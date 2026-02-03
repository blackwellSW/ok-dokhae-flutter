import 'package:flutter/material.dart';
import 'api_service.dart';
import '../models/work.dart';
import '../models/session_task.dart';

class MockApiService implements ApiService {
  @override
  Future<List<Work>> getWorks() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      Work(
        id: 'simcheong', // [중요] 이 ID로 데이터를 찾습니다.
        title: '심청전',
        author: '작자미상',
        category: '고전소설',
        baseColor: const Color(0xFFD7CCC8),
        patternColor: const Color(0xFF8D6E63),
        spineColor: const Color(0xFF5D4037),
        completedSets: 3,
        studyTime: '7분',
        difficulty: '중',
      ),
      Work(
        id: 'gwandong',
        title: '관동별곡',
        author: '정철',
        category: '고전시가',
        baseColor: const Color(0xFFC8E6C9),
        patternColor: const Color(0xFF2E7D32),
        spineColor: const Color(0xFF1B5E20),
        completedSets: 0,
        studyTime: '10분',
        difficulty: '상',
      ),
      // (나머지 더미 데이터 생략 가능하지만, 리스트 유지를 위해 둠)
      Work(
        id: 'honggildong',
        title: '홍길동전',
        author: '허균',
        category: '고전소설',
        baseColor: const Color(0xFFFFE0B2),
        patternColor: const Color(0xFFEF6C00),
        spineColor: const Color(0xFFE65100),
        completedSets: 0,
        studyTime: '6분',
        difficulty: '하',
      ),
      Work(
        id: 'chunhyang',
        title: '춘향전',
        author: '작자미상',
        category: '고전소설',
        baseColor: const Color(0xFFFFCCBC),
        patternColor: const Color(0xFFD84315),
        spineColor: const Color(0xFFBF360C),
        completedSets: 1,
        studyTime: '8분',
        difficulty: '중',
      ),
      Work(
        id: 'chungsan',
        title: '청산별곡',
        author: '작자미상',
        category: '고전시가',
        baseColor: const Color(0xFFDCEDC8),
        patternColor: const Color(0xFF558B2F),
        spineColor: const Color(0xFF33691E),
        completedSets: 0,
        studyTime: '5분',
        difficulty: '중',
      ),
    ];
  }

  // [구현] 지문 데이터 반환
  @override
  Future<List<String>> getWorkContent(String workId) async {
    await Future.delayed(const Duration(milliseconds: 500)); // 짧은 로딩

    // 지금은 '심청전(simcheong)' 데이터만 준비됨
    if (workId == 'simcheong') {
      return [
        "심청이 거동 봐라. ",
        "밥 빌러 나갈 제, 치마 자락을 거둠거둠 안고 허리띠를 매고, 바가지 옆에 끼고, 본동을 휩돌아 중문을 나서니, ",
        "건너편 징검다리에서 동네 여인들이 빨래하다가 심청을 보고 하는 말이, ",
        "\"아가 아가 심청 아가. 이리 와서 점심이나 먹고 가라.\" ",
        "등을 밀어 밥을 주며, 머리 감겨 빗겨 주며, ",
        "\"불쌍하다 심청 아가. 쯧쯧.\" 혀를 차니 ",
        "심청이 생각한들 아니 슬플소냐. ",
        "어느 집을 다다르니, 늙은 할미 밖을 보며, ",
        "\"그 누구냐?\" \"심봉사 딸 심청이요. 밥 좀 빌러 왔습니다.\" ",
        "\"어 들어오너라. 내 밥 푸마.\" ",
        "밥을 꾹꾹 눌러 담아 주며 하는 말이, ",
        "\"너의 부친 밥이라도 걱정 말고 먹고 가라.\""
      ];
    } 
    
    // 다른 작품 데이터가 아직 없으면 기본 텍스트 반환 (에러 방지)
    return ["(아직 준비되지 않은 지문입니다.)", "다른 작품을 선택해주세요."];
  }

  // [구현] 문제 데이터 반환
  @override
  Future<List<Task>> getTasks(String workId) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (workId == 'simcheong') {
      return [
        Task(
          id: 't1',
          typeTag: "상황 파악",
          question: "노란색 구절에서 '동네 여인들'이 심청에게 느끼는 주된 감정은?",
          options: ["질투와 시기심", "안타까움과 연민", "무관심과 냉소", "반가움과 환대"],
          correctOptionIndex: 1,
          highlightSentenceIndex: 2,
          validEvidenceIndices: [4, 5],
          feedbackMessage: "잘하셨습니다! 여인들의 행동(밥을 줌)과 말투(쯧쯧)가 핵심 근거였습니다.",
          whyOptions: [
            "등을 밀어 밥을 주는 행동 때문에",
            "'불쌍하다'고 말하는 대사 때문에",
            "동네 사람들의 전체적인 분위기 때문에"
          ],
        ),
        Task(
          id: 't2',
          typeTag: "어휘 추론",
          question: "'거둠거둠'의 문맥적 의미로 가장 적절한 것은?",
          options: ["허둥지둥 급하게", "조심스럽고 단정하게", "거칠고 투박하게", "느릿느릿 여유롭게"],
          correctOptionIndex: 1,
          highlightSentenceIndex: 1,
          validEvidenceIndices: [0],
          feedbackMessage: "네! '심청이 거동 봐라'라는 문맥과 연결해보면 단정한 태도를 알 수 있습니다.",
          whyOptions: [
            "'거동 봐라'라는 앞 문맥 때문에",
            "치마 자락을 안는 동작 묘사 때문에",
            "허리띠를 매는 순서 때문에"
          ],
        ),
        Task(
          id: 't3',
          typeTag: "인물 심리",
          question: "심청이 밥을 빌러 나갈 때의 심정으로 적절하지 않은 것은?",
          options: ["비참함", "담담함", "부끄러움", "분노"],
          correctOptionIndex: 3,
          highlightSentenceIndex: 6,
          validEvidenceIndices: [6],
          feedbackMessage: "맞습니다. 슬픔은 느끼지만(아니 슬플소냐), 누군가에게 화를 내는 상황은 아닙니다.",
          whyOptions: [
            "'아니 슬플소냐'라는 독백 때문에",
            "누구를 탓하는 표현이 없어서",
            "밥을 빌러 가는 상황 자체 때문에"
          ],
        ),
        Task(
          id: 't4',
          typeTag: "핵심 파악",
          question: "이 글 전체에서 드러나는 심청의 성격은?",
          options: ["효심이 깊고 차분함", "적극적이고 활달함", "소극적이고 비관적", "계산적이고 현실적"],
          correctOptionIndex: 0,
          highlightSentenceIndex: 11,
          validEvidenceIndices: [8, 11],
          feedbackMessage: "정확합니다. 아버지의 밥을 먼저 챙기는 모습에서 깊은 효심을 알 수 있습니다.",
          whyOptions: [
            "아버지 밥을 걱정하는 대사 때문에",
            "동네 사람들의 칭찬 때문에",
            "차분하게 대답하는 태도 때문에"
          ],
        ),
      ];
    }

    return [];
  }

  @override
  Future<void> submitResult(String workId, List<UserLog> logs) async {
    // 1초 동안 '저장 중...' 인 척 기다림
    await Future.delayed(const Duration(seconds: 1));
    
    // 개발자 확인용 로그 출력
    print("✅ [서버 전송 완료] 작품ID: $workId, 총 ${logs.length}개의 기록 저장됨.");
    for (var log in logs) {
      print("- Q: ${log.question} / A: ${log.selectedAnswer}");
    }
  }
}