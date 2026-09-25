class PumpSchedule {
  final String id;
  final String deviceId;
  final bool isEnabled;
  final int weekdayMask;
  final String startTime;
  final int durationSeconds;
  final String timeZone;
  final String? lastDispatchedOccurrenceUtc;
  final String createdAt;

  PumpSchedule({
    required this.id,
    required this.deviceId,
    required this.isEnabled,
    required this.weekdayMask,
    required this.startTime,
    required this.durationSeconds,
    required this.timeZone,
    this.lastDispatchedOccurrenceUtc,
    required this.createdAt,
  });

  factory PumpSchedule.fromJson(Map<String, dynamic> json) {
    return PumpSchedule(
      id: json['id'] ?? '',
      deviceId: json['deviceId'] ?? '',
      isEnabled: json['isEnabled'] ?? false,
      weekdayMask: json['weekdayMask'] ?? 0,
      startTime: json['startTime'] ?? '',
      durationSeconds: json['durationSeconds'] ?? 0,
      timeZone: json['timeZone'] ?? '',
      lastDispatchedOccurrenceUtc: json['lastDispatchedOccurrenceUtc'],
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceId': deviceId,
      'isEnabled': isEnabled,
      'weekdayMask': weekdayMask,
      'startTime': startTime,
      'durationSeconds': durationSeconds,
      'timeZone': timeZone,
      'lastDispatchedOccurrenceUtc': lastDispatchedOccurrenceUtc,
      'createdAt': createdAt,
    };
  }
}