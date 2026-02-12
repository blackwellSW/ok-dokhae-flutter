class ApiConfig {
  /// true면 데모, false면 실서버
  static const bool demoMode =
      bool.fromEnvironment('DEMO_MODE', defaultValue: false);

  // 실서버 Base URL
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
        'https://ok-dokhae-backend-84537953160.asia-northeast1.run.app',
  );

  /// 네트워크 타임아웃(초)
  static const int connectTimeoutSec =
      int.fromEnvironment('CONNECT_TIMEOUT_SEC', defaultValue: 10);
  static const int receiveTimeoutSec =
      int.fromEnvironment('RECEIVE_TIMEOUT_SEC', defaultValue: 10);
}
