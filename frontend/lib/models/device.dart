class Device {
  final String id;
  final String name;
  final bool isOnline;
  final String? lastSeenAt;
  final String createdAt;
  final String? deviceKey;

  Device({
    required this.id,
    required this.name,
    required this.isOnline,
    this.lastSeenAt,
    required this.createdAt,
    this.deviceKey,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      isOnline: json['isOnline'] ?? false,
      lastSeenAt: json['lastSeenAt'],
      createdAt: json['createdAt'] ?? '',
      deviceKey: json['deviceKey'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isOnline': isOnline,
      'lastSeenAt': lastSeenAt,
      'createdAt': createdAt,
      'deviceKey': deviceKey,
    };
  }
}