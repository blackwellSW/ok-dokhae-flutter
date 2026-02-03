import 'package:flutter/material.dart';
import 'result_screen.dart';
import '../models/session_task.dart';
import '../services/api_service.dart';      // 서비스
import '../services/mock_api_service.dart'; // 구현체

class SessionScreen extends StatefulWidget {
  final String id;    // 작품 ID
  final String title; // 작품 제목

  const SessionScreen({
    super.key, 
    required this.id, 
    required this.title
  });

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

enum SessionStep { pickingAnswer, pickingEvidence, feedbackAndWhy }

class _SessionScreenState extends State<SessionScreen> {
  // [서비스 & 데이터]
  late ApiService _apiService;
  late Future<List<dynamic>> _sessionDataFuture; // 지문과 문제를 한 번에 기다림

  // [상태 변수]
  int _currentTaskIndex = 0;
  SessionStep _currentStep = SessionStep.pickingAnswer;
  final List<UserLog> _userLogs = [];

  // [입력 값]
  int? _selectedOptionIndex;
  final Set<int> _selectedEvidenceIndices = {};
  int? _selectedWhyIndex;

  @override
  void initState() {
    super.initState();
    _apiService = MockApiService();
    // 지문(0번)과 문제(1번)를 동시에 요청해서 기다림
    _sessionDataFuture = Future.wait([
      _apiService.getWorkContent(widget.id),
      _apiService.getTasks(widget.id),
    ]);
  }

  // [수정] 서버 제출 기능이 포함된 저장 및 이동 로직
  Future<void> _saveAndNext(List<Task> tasks, List<String> sentences) async {
    final currentTask = tasks[_currentTaskIndex];
    
    // 1. 로그 데이터 생성
    String evidenceSummary = "";
    if (_selectedEvidenceIndices.isNotEmpty) {
      int firstIndex = _selectedEvidenceIndices.first;
      if (firstIndex < sentences.length) {
        evidenceSummary = sentences[firstIndex].trim();
        if (_selectedEvidenceIndices.length > 1) {
          evidenceSummary += " (외 ${_selectedEvidenceIndices.length - 1}문장)";
        }
      }
    } else {
      evidenceSummary = "(선택한 근거 없음)";
    }

    final log = UserLog(
      taskType: currentTask.typeTag,
      question: currentTask.question,
      selectedAnswer: currentTask.options[_selectedOptionIndex ?? 0],
      evidenceText: evidenceSummary,
      whyReason: currentTask.whyOptions[_selectedWhyIndex ?? 0],
    );

    _userLogs.add(log);

    // 2. 다음 문제로 이동 or 서버 제출
    if (_currentTaskIndex < tasks.length - 1) {
      // 다음 문제로
      setState(() {
        _currentTaskIndex++;
        _currentStep = SessionStep.pickingAnswer;
        _selectedOptionIndex = null;
        _selectedEvidenceIndices.clear();
        _selectedWhyIndex = null;
      });
    } else {
      // [핵심] 마지막 문제: 서버 제출 프로세스 시작
      
      // A. 로딩 다이얼로그 띄우기
      showDialog(
        context: context,
        barrierDismissible: false, // 터치로 못 닫게 함
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );

      try {
        // B. 서버에 데이터 전송 (1초 대기)
        await _apiService.submitResult(widget.id, _userLogs);

        // C. 로딩 닫기
        if (mounted) Navigator.pop(context); 

        // D. 결과 화면으로 이동
        if (mounted) {
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
      } catch (e) {
        // 에러 처리 (실패 시)
        if (mounted) Navigator.pop(context); // 로딩 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("저장 실패: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _sessionDataFuture,
        builder: (context, snapshot) {
          // 1. 로딩 중
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }
          // 2. 에러 발생
          if (snapshot.hasError) {
            return Center(child: Text("데이터를 불러오지 못했습니다.\n${snapshot.error}"));
          }
          // 3. 데이터 없음
          if (!snapshot.hasData) {
            return const Center(child: Text("학습 데이터가 없습니다."));
          }

          // [데이터 언패킹] Future.wait 순서대로 꺼냄
          final sentences = snapshot.data![0] as List<String>;
          final tasks = snapshot.data![1] as List<Task>;

          if (tasks.isEmpty) {
            return const Center(child: Text("준비된 문제가 없습니다."));
          }

          final currentTask = tasks[_currentTaskIndex];

          return Column(
            children: [
               // 진행도 표시
               Container(
                 alignment: Alignment.centerRight,
                 padding: const EdgeInsets.only(right: 24, bottom: 10),
                 child: Text('${_currentTaskIndex + 1} / ${tasks.length}', style: const TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 12)),
               ),

              // 지문 영역 (스크롤)
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
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
                        children: List.generate(sentences.length, (index) {
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
                                sentences[index],
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
              
              // 하단 인터랙션 영역
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
                        if (_currentStep == SessionStep.feedbackAndWhy) _buildStep3(currentTask, primaryColor, tasks, sentences),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStep1(Task task, Color primaryColor) {
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

  Widget _buildStep3(Task task, Color primaryColor, List<Task> tasks, List<String> sentences) {
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
        Wrap(
          spacing: 8, 
          runSpacing: 8, 
          children: List.generate(task.whyOptions.length, (index) => _buildWhyChip(index, task.whyOptions[index]))
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: _selectedWhyIndex != null ? () => _saveAndNext(tasks, sentences) : null,
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: Text(_currentTaskIndex < tasks.length - 1 ? '다음 문제로' : '학습 결과 보기', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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