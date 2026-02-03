import 'package:flutter/material.dart';

// [데이터 모델] 유저의 사고 기록 (SessionScreen에서 전달받음)
class UserLog {
  final String taskType;      // 예: 상황 파악
  final String question;      // 문제 질문
  final String selectedAnswer; // 내가 고른 답
  final String evidenceText;  // 내가 선택한 근거 (대표 문장)
  final String whyReason;     // 내가 선택한 이유

  UserLog({
    required this.taskType,
    required this.question,
    required this.selectedAnswer,
    required this.evidenceText,
    required this.whyReason,
  });
}

class ResultScreen extends StatelessWidget {
  final String title;
  final List<UserLog> userLogs; // [핵심] 기록 데이터

  const ResultScreen({
    super.key, 
    required this.title,
    required this.userLogs, // 필수 입력
  });

  @override
  Widget build(BuildContext context) {
    const bgPaperColor = Color(0xFFFDFBF7);
    const primaryColor = Color(0xFF3E2723);

    return Scaffold(
      backgroundColor: bgPaperColor,
      appBar: AppBar(
        backgroundColor: bgPaperColor,
        elevation: 0,
        centerTitle: true,
        title: const Text("오늘의 사고 기록", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        leading: Container(), // 뒤로가기 숨김 (완료했으므로)
      ),
      body: Column(
        children: [
          // 상단 메시지
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                const Icon(Icons.verified, size: 40, color: Color(0xFF8D6E63)),
                const SizedBox(height: 8),
                Text(
                  "총 ${userLogs.length}개의 근거를 발견하고\n논리적으로 연결했습니다.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.4),
                ),
              ],
            ),
          ),

          // [메인] 사고 기록 리스트 (포트폴리오)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: userLogs.length,
              itemBuilder: (context, index) {
                return _buildLogCard(userLogs[index], index + 1);
              },
            ),
          ),

          // 하단 버튼
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('서재로 돌아가기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // [위젯] 사고 기록 카드
  Widget _buildLogCard(UserLog log, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 태그 & 질문
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEBE9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Q${index}. ${log.taskType}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  log.question,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF3E2723), height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey[100], height: 1),
          const SizedBox(height: 16),

          // 2. 내가 찾은 근거 (핵심)
          const Text("내가 발견한 근거", style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDE7), // 연한 노랑 (형광펜 느낌)
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFF59D)),
            ),
            child: Text(
              "❝ ${log.evidenceText} ❞",
              style: const TextStyle(fontSize: 14, color: Color(0xFF424242), height: 1.4, fontFamily: 'Pretendard', fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: 16),

          // 3. 나의 사고 과정 (Why + Answer)
          const Text("나의 사고 연결", style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 14, color: Color(0xFF3E2723), height: 1.5),
              children: [
                TextSpan(
                  text: "${log.whyReason} ",
                  style: const TextStyle(fontWeight: FontWeight.bold, backgroundColor: Color(0xFFEFEBE9)),
                ),
                const TextSpan(text: "그렇기에 "),
                TextSpan(
                  text: "[${log.selectedAnswer}]",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
                ),
                const TextSpan(text: " 이라고 판단했습니다."),
              ],
            ),
          ),
        ],
      ),
    );
  }
}