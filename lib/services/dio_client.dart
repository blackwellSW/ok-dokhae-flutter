import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  // 백엔드 주소
  static const String baseUrl = "https://ok-dokhae-backend-84537953160.asia-northeast1.run.app";
  
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  DioClient() : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 300),
    receiveTimeout: const Duration(seconds: 300), 
    sendTimeout: const Duration(seconds: 300),
    responseType: ResponseType.json,
  )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        // 에러 로그
        print("API 에러 발생: ${error.response?.statusCode} / ${error.message}");
        return handler.next(error);
      },
    ));
  }

  // 외부에서 Dio 인스턴스를 가져다 쓸 수 있게 getter 제공
  Dio get dio => _dio;

  // 토큰 저장 (로그인 성공 시 호출)
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  // 토큰 삭제 (로그아웃 시 호출)
  Future<void> deleteToken() async {
    await _storage.delete(key: 'access_token');
  }
}