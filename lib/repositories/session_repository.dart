import '../services/dio_client.dart';

class SessionRepository {
  final DioClient _client = DioClient();

  // 세션 생성 (명세서: POST /sessions)
  // 반환값: Map (session_id, first_question 포함)
  Future<Map<String, dynamic>?> createSession(String documentId, {String mode = 'student_led'}) async {
    try {
      final response = await _client.dio.post(
        '/sessions',
        data: {
          'document_id': documentId,
          'mode': mode,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
    } catch (e) {
      print("세션 생성 실패: $e");
    }
    return null;
  }

  // 메시지 전송 (명세서: POST /sessions/{id}/messages)
  Future<Map<String, dynamic>?> sendMessage(String sessionId, String content) async {
    try {
      final response = await _client.dio.post(
        '/sessions/$sessionId/messages',
        data: {
          'content': content,
        },
      );

      if (response.statusCode == 200) {
        return response.data; 
      }
    } catch (e) {
      print("메시지 전송 실패: $e");
    }
    return null;
  }

  // 세션 강제 종료 (명세서: POST /sessions/{id}/finalize)
  Future<String?> finalizeSession(String sessionId) async {
    try {
      final response = await _client.dio.post('/sessions/$sessionId/finalize');
      if (response.statusCode == 200) {
        return response.data['report_id'];
      }
    } catch (e) {
      print("세션 종료 실패: $e");
    }
    return null;
  }
}