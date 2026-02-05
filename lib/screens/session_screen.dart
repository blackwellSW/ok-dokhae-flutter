import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import '../services/mock_api_service.dart';
import 'result_screen.dart';

class SessionScreen extends StatefulWidget {
  final String id;
  final String title;

  const SessionScreen({super.key, required this.id, required this.title});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

enum LearningStep { loading, chatting, report }

class _SessionScreenState extends State<SessionScreen> {
  late ApiService _apiService;
  
  LearningStep _currentStep = LearningStep.loading;
  List<String> _content = []; 
  
  final List<Map<String, String>> _chatHistory = [];
  
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String? _attachedFileName;
  
  bool _isContentExpanded = false; 

  @override
  void initState() {
    super.initState();
    _apiService = MockApiService(); 
    _initSession();
  }

  Future<void> _initSession() async {
    setState(() => _currentStep = LearningStep.loading);
    
    final content = await _apiService.getWorkContent(widget.id);
    final firstQuestion = await _apiService.startThinkingSession(widget.id);

    if (!mounted) return;
    setState(() {
      _content = content;
      _chatHistory.add({"role": "ai", "text": firstQuestion});
      _currentStep = LearningStep.chatting;
    });
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt', 'docx'],
      );
      if (result != null) {
        setState(() {
          _attachedFileName = result.files.single.name;
        });
      }
    } catch (e) {
      print("파일 선택 에러: $e");
    }
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty && _attachedFileName == null) return;

    String userMsg = text;
    if (_attachedFileName != null) {
      userMsg = "[파일 첨부: $_attachedFileName]\n$text";
    }

    setState(() {
      _chatHistory.add({"role": "user", "text": userMsg});
      _inputController.clear();
      _attachedFileName = null; 
      _currentStep = LearningStep.loading; 
    });
    _scrollToBottom();

    final response = await _apiService.getGuidance(widget.id, text);

    if (!mounted) return;
    setState(() {
      _chatHistory.add({"role": "ai", "text": response['text']});
      if (response['is_finish'] == true) {
        _currentStep = LearningStep.report; 
      } else {
        _currentStep = LearningStep.chatting;
      }
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // 세션 종료 옵션 (Bottom Sheet)
  void _showExitOptions() {
    showModalBottomSheet(
      context: context, 
      builder: (sheetContext) { 
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("진단을 종료하시겠습니까?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("지금까지의 대화 내용을 바탕으로 분석 리포트를 생성합니다.", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(sheetContext); 
                    
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("분석 리포트를 생성합니다...")));
                    
                    Future.delayed(const Duration(milliseconds: 1500), () {
                      if (!mounted) return;
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => ResultScreen(title: widget.title))
                      );
                    });
                  },
                  // [색상 변경] 갈색 -> 녹색
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF02B152)),
                  child: const Text("네, 리포트 생성하기", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: const Text("아니요, 더 대화할래요", style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEvidenceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  // [색상 변경] 갈색 -> 녹색
                  Icon(Icons.menu_book, color: Color(0xFF02B152)),
                  SizedBox(width: 8),
                  Text("근거 문장 확인", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "\"...아니 슬플소냐. 늘물이 비 오듯 하여...\"",
                      style: TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text("- 3번째 문단", style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1), 
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb, size: 16, color: Color(0xFFF57F17)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "💡 튜터의 노트: 이 문장에서 화자의 감정이 '슬픔'임을 직접적으로 확인할 수 있어요.",
                        style: TextStyle(fontSize: 13, color: Color(0xFFBF360C), height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    // [색상 변경] 갈색 -> 녹색
                    backgroundColor: const Color(0xFF02B152),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("확인", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.black, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
        // 우상단 진단 종료 버튼
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              onPressed: _showExitOptions,
              // [색상 변경] 아이콘: 갈색 -> 녹색
              icon: const Icon(Icons.exit_to_app, size: 18, color: Color(0xFF02B152)),
              // [색상 변경] 텍스트: 갈색 -> 녹색
              label: const Text("진단 종료", style: TextStyle(color: Color(0xFF02B152), fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[50],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: const Color(0xFFFAFAFA),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.edit_note, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                const Text(
                  "실시간 사고 흐름 기록 중", 
                  style: TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text("진단 준비됨", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ],
            ),
          ),

          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _isContentExpanded ? MediaQuery.of(context).size.height * 0.4 : 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: SingleChildScrollView(
              physics: _isContentExpanded ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _isContentExpanded = !_isContentExpanded),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          // [색상 변경] 갈색 -> 녹색
                          const Icon(Icons.description_outlined, size: 18, color: Color(0xFF02B152)),
                          const SizedBox(width: 8),
                          // [색상 변경] 갈색 -> 녹색
                          const Text("지문 본문 보기", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF02B152))),
                          const Spacer(),
                          Text(
                            _isContentExpanded ? "접기" : "펼쳐보기",
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _isContentExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            size: 20,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  if (_isContentExpanded)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                           ..._content.map((sentence) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(sentence, style: const TextStyle(fontSize: 15, height: 1.6)),
                          )),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _chatHistory.length + (_currentStep == LearningStep.loading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _chatHistory.length) {
                          return const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                            ),
                          );
                        }
                        final msg = _chatHistory[index];
                        final isAi = msg['role'] == 'ai';
                        return _buildChatBubble(isAi, msg['text']!);
                      },
                    ),
                  ),
                  _buildBottomArea(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(bool isAi, String text) {
    return Column(
      crossAxisAlignment: isAi ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        if (isAi) 
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 4),
            // [색상 변경] 갈색 -> 녹색
            child: Text("튜터", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF02B152))),
          ),
        
        Container(
          margin: EdgeInsets.only(bottom: isAi ? 4 : 12), 
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          decoration: BoxDecoration(
            // [색상 변경] 사용자 버블 갈색 -> 녹색
            color: isAi ? const Color(0xFFF5F5F5) : const Color(0xFF02B152),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isAi ? const Radius.circular(4) : const Radius.circular(16),
              bottomRight: isAi ? const Radius.circular(16) : const Radius.circular(4),
            ),
          ),
          child: Text(
            text, 
            style: TextStyle(
              fontSize: 15, 
              height: 1.4, 
              color: isAi ? Colors.black87 : Colors.white
            )
          ),
        ),

        if (isAi)
          Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 4),
            child: GestureDetector(
              onTap: _showEvidenceSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.format_quote, size: 12, color: Colors.grey),
                    SizedBox(width: 4),
                    Text("근거로 쓴 문장 보기", style: TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomArea() {
    if (_currentStep == LearningStep.report) {
      return Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("분석 리포트 화면으로 이동합니다.")));
          },
          icon: const Icon(Icons.assessment, color: Colors.white),
          label: const Text("최종 진단 리포트 확인", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            // [색상 변경] 갈색 -> 녹색
            backgroundColor: const Color(0xFF02B152),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          if (_attachedFileName != null)
             Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.only(bottom: 8), child: Chip(label: Text(_attachedFileName!), onDeleted: () => setState(() => _attachedFileName = null)))),
          
          Row(
            children: [
              IconButton(onPressed: _pickFile, icon: const Icon(Icons.attach_file, color: Colors.grey)),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: _inputController,
                  decoration: const InputDecoration(hintText: "답변을 입력하세요...", border: InputBorder.none, isDense: true),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              // [색상 변경] 전송 아이콘: 갈색 -> 녹색
              IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send, color: Color(0xFF02B152))),
            ],
          ),
        ],
      ),
    );
  }
}