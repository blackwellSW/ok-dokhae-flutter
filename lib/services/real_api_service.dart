import 'package:flutter/material.dart';
import '../models/work.dart';
import '../models/session_task.dart';
import '../models/document_model.dart';
import '../repositories/document_repository.dart';
import '../repositories/session_repository.dart';
import '../services/dio_client.dart';
import 'package:dio/dio.dart';
import 'api_service.dart';

class RealApiService implements ApiService {
  final DocumentRepository _docRepo = DocumentRepository();
  final SessionRepository _sessionRepo = SessionRepository();
  final DioClient _client = DioClient();

  String? _currentSessionId;

  @override
  Future<List<Work>> getWorks() async {
    try {
      List<Document> docs = await _docRepo.getDocuments();
      return docs.map((doc) {
        final int count = doc.charCount ?? 0;
        final String timeStr = count > 0 ? "${(count / 500).ceil()}분" : "분석 중";

        return Work(
          id: doc.id.isEmpty ? "temp_${DateTime.now().millisecondsSinceEpoch}" : doc.id,
          title: doc.title.isEmpty ? "제목 없음" : doc.title,
          author: "내 문서함",
          category: "개인 학습",
          baseColor: const Color(0xFF02B152),
          patternColor: const Color(0xFFE8F5E9),
          spineColor: const Color(0xFF1B5E20),
          studyTime: timeStr,
        );
      }).toList();
    } catch (e) {
      print("Service 에러: $e");
      return [];
    }
  }

  @override
  Future<List<String>> getWorkContent(String workId) async {
    return await _docRepo.getDocumentContent(workId);
  }

  @override
  Future<String> startThinkingSession(String workId) async {
    final result = await _sessionRepo.createSession(workId);
    if (result != null) {
      _currentSessionId = result['session_id'];
      return result['first_question'] ?? "질문을 생성하는 중입니다...";
    }
    return "세션 생성에 실패했습니다.";
  }

  @override
  Future<Map<String, dynamic>> getGuidance(String workId, String userAnswer) async {
    if (_currentSessionId == null) {
      return {"text": "세션이 만료되었습니다.", "is_finish": true};
    }

    final result = await _sessionRepo.sendMessage(_currentSessionId!, userAnswer);

    if (result != null) {
      final status = result['session_status'] as String?;
      final isFinished = status == 'completed' || status == 'finalized';
      
      Map<String, dynamic>? reportData;

      // 세션 종료 시 리포트 데이터 조회
      if (isFinished) {
        try {
          print("📊 1차 리포트 조회 요청: /sessions/$_currentSessionId/report");
          final reportRes = await _client.dio.get('/sessions/$_currentSessionId/report');
          
          if (reportRes.statusCode == 200) {
            final data = reportRes.data;

            if (data['report_id'] != null && data['summary'] == null) {
               final String reportId = data['report_id'];

               for (int i = 0; i < 10; i++) {
                 try {
                   print("🔄 2차 상세 리포트 요청 (${i + 1}/10): /reports/$reportId");

                   await Future.delayed(const Duration(seconds: 3));
                   
                   final detailRes = await _client.dio.get('/reports/$reportId');
                   if (detailRes.statusCode == 200) {
                     reportData = detailRes.data;
                     print("✅ 진짜 리포트 데이터 수신 완료!");
                     break;
                   }
                 } on DioException catch (e) {
                   if (e.response?.statusCode == 404) {
                     print("⏳ 아직 리포트 생성 중... (404 Not Found Yet)");
                     continue;
                   } else {
                     print("❌ 리포트 요청 중 다른 에러 발생: $e");

                     continue;
                   }
                 }
               }
               
               if (reportData == null) {
                 print("⚠️ 리포트 생성 시간 초과(30초). 껍데기 데이터 반환.");
                 reportData = data;
               }

            } else {
               reportData = data;
               print("✅ 리포트 데이터 수신 완료 (한 번에 성공)");
            }
          }
        } catch (e) {
          print("❌ 리포트 조회 실패: $e");
        }
      }

      return {
        "text": result['assistant_message'] ?? "응답이 없습니다.",
        "is_finish": isFinished,
        "report": reportData,
      };
    }
    return {"text": "네트워크 오류가 발생했습니다.", "is_finish": false};
  }

  @override
  Future<List<Task>> getTasks(String workId) async => [];

  @override
  Future<Map<String, dynamic>> submitResult(String workId, dynamic logs) async => {};
}