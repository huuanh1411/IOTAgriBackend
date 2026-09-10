/// Tuong ung Dtos/Devices/DeviceResponse.cs
/// (GET/PUT /api/devices... - KHONG chua deviceKey)
class Device {
  const Device({
    required this.id,
    required this.name,
    required this.isOnline,
    required this.lastSeenAt,
    required this.createdAt,
  });

  final String id;
  final String name;
  final bool isOnline;
  final DateTime? lastSeenAt;
  final DateTime createdAt;

  factory Device.fromJson(Map<String, dynamic> json) => Device(
        id: json['id'] as String,
        name: json['name'] as String,
        isOnline: json['isOnline'] as bool,
        lastSeenAt: json['lastSeenAt'] == null
            ? null
            : DateTime.parse(json['lastSeenAt'] as String).toLocal(),
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      );

  Device copyWith({String? name, bool? isOnline, DateTime? lastSeenAt}) => Device(
        id: id,
        name: name ?? this.name,
        isOnline: isOnline ?? this.isOnline,
        lastSeenAt: lastSeenAt ?? this.lastSeenAt,
        createdAt: createdAt,
      );
}

/// Tuong ung ket qua tra ve tu POST /api/devices - CHI xuat hien 1 lan duy
/// nhat, chua "deviceKey" (secret ma ESP32 dung de publish MQTT).
class NewDeviceResult {
  const NewDeviceResult({
    required this.id,
    required this.name,
    required this.deviceKey,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String deviceKey;
  final DateTime createdAt;

  factory NewDeviceResult.fromJson(Map<String, dynamic> json) => NewDeviceResult(
        id: json['id'] as String,
        name: json['name'] as String,
        deviceKey: json['deviceKey'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      );
}
