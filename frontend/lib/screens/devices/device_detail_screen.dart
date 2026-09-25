import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/device.dart';
import '../../models/sensor_reading.dart';
import '../../models/pump_command.dart';
import '../../models/device_alert.dart';
import '../../services/api_service.dart';

class DeviceDetailScreen extends StatefulWidget {
  final Device device;

  const DeviceDetailScreen({super.key, required this.device});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  final ApiService _apiService = ApiService();
  SensorReading? _latestReading;
  List<SensorReading> _readings = [];
  List<PumpCommand> _pumpCommands = [];
  List<DeviceAlert> _alerts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDeviceData();
  }

  Future<void> _loadDeviceData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _apiService.getDeviceReadings(widget.device.id, limit: 1),
        _apiService.getDeviceReadings(widget.device.id, limit: 20),
        _apiService.getPumpCommands(widget.device.id),
        _apiService.getAlerts(widget.device.id),
      ]);

      setState(() {
        final readings1 = results[0] as List<dynamic>;
        final readings2 = results[1] as List<dynamic>;
        final commandsData = results[2] as Map<String, dynamic>;
        final alertsData = results[3] as Map<String, dynamic>;

        if (readings1.isNotEmpty) {
          _latestReading = SensorReading.fromJson(readings1[0]);
        }
        _readings = readings2.map((data) => SensorReading.fromJson(data)).toList();
        
        final commandsItems = commandsData['items'] as List<dynamic>?;
        _pumpCommands = commandsItems?.map((data) => PumpCommand.fromJson(data)).toList() ?? [];
        
        final alertsItems = alertsData['items'] as List<dynamic>?;
        _alerts = alertsItems?.map((data) => DeviceAlert.fromJson(data)).toList() ?? [];
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Color _getTemperatureColor(double? temp) {
    if (temp == null) return Colors.grey;
    if (temp > 30) return Colors.red;
    if (temp < 15) return Colors.blue;
    return Colors.green;
  }

  Color _getWaterLevelColor(double? level) {
    if (level == null) return Colors.grey;
    if (level < 30) return Colors.red;
    if (level < 50) return Colors.orange;
    return Colors.green;
  }

  Future<void> _sendPumpCommand(bool isOn, int durationSeconds) async {
    try {
      final commandId = DateTime.now().millisecondsSinceEpoch.toString();
      await _apiService.sendPumpCommand(
        widget.device.id,
        commandId,
        isOn,
        durationSeconds,
      );
      await _loadDeviceData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isOn ? 'Đã bật bơm' : 'Đã tắt bơm'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDeviceData,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Lỗi: $_errorMessage',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDeviceData,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          _buildDeviceStatus(),
          const TabBar(
            tabs: [
              Tab(text: 'Tổng quan'),
              Tab(text: 'Cảm biến'),
              Tab(text: 'Bơm'),
              Tab(text: 'Cảnh báo'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildOverviewTab(),
                _buildSensorsTab(),
                _buildPumpTab(),
                _buildAlertsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: widget.device.isOnline ? Colors.green[50] : Colors.red[50],
      child: Row(
        children: [
          Icon(
            widget.device.isOnline ? Icons.wifi : Icons.wifi_off,
            color: widget.device.isOnline ? Colors.green : Colors.red,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.device.isOnline ? 'Đang hoạt động' : 'Mất kết nối',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.device.isOnline ? Colors.green : Colors.red,
                  ),
                ),
                if (widget.device.lastSeenAt != null)
                  Text(
                    'Lần hoạt động cuối: ${_formatDate(widget.device.lastSeenAt!)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chỉ số cảm biến mới nhất',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_latestReading != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSensorRow(
                      'Nhiệt độ',
                      '${_latestReading!.temperature?.toStringAsFixed(1) ?? 'N/A'}°C',
                      _getTemperatureColor(_latestReading!.temperature),
                      Icons.thermostat,
                    ),
                    const Divider(),
                    _buildSensorRow(
                      'Độ ẩm',
                      '${_latestReading!.humidity?.toStringAsFixed(1) ?? 'N/A'}%',
                      Colors.blue,
                      Icons.water_drop,
                    ),
                    const Divider(),
                    _buildSensorRow(
                      'pH',
                      _latestReading!.ph?.toStringAsFixed(1) ?? 'N/A',
                      Colors.purple,
                      Icons.science,
                    ),
                    const Divider(),
                    _buildSensorRow(
                      'Mực nước',
                      '${_latestReading!.waterLevel?.toStringAsFixed(1) ?? 'N/A'}%',
                      _getWaterLevelColor(_latestReading!.waterLevel),
                      Icons.opacity,
                    ),
                  ],
                ),
              ),
            )
          else
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Chưa có dữ liệu cảm biến'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSensorRow(String label, String value, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSensorsTab() {
    if (_readings.isEmpty) {
      return const Center(child: Text('Chưa có dữ liệu cảm biến'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _readings.length,
      itemBuilder: (context, index) {
        final reading = _readings[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(reading.recordedAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildCompactSensor('Nhiệt độ', '${reading.temperature?.toStringAsFixed(1) ?? 'N/A'}°C'),
                    ),
                    Expanded(
                      child: _buildCompactSensor('Độ ẩm', '${reading.humidity?.toStringAsFixed(1) ?? 'N/A'}%'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildCompactSensor('pH', reading.ph?.toStringAsFixed(1) ?? 'N/A'),
                    ),
                    Expanded(
                      child: _buildCompactSensor('Mực nước', '${reading.waterLevel?.toStringAsFixed(1) ?? 'N/A'}%'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactSensor(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPumpTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Điều khiển bơm thủ công',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _sendPumpCommand(true, 60),
                  icon: const Icon(Icons.power_settings_new),
                  label: const Text('Bật bơm (1 phút)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _sendPumpCommand(false, 0),
                  icon: const Icon(Icons.power_off),
                  label: const Text('Tắt bơm'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Lịch sử lệnh bơm',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_pumpCommands.isEmpty)
            const Text('Chưa có lệnh nào')
          else
            ..._pumpCommands.map((command) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  command.isOn ? Icons.toggle_on : Icons.toggle_off,
                  color: command.isOn ? Colors.green : Colors.red,
                ),
                title: Text(command.isOn ? 'BẬT' : 'TẮT'),
                subtitle: Text('${command.durationSeconds} giây'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      command.status,
                      style: TextStyle(
                        color: command.status == 'Acknowledged'
                            ? Colors.green
                            : command.status == 'Failed'
                                ? Colors.red
                                : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatDate(command.issuedAt),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildAlertsTab() {
    if (_alerts.isEmpty) {
      return const Center(child: Text('Không có cảnh báo nào'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _alerts.length,
      itemBuilder: (context, index) {
        final alert = _alerts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: Colors.red[50],
          child: ListTile(
            leading: const Icon(Icons.warning, color: Colors.red),
            title: Text(
              alert.type == 'HighTemperature' ? 'Nhiệt độ cao' : 'Mực nước thấp',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            subtitle: Text('Giá trị: ${alert.measuredValue} - Ngưỡng: ${alert.threshold}'),
            trailing: Text(_formatDate(alert.triggeredAt)),
          ),
        );
      },
    );
  }
}