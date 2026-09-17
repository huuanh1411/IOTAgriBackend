// Requires the PubSubClient library. All other headers ship with ESP32 Arduino core.
  #include <DNSServer.h>
  #include <HTTPClient.h>
  #include <Preferences.h>
  #include <PubSubClient.h>
  #include <WebServer.h>
  #include <WiFi.h>

  DNSServer dns;
  WebServer server(80);
  Preferences settings;
  WiFiClient network;
  PubSubClient mqtt(network);

  String apiUrl, mqttHost, deviceKey;
  int mqttPort;
  bool setupMode;
  unsigned long lastPublish;

  String hardwareId() {
    uint64_t id = ESP.getEfuseMac();
    char value[17];
    snprintf(value, sizeof(value), "%08X%08X", (uint32_t)(id >> 32), (uint32_t)id);
    return value;
  }

  String jsonString(const String& json, const char* key) {
    String marker = String("\"") + key + "\":\"";
    int start = json.indexOf(marker);
    if (start < 0) return "";
    start += marker.length();
    int end = json.indexOf('"', start);
    return end < 0 ? "" : json.substring(start, end);
  }

  int jsonInt(const String& json, const char* key) {
    String marker = String("\"") + key + "\":";
    int start = json.indexOf(marker);
    return start < 0 ? 0 : json.substring(start + marker.length()).toInt();
  }

  bool jsonBool(const String& json, const char* key) {
    return json.indexOf(String("\"") + key + "\":true") >= 0;
  }

  bool connectWifi(const String& ssid, const String& password) {
    WiFi.begin(ssid.c_str(), password.c_str());
    for (int i = 0; i < 40 && WiFi.status() != WL_CONNECTED; i++) delay(500);
    return WiFi.status() == WL_CONNECTED;
  }

  bool claimDevice(const String& code) {
    HTTPClient http;
    http.begin(apiUrl + "/api/device-provisioning/claims");
    http.addHeader("Content-Type", "application/json");
    String body = "{\"code\":\"" + code + "\",\"hardwareId\":\"" + hardwareId() + "\"}";
    int status = http.POST(body);
    String response = http.getString();
    http.end();
    if (status != HTTP_CODE_OK || jsonBool(response, "useTls")) return false;

    deviceKey = jsonString(response, "deviceKey");
    mqttHost = jsonString(response, "mqttHost");
    mqttPort = jsonInt(response, "mqttPort");
    return !deviceKey.isEmpty() && !mqttHost.isEmpty() && mqttPort > 0;
  }

  void saveSettings(const String& ssid, const String& password) {
    settings.begin("iotagri", false);
    settings.putString("ssid", ssid);
    settings.putString("pass", password);
    settings.putString("api", apiUrl);
    settings.putString("host", mqttHost);
    settings.putString("key", deviceKey);
    settings.putInt("port", mqttPort);
    settings.end();
  }

  void startPortal() {
    setupMode = true;
    WiFi.mode(WIFI_AP);
    WiFi.softAP("IOTAgri-Setup");
    dns.start(53, "*", WiFi.softAPIP());
    server.on("/", HTTP_GET, [] {
      server.send(200, "text/html", R"html(
        <h2>IOTAgri device setup</h2><form method='post' action='/save'>
        Wi-Fi name <input name='wifi' required><br>Wi-Fi password <input name='pass' type='password'><br>
        Backend URL <input name='api' value='http://192.168.12.140:8080' required><br>
        Claim code <input name='code' required><br><button>Connect</button></form>)html");
    });
    server.on("/save", HTTP_POST, [] {
      apiUrl = server.arg("api");
      WiFi.mode(WIFI_AP_STA);
      if (!connectWifi(server.arg("wifi"), server.arg("pass"))) {
        server.send(400, "text/plain", "Wi-Fi connection failed. Check the network details.");
        return;
      }
      if (!claimDevice(server.arg("code"))) {
        server.send(400, "text/plain", "Claim failed. Check the code, backend URL, and MQTT TLS setting.");
        return;
      }
      saveSettings(server.arg("wifi"), server.arg("pass"));
      server.send(200, "text/plain", "Connected. Device will restart now.");
      delay(1000);
      ESP.restart();
    });
    server.begin();
    Serial.printf("Setup Wi-Fi: IOTAgri-Setup; open http://%s\n", WiFi.softAPIP().toString().c_str());
  }

  void connectMqtt() {
    if (mqtt.connected()) return;
    char clientId[32];
    snprintf(clientId, sizeof(clientId), "iotagr-%s", hardwareId().c_str());
    if (mqtt.connect(clientId)) Serial.println("MQTT connected");
    else Serial.printf("MQTT retry later (%d)\n", mqtt.state());
  }

  void setup() {
    Serial.begin(115200);
    settings.begin("iotagri", true);
    String ssid = settings.getString("ssid");
    String password = settings.getString("pass");
    apiUrl = settings.getString("api");
    mqttHost = settings.getString("host");
    deviceKey = settings.getString("key");
    mqttPort = settings.getInt("port");
    settings.end();

    WiFi.mode(WIFI_STA);
    if (ssid.isEmpty() || !connectWifi(ssid, password)) startPortal();
    else {
      mqtt.setServer(mqttHost.c_str(), mqttPort);
      Serial.printf("Wi-Fi connected: %s\n", WiFi.localIP().toString().c_str());
    }
  }

  void loop() {
    if (setupMode) {
      dns.processNextRequest();
      server.handleClient();
      return;
    }

    connectMqtt();
    mqtt.loop();
    if (millis() - lastPublish < 10000 || !mqtt.connected()) return;
    lastPublish = millis();

    char topic[128];
    snprintf(topic, sizeof(topic), "devices/%s/readings", deviceKey.c_str());
    const char* payload = "{\"temperature\":26.5,\"humidity\":61.2,\"ph\":6.1,\"tds\":850,\"waterLevel\":42}";
    Serial.println(mqtt.publish(topic, payload) ? "Reading published" : "Publish failed");
  }
