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

  // 화면이 세션 ID를 몰라도 되도록 내부에서 관리
  String? _currentSessionId;

  @override
  Future<List<Work>> getWorks() async {
    // 백엔드의 Document를 UI의 Work 모델로 변환 (어댑터 역할)
    List<Document> docs = await _docRepo.getDocuments();
    return docs.map((doc) => Work(
      id: doc.id,
      title: doc.title,
      author: "업로드된 문서", // 백엔드에 정보가 없으면 기본값
      category: "개인 학습",
      baseColor: const Color(0xFF5D4037), // 기본 테마색
      patternColor: const Color(0xFFD7CCC8),
      spineColor: const Color(0xFF3E2723),
      studyTime: doc.charCount != null ? "${(doc.charCount! / 500).ceil()}분" : "미정",
    )).toList();
  }

  @override
  Future<String> startThinkingSession(String workId) async {
    // workId == documentId
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
      return {"text": "세션이 만료되었습니다. 다시 시작해주세요.", "is_finish": true};
    }

    final result = await _sessionRepo.sendMessage(_currentSessionId!, userAnswer);
    
    if (result != null) {
      // 백엔드 응답을 UI 포맷에 맞게 변환
      return {
        "text": result['assistant_message'],
        // status가 completed면 종료 신호 보냄
        "is_finish": result['session_status'] == 'completed' || result['session_status'] == 'finalized', 
      };
    }
    return {"text": "오류가 발생했습니다.", "is_finish": false};
  }

  // 아래 메서드들은 현재 대화형 UI에서는 사용되지 않으나 인터페이스 구현을 위해 둠
  @override
  Future<List<String>> getWorkContent(String workId) async => [];
  @override
  Future<List<Task>> getTasks(String workId) async => [];
  @override
  Future<Map<String, dynamic>> submitResult(String workId, logs) async => {};
}