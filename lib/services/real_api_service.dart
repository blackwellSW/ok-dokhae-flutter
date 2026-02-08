import 'package:flutter/material.dart';
import '../models/work.dart';
import '../models/session_task.dart';
import '../models/document_model.dart';
import '../repositories/document_repository.dart';
import '../repositories/session_repository.dart';
import 'api_service.dart';

class RealApiService implements ApiService {
  final DocumentRepository _docRepo = DocumentRepository();
  final SessionRepository _sessionRepo = SessionRepository();

  String? _currentSessionId;

  @override
  Future<List<Work>> getWorks() async {
    try {
      List<Document> docs = await _docRepo.getDocuments();
      
      return docs.map((doc) {
        // [수정] 글자수 기반 시간 계산
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
      // [핵심] 서버가 완료 신호를 주면 is_finish를 true로 설정 -> 리포트 화면 이동 트리거
      final status = result['session_status'] as String?;
      final isFinished = status == 'completed' || status == 'finalized';
      
      return {
        "text": result['assistant_message'] ?? "응답이 없습니다.",
        "is_finish": isFinished, 
      };
    }
    return {"text": "네트워크 오류가 발생했습니다.", "is_finish": false};
  }

  @override
  Future<List<Task>> getTasks(String workId) async => [];

  @override
  Future<Map<String, dynamic>> submitResult(String workId, dynamic logs) async => {};
}