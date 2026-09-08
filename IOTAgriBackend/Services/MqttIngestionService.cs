using System.Buffers;
using System.Text;
using System.Text.Json;
using IOTAgriBackend.Data;
using IOTAgriBackend.Dtos.Sensors;
using IOTAgriBackend.Models;
using Microsoft.EntityFrameworkCore;
using MQTTnet;

namespace IOTAgriBackend.Services;

// Subscribes to devices/{deviceKey}/readings on the configured MQTT broker and persists incoming sensor data.
public class MqttIngestionService : BackgroundService
{
    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web);

    private readonly IServiceScopeFactory _scopeFactory;
    private readonly IConfiguration _configuration;
    private readonly ILogger<MqttIngestionService> _logger;
    private readonly IMqttClient _mqttClient;

    public MqttIngestionService(
        IServiceScopeFactory scopeFactory,
        IConfiguration configuration,
        ILogger<MqttIngestionService> logger)
    {
        _scopeFactory = scopeFactory;
        _configuration = configuration;
        _logger = logger;
        _mqttClient = new MqttClientFactory().CreateMqttClient();
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var mqttSection = _configuration.GetSection("Mqtt");
        var host = mqttSection["Host"] ?? "localhost";
        var port = mqttSection.GetValue<int?>("Port") ?? 1883;
        var useTls = mqttSection.GetValue<bool>("UseTls");
        var username = mqttSection["Username"];
        var password = mqttSection["Password"];
        var clientId = mqttSection["ClientId"] ?? $"iotagribackend-{Guid.NewGuid():N}";
        var topicFilter = mqttSection["ReadingsTopicFilter"] ?? "devices/+/readings";

        var optionsBuilder = new MqttClientOptionsBuilder()
            .WithTcpServer(host, port)
            .WithClientId(clientId)
            .WithCleanSession();

        if (!string.IsNullOrEmpty(username))
        {
            optionsBuilder = optionsBuilder.WithCredentials(username, password);
        }

        if (useTls)
        {
            optionsBuilder = optionsBuilder.WithTlsOptions(o => o.UseTls());
        }

        var options = optionsBuilder.Build();

        _mqttClient.ApplicationMessageReceivedAsync += OnMessageReceivedAsync;

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                if (!_mqttClient.IsConnected)
                {
                    await _mqttClient.ConnectAsync(options, stoppingToken);

                    var subscribeOptions = new MqttClientFactory()
                        .CreateSubscribeOptionsBuilder()
                        .WithTopicFilter(topicFilter)
                        .Build();

                    await _mqttClient.SubscribeAsync(subscribeOptions, stoppingToken);
                    _logger.LogInformation("MQTT connected to {Host}:{Port} and subscribed to {Topic}", host, port, topicFilter);
                }
            }
            catch (Exception ex) when (ex is not OperationCanceledException)
            {
                _logger.LogWarning(ex, "MQTT connection attempt failed, retrying in 5s.");
            }

            await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
        }
    }

    private async Task OnMessageReceivedAsync(MqttApplicationMessageReceivedEventArgs args)
    {
        try
        {
            var topic = args.ApplicationMessage.Topic;
            var segments = topic.Split('/');
            if (segments.Length < 3 || segments[0] != "devices" || segments[2] != "readings")
            {
                return;
            }

            var deviceKey = segments[1];
            var payloadBytes = args.ApplicationMessage.Payload.ToArray();
            var request = JsonSerializer.Deserialize<SensorReadingRequest>(Encoding.UTF8.GetString(payloadBytes), JsonOptions);
            if (request is null)
            {
                return;
            }

            using var scope = _scopeFactory.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

            var device = await db.Devices.FirstOrDefaultAsync(d => d.DeviceKey == deviceKey);
            if (device is null)
            {
                _logger.LogWarning("Received MQTT reading for unknown device key on topic {Topic}.", topic);
                return;
            }

            var reading = new SensorReading
            {
                DeviceId = device.Id,
                Temperature = request.Temperature,
                Humidity = request.Humidity,
                Ph = request.Ph,
                Tds = request.Tds,
                WaterLevel = request.WaterLevel,
            };

            db.SensorReadings.Add(reading);
            device.IsOnline = true;
            device.LastSeenAt = reading.RecordedAt;
            await db.SaveChangesAsync();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to process incoming MQTT sensor reading.");
        }
    }

    public override async Task StopAsync(CancellationToken cancellationToken)
    {
        if (_mqttClient.IsConnected)
        {
            await _mqttClient.DisconnectAsync(cancellationToken: cancellationToken);
        }

        await base.StopAsync(cancellationToken);
    }
}
