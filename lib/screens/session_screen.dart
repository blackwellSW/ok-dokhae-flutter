import 'package:flutter/material.dart';
import 'result_screen.dart'; // ResultScreen import 확인

class SessionScreen extends StatefulWidget {
  final String title;

  const SessionScreen({
    super.key, 
    required this.title
  });

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

enum SessionStep { pickingAnswer, pickingEvidence, feedbackAndWhy }

// [데이터 모델 업그레이드] 문제별로 Why 선택지를 다르게 갖도록 수정
class TaskData {
  final String typeTag;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final int highlightSentenceIndex;
  final List<int> validEvidenceIndices;
  final String feedbackMessage;
  final List<String> whyOptions; // [추가] 문제별 맞춤 Why 선택지

  TaskData({
    required this.typeTag,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.highlightSentenceIndex,
    required this.validEvidenceIndices,
    required this.feedbackMessage,
    required this.whyOptions, // 필수 항목으로 추가
  });
}

class _SessionScreenState extends State<SessionScreen> {
  // [상태 변수]
  int _currentTaskIndex = 0;
  SessionStep _currentStep = SessionStep.pickingAnswer;
  
  // [로그 저장소]
  final List<UserLog> _userLogs = [];

  // [입력 값]
  int? _selectedOptionIndex;
  final Set<int> _selectedEvidenceIndices = {};
  int? _selectedWhyIndex;

