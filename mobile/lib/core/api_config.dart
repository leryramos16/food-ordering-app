class ApiConfig {
  ApiConfig._();

  // Android emulator reaches the host machine through 10.0.2.2.
  // For a physical phone, pass your PC's LAN IP when running Flutter:
  // flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );
}
