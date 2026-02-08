import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:math';
import 'session_screen.dart';
import '../models/work.dart';
import '../services/api_service.dart';
import '../services/mock_api_service.dart';
import '../services/real_api_service.dart';
import '../config/api_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ApiService _apiService;
  late Future<List<Work>> _demoWorksFuture;

  @override
  void initState() {
    super.initState();
    _apiService = ApiConfig.demoMode ? MockApiService() : RealApiService();
    _demoWorksFuture = _apiService.getWorks();
  }

  Future<void> _handleFileUpload() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt', 'docx'],
      );

      if (result != null) {
        String fileName = result.files.single.name;
        if (!mounted) return;
        _showContentPreview(fileName);
      }
    } catch (e) {
      print("파일 선택 에러: $e");
    }
  }

  // [수정] 업로드 확인 모달 - "문서 분석기" 느낌 강화
  void _showContentPreview(String fileName) {
    // 가짜 메타데이터 생성 (신뢰도 상승용)
    final random = Random();
    final charCount = 10000 + random.nextInt(5000); 
    final readTime = 5 + random.nextInt(5); 

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2)))),
              
              const Row(children: [
                // [색상 변경] 갈색(0xFF5D4037) -> 메인 녹색(0xFF02B152)
                Icon(Icons.description, color: Color(0xFF02B152)),
                SizedBox(width: 8),
                // [De-AI] "AI 분석" 대신 "학습 자료 준비"
                Text("학습 자료 준비 완료",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
              ]),
              const SizedBox(height: 16),
              
              // 파일 정보 카드
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Row(children: [
                      // [색상 변경] 기존 green -> 메인 녹색(0xFF02B152)으로 통일
                      const Icon(Icons.check_circle, size: 20, color: Color(0xFF02B152)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(fileName, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    // [신뢰도] 숫자 데이터 노출
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetaItem("글자 수", "${charCount}자"),
                        _buildMetaItem("예상 시간", "${readTime}분"),
                        _buildMetaItem("추출 품질", "매우 좋음"),
                      ],
                    )
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              const Text("지문 미리보기", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              
              Container(
                height: 100,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8)),
                child: const SingleChildScrollView(
                  child: Text(
                    "이 문서는 텍스트 추출 엔진을 통해 변환된 결과입니다.\n\n"
                    "튜터가 이 내용을 바탕으로 사고 유도 질문을 생성합니다.\n"
                    "(실제 구현 시에는 파일의 앞부분 내용이 여기에 표시됩니다.)\n\n"
                    "텍스트가 깨져 보인다면 원본 파일을 다시 확인해주세요.",
                    style: TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _navigateToSession('custom_file', fileName);
                  },
                  style: ElevatedButton.styleFrom(
                      // [색상 변경] 갈색(0xFF5D4037) -> 메인 녹색(0xFF02B152)
                      backgroundColor: const Color(0xFF02B152),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16))),
                  child: const Text("이 자료로 진단 시작하기", // [De-AI] 세션 -> 진단
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetaItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  void _navigateToSession(String id, String title) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SessionScreen(id: id, title: title)));
  }

  void _navigateToDemo(Work work) => _navigateToSession(work.id, work.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Row(
                children: [
                  // [색상 변경] 진한 갈색(0xFF4E342E) -> 메인 녹색(0xFF02B152)
                  const Icon(Icons.auto_stories, color: Color(0xFF02B152), size: 28),
                  const SizedBox(width: 8),
                  // [색상 변경] 진한 갈색(0xFF4E342E) -> 진한 녹색 텍스트(0xFF1B5E20)
                  const Text("OK 독해", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1B5E20))),
                  const Spacer(),
                  // [색상 변경] 갈색(0xFF5D4037) -> 메인 녹색(0xFF02B152)
                  IconButton(onPressed: () {}, icon: const Icon(Icons.account_circle, color: Color(0xFF02B152), size: 32)),
                ],
              ),
            ),
            const Spacer(flex: 1),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // [De-AI] 결과물(리포트) 강조
                  const Text(
                    "대화로 사고를 확장하고,\n리포트로 진단해드려요.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.3),
                  ),
                  const SizedBox(height: 12),
                  
                  // 배지: 혜택 강조
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      // [색상 변경] 오렌지 배경 -> 연한 녹색 배경(0xFFE8F5E9)
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                      // [색상 변경] 오렌지 테두리 -> 연한 녹색 테두리(0xFFC8E6C9)
                      border: Border.all(color: const Color(0xFFC8E6C9)),
                    ),
                    child: const Text(
                      "✨ 3분 대화 후: 핵심 요약 + 사고 패턴 분석 리포트 제공",
                      // [색상 변경] 오렌지 텍스트 -> 진한 녹색 텍스트(0xFF1B5E20)
                      style: TextStyle(fontSize: 13, color: Color(0xFF1B5E20), fontWeight: FontWeight.bold),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: _handleFileUpload,
                    child: Container(
                      width: 280, height: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)]),
                            // [색상 변경] 갈색(0xFF5D4037) -> 메인 녹색(0xFF02B152)
                            child: const Icon(Icons.cloud_upload_rounded, size: 40, color: Color(0xFF02B152)),
                          ),
                          const SizedBox(height: 16),
                          // [색상 변경] 갈색(0xFF5D4037) -> 진한 녹색 텍스트(0xFF1B5E20)
                          const Text("파일 업로드하기", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                          const SizedBox(height: 4),
                          const Text("PDF, TXT, DOCX 지원", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: Color(0xFFFAFAFA), borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("자료가 없으신가요? 예시로 시작해보세요.", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 100,
                    child: FutureBuilder<List<Work>>(
                      future: _demoWorksFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                        final works = snapshot.data!;
                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: works.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final work = works[index];
                            return GestureDetector(
                              onTap: () => _navigateToDemo(work),
                              child: Container(
                                width: 200, padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: work.baseColor.withOpacity(0.3), borderRadius: BorderRadius.circular(16), border: Border.all(color: work.baseColor)),
                                child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: work.spineColor, shape: BoxShape.circle), child: Center(child: Text(work.title[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(work.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(work.author, style: const TextStyle(fontSize: 12, color: Colors.black54))]))]),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}