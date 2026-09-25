class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  // Auth endpoints
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String refresh = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';

  // Device endpoints
  static const String devices = '/api/devices';
  static String device(String id) => '/api/devices/$id';

  // Dashboard endpoints
  static const String dashboardOverview = '/api/dashboard/overview';

  // Sensor endpoints
  static String deviceReadings(String id) => '/api/devices/$id/readings';
  static String aggregatedReadings(String id) => '/api/devices/$id/readings/aggregated';

  // Pump control endpoints
  static String pumpCommands(String id) => '/api/devices/$id/pump/commands';
  static String pumpCommandHistory(String id) => '/api/devices/$id/pump-commands';
  static String pumpSchedules(String id) => '/api/devices/$id/pump-schedules';
  static String pumpSchedule(String id, String scheduleId) => '/api/devices/$id/pump-schedules/$scheduleId';

  // Alert endpoints
  static String alertSettings(String id) => '/api/devices/$id/alert-settings';
  static String alerts(String id) => '/api/devices/$id/alerts';
}