  // [데이터] 지문 (그대로 유지)
  final List<String> _sentences = [
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

  // [데이터] 4문항 (Why 옵션을 문제마다 다르게 설정!)
  final List<TaskData> _tasks = [
    TaskData(
      typeTag: "상황 파악",
      question: "노란색 구절에서 '동네 여인들'이 심청에게 느끼는 주된 감정은?",
      options: ["질투와 시기심", "안타까움과 연민", "무관심과 냉소", "반가움과 환대"],
      correctOptionIndex: 1,
      highlightSentenceIndex: 2,
      validEvidenceIndices: [4, 5],
      feedbackMessage: "잘하셨습니다! 여인들의 행동(밥을 줌)과 말투(쯧쯧)가 핵심 근거였습니다.",
      whyOptions: [ // [변경] 구체적인 단서 기반 옵션
        "등을 밀어 밥을 주는 행동 때문에",
        "'불쌍하다'고 말하는 대사 때문에",
        "동네 사람들의 전체적인 분위기 때문에"
      ],
    ),
    TaskData(
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
    TaskData(
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
    TaskData(
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

  // [로직] 기록 저장 및 다음 단계 이동
  void _saveAndNext() {
    final currentTask = _tasks[_currentTaskIndex];
    
    // 근거 요약 텍스트 생성
    String evidenceSummary = "";
    if (_selectedEvidenceIndices.isNotEmpty) {
      int firstIndex = _selectedEvidenceIndices.first;
      evidenceSummary = _sentences[firstIndex].trim();
      if (_selectedEvidenceIndices.length > 1) {
        evidenceSummary += " (외 ${_selectedEvidenceIndices.length - 1}문장)";
      }
    } else {
      evidenceSummary = "(선택한 근거 없음)";
    }

    final log = UserLog(
      taskType: currentTask.typeTag,
      question: currentTask.question,
      selectedAnswer: currentTask.options[_selectedOptionIndex ?? 0],
      evidenceText: evidenceSummary,
      whyReason: currentTask.whyOptions[_selectedWhyIndex ?? 0], // [변경] 현재 문제의 옵션에서 가져옴
    );

    _userLogs.add(log);

    if (_currentTaskIndex < _tasks.length - 1) {
      setState(() {
        _currentTaskIndex++;
        _currentStep = SessionStep.pickingAnswer;
        _selectedOptionIndex = null;
        _selectedEvidenceIndices.clear();
        _selectedWhyIndex = null;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            title: widget.title,
            userLogs: _userLogs,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTask = _tasks[_currentTaskIndex];
    const bgPaperColor = Color(0xFFFDFBF7); 
    const primaryColor = Color(0xFF3E2723); 
    const accentColor = Color(0xFF8D6E63);
    const highlightColor = Color(0xFFFFF9C4); 
    const selectionColor = Color(0xFFC8E6C9);

    return Scaffold(
      backgroundColor: bgPaperColor,
      appBar: AppBar(
        backgroundColor: bgPaperColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.title, style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text('${_currentTaskIndex + 1} / ${_tasks.length}', style: const TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
      body: Column(
        children: [
          // 지문 영역
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 16, color: Colors.grey),
                      label: const Text('이전 문맥 더 보기 (+10문장)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    children: List.generate(_sentences.length, (index) {
                      final isTarget = index == currentTask.highlightSentenceIndex;
                      final isSelected = _selectedEvidenceIndices.contains(index);
                      final isTappable = _currentStep == SessionStep.pickingEvidence;

                      return GestureDetector(
                        onTap: isTappable ? () {
                          setState(() {
                            if (isSelected) _selectedEvidenceIndices.remove(index);
                            else _selectedEvidenceIndices.add(index);
                          });
                        } : null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? selectionColor : (isTarget ? highlightColor : Colors.transparent),
                            borderRadius: BorderRadius.circular(4),
                            border: isSelected ? Border.all(color: Colors.green, width: 1) : null,
                          ),
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                          child: Text(
                            _sentences[index],
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 17,
                              height: 1.6,
                              color: isTappable && !isSelected ? Colors.black87 : const Color(0xFF424242),
                              fontWeight: isTarget || isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          
          // 코치 패널
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -5))],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_currentStep == SessionStep.pickingAnswer) _buildStep1(currentTask, primaryColor),
                    if (_currentStep == SessionStep.pickingEvidence) _buildStep2(primaryColor),
                    if (_currentStep == SessionStep.feedbackAndWhy) _buildStep3(currentTask, primaryColor),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1(TaskData task, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFFEFEBE9), borderRadius: BorderRadius.circular(8)),
          child: Text(task.typeTag, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
        ),
        const SizedBox(height: 16),
        Text(task.question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723), height: 1.3)),
        const SizedBox(height: 24),
        ...List.generate(task.options.length, (index) => Padding(padding: const EdgeInsets.only(bottom: 8.0), child: _buildOptionButton(index, task.options[index]))),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: _selectedOptionIndex != null ? () => setState(() => _currentStep = SessionStep.pickingEvidence) : null,
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), disabledBackgroundColor: Colors.grey[300]),
            child: const Text('근거 찾으러 가기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [const Icon(Icons.touch_app_rounded, color: Colors.green, size: 20), const SizedBox(width: 8), Text('지문 탭 모드 활성화됨', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green[700]))]),
        const SizedBox(height: 12),
        const Text("선택한 답의 근거가 되는 문장을\n지문에서 직접 눌러주세요.", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723), height: 1.4)),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: _selectedEvidenceIndices.isNotEmpty ? () => setState(() => _currentStep = SessionStep.feedbackAndWhy) : null,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600], foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: Text('선택 완료 (${_selectedEvidenceIndices.length}개)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3(TaskData task, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
          child: Row(children: [const Icon(Icons.check_circle, color: Colors.green), const SizedBox(width: 12), Expanded(child: Text(task.feedbackMessage, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))))]),
        ),
        const SizedBox(height: 20),
        const Text("마지막으로, 왜 이 근거가 답이 된다고 생각했나요?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
        const SizedBox(height: 16),
        // [수정] 문제별 Why 옵션 렌더링
        Wrap(
          spacing: 8, 
          runSpacing: 8, 
          children: List.generate(task.whyOptions.length, (index) => _buildWhyChip(index, task.whyOptions[index]))
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: _selectedWhyIndex != null ? _saveAndNext : null,
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: Text(_currentTaskIndex < _tasks.length - 1 ? '다음 문제로' : '학습 결과 보기', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton(int index, String text) {
    final isSelected = _selectedOptionIndex == index;
    return SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => setState(() => _selectedOptionIndex = index), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20), backgroundColor: isSelected ? const Color(0xFFEFEBE9) : Colors.transparent, side: BorderSide(color: isSelected ? const Color(0xFF8D6E63) : Colors.grey.shade300, width: isSelected ? 2 : 1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), alignment: Alignment.centerLeft), child: Text(text, style: TextStyle(fontSize: 15, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? const Color(0xFF3E2723) : const Color(0xFF424242)))));
  }

  Widget _buildWhyChip(int index, String text) {
    final isSelected = _selectedWhyIndex == index;
    return ChoiceChip(label: Text(text), selected: isSelected, onSelected: (bool selected) => setState(() => _selectedWhyIndex = selected ? index : null), selectedColor: const Color(0xFFD7CCC8), backgroundColor: Colors.white, labelStyle: TextStyle(color: isSelected ? Colors.black87 : Colors.grey[600], fontWeight: isSelected ? FontWeight.bold : FontWeight.normal), side: BorderSide(color: Colors.grey.shade300));
  }
}