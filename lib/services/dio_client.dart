import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  // 백엔드 주소 (마지막 슬래시 제외)
  static const String baseUrl = "https://ok-dokhae-backend-84537953160.asia-northeast1.run.app";
  
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  DioClient() : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    responseType: ResponseType.json,
  )) {
    // [Interceptor 설정] 모든 요청 헤더에 토큰 자동 추가
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 저장된 토큰 꺼내기
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        print("API 에러 발생: ${error.response?.statusCode} / ${error.message}");
        return handler.next(error);
      },
    ));
  }

  // 외부에서 Dio 인스턴스를 가져다 쓸 수 있게 getter 제공
  Dio get dio => _dio;
  
  // 토큰 저장/삭제 헬퍼
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }
  
  Future<void> deleteToken() async {
    await _storage.delete(key: 'access_token');
  }
}