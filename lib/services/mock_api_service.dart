import 'package:flutter/material.dart';
import 'api_service.dart';
import '../models/work.dart';
import '../models/session_task.dart';

class MockApiService implements ApiService {
  @override
  Future<List<Work>> getWorks() async {
    return [
      Work(id: 'simcheong', title: '심청전', author: '작자미상', category: '고전소설', baseColor: const Color(0xFFD7CCC8), patternColor: const Color(0xFF8D6E63), spineColor: const Color(0xFF5D4037)),
      Work(id: 'gwandong', title: '관동별곡', author: '정철', category: '고전시가', baseColor: const Color(0xFFC8E6C9), patternColor: const Color(0xFF2E7D32), spineColor: const Color(0xFF1B5E20)),
    ];
  }

  @override
  Future<List<String>> getWorkContent(String workId) async {
    await Future.delayed(const Duration(milliseconds: 500)); 
    if (workId == 'simcheong') {
      return [
        "심청이 거동 봐라.",
        "밥 빌러 나갈 제, 치마 자락을 거둠거둠 안고...",
        "\"아가 아가 심청 아가. 이리 와서 점심이나 먹고 가라.\"",
        "심청이 생각한들 아니 슬플소냐."
      ];
    } 
    return [
      "[파일 내용 추출 완료]",
      "업로드하신 문서의 텍스트가 여기에 표시됩니다.",
      "튜터가 내용을 분석하여 학습을 도와드립니다.",
      "(실제 구현 시에는 PDF/TXT 파싱 결과가 들어갑니다)"
    ];
  }

  @override
  Future<String> startThinkingSession(String workId) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // [피드백 반영] 시험 문제 톤 -> 대화 유도 톤
    // Before: "이 글의 핵심 주제는 무엇인가요?"
    // After: 읽고 나서 가장 기억에 남는 장면이나, 한 문장으로 요약하고 싶은 게 있나요?
    return "이 글을 다 읽고 나서 가장 기억에 남는 장면이나, 한 문장으로 요약하고 싶은 내용이 있나요?";
  }

  @override
  Future<Map<String, dynamic>> getGuidance(String workId, String userAnswer) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (userAnswer.length < 5) {
      return {"text": "조금 더 구체적으로 이야기해 줄래요? 본문의 내용을 인용하면 더 좋아요.", "is_finish": false};
    }
    return {"text": "흥미로운 생각이네요! 본문의 어떤 문장이 그런 생각을 하게 만들었나요?", "is_finish": false};
  }

  @override
  Future<List<Task>> getTasks(String workId) async => [];
  @override
  Future<Map<String, dynamic>> submitResult(String workId, dynamic logs) async => {};
}