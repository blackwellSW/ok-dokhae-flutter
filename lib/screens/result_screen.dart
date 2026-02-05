import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final String title;

  const ResultScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    // [Mock Data] 백엔드 API 명세에 맞춰 구조화된 데이터
    final Map<String, dynamic> analysisResult = {
      // 1. 수치(상위 n%) 제거 -> 정성적 요약 및 태그 강조
      "summary": "단서들을 논리적으로 연결하여\n이면의 뜻을 읽어내는 힘이 훌륭해요.",
      "tags": ["#근거기반", "#심층분석가", "#맥락이해"], 
      
      // 2. 점수(Score) + 이유(Reason) 구조
      "scores": [
        {"label": "문해력", "score": 0.9, "label_text": "탁월함", "reason": "지문의 핵심 어휘와 문장 구조를 정확히 파악함"},
        {"label": "추론력", "score": 0.85, "label_text": "좋음", "reason": "드러나지 않은 화자의 의도를 문맥을 통해 도출함"},
        {"label": "근거활용", "score": 0.95, "label_text": "탁월함", "reason": "본문 문장을 3회 이상 직접 인용하여 주장을 뒷받침함"}, // 핵심 포인트
        {"label": "비판적사고", "score": 0.7, "label_text": "보통", "reason": "주장에 대한 반론이나 다른 관점의 대안 제시가 부족함"},
      ],
      
      // 3. 사고 흐름 + 인용문(Quote) 직접 노출
      "flow_analysis": [
        {
          "step": "단서 발견", 
          "status": "perfect", 
          "comment": "화자의 감정이 드러난 핵심 단어를 놓치지 않고 포착했습니다.",
          "quote": "...아니 슬플소냐..." // 증거 자료
        },
        {
          "step": "논리 연결", 
          "status": "good", 
          "comment": "반어법적 표현을 '슬픔'이라는 감정과 논리적으로 잘 연결했습니다.",
          "quote": "눈물이 비 오듯 하여"
        },
        {
          "step": "배경 확장", 
          "status": "weak", 
          "comment": "당시의 시대적 배경(효 사상)까지 사고를 확장했다면 분석이 더 풍부했을 거예요.",
          "quote": null // 근거 없음 (약점)
        },
      ],
      
      // 4. 말투 수정 (기계적 평가 -> 튜터의 코칭)
      "prescription": "지금은 본문에서 단서를 찾는 능력이 아주 좋아요. 다음번에는 '왜 작가가 굳이 이 단어를 썼을까?'라고 작가의 숨은 의도를 한 번 더 파고들어 보세요."
    };

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("진단 리포트", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          // 홈으로 돌아가기
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. 헤더 (종합 진단)
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
              child: Column(
                children: [
                  // 태그 (Badge)
                  Wrap(
                    spacing: 8,
                    children: (analysisResult['tags'] as List).map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        // [색상 변경] 연한 갈색 -> 연한 녹색 (0xFFE8F5E9)
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(20),
                        // [색상 변경] 갈색 테두리 -> 연한 녹색 테두리 (0xFFC8E6C9)
                        border: Border.all(color: const Color(0xFFC8E6C9)),
                      ),
                      // [색상 변경] 갈색 텍스트 -> 진한 녹색 텍스트 (0xFF1B5E20)
                      child: Text(tag, style: const TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold, fontSize: 13)),
                    )).toList(),
                  ),
                  const SizedBox(height: 20),
                  // 요약 멘트
                  Text(
                    analysisResult['summary'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.4, color: Color(0xFF263238)),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),

            // 2. 역량 분석 (점수 + 근거)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("영역별 강점 및 약점", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text("이번 세션에서 관찰된 사고 패턴을 분석했습니다.", style: TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 24),
                  
                  ...analysisResult['scores'].map<Widget>((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 라벨, 바, 등급 텍스트
                          Row(
                            children: [
                              SizedBox(width: 70, child: Text(item['label'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87))),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: item['score'],
                                    minHeight: 8,
                                    backgroundColor: Colors.grey[100],
                                    color: _getScoreColor(item['score']),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(item['label_text'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: _getScoreColor(item['score']))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // [핵심] 근거 문구 (Reason) - 화살표 아이콘과 함께
                          Padding(
                            padding: const EdgeInsets.only(left: 70), 
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.subdirectory_arrow_right, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    item['reason'], 
                                    style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 3. 사고 흐름 분석 (인용문 포함)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      // [색상 변경] 갈색 -> 메인 녹색 (0xFF02B152)
                      Icon(Icons.timeline, color: Color(0xFF02B152)),
                      SizedBox(width: 8),
                      Text("사고 흐름 상세 진단", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  ...analysisResult['flow_analysis'].map<Widget>((step) {
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Column(
                            children: [
                              _buildStepIcon(step['status']),
                              Expanded(child: Container(width: 2, color: Colors.grey[200])),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 30.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 단계명
                                  Text(step['step'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                                  const SizedBox(height: 4),
                                  // 코멘트
                                  Text(step['comment'], style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black54)),
                                  
                                  // [핵심] 인용문(Evidence) 카드
                                  if (step['quote'] != null)
                                    Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF5F5F5),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // [색상 변경] 갈색 -> 메인 녹색 (0xFF02B152)
                                          const Icon(Icons.format_quote, size: 14, color: Color(0xFF02B152)),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              step['quote'], 
                                              // [색상 변경] 갈색 텍스트 -> 진한 녹색 텍스트 (0xFF1B5E20)
                                              style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Color(0xFF1B5E20)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 4. 튜터의 맞춤 처방
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("💊 튜터의 맞춤 처방", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFE0B2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lightbulb_outline, color: Color(0xFFF57F17)),
                            SizedBox(width: 8),
                            Text("이렇게 해보면 어때요?", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          analysisResult['prescription'],
                          style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFFBF360C)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 5. 하단 버튼 (CTA)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // 홈 화면으로 스택 초기화하며 이동
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("리포트가 저장되었습니다.")));
                  },
                  style: ElevatedButton.styleFrom(
                    // [색상 변경] 갈색 -> 메인 녹색 (0xFF02B152)
                    backgroundColor: const Color(0xFF02B152),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("리포트 저장 및 종료", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 0.9) return const Color(0xFF2E7D32);
    if (score >= 0.7) return const Color(0xFFF9A825);
    return const Color(0xFFC62828);
  }

  Widget _buildStepIcon(String status) {
    IconData icon;
    Color color;

    switch (status) {
      case 'perfect':
        icon = Icons.check_circle;
        color = const Color(0xFF2E7D32);
        break;
      case 'good':
        icon = Icons.check_circle_outline;
        color = const Color(0xFF1976D2);
        break;
      case 'weak':
      default:
        icon = Icons.error_outline;
        color = const Color(0xFFF57F17);
        break;
    }

    return Container(
      color: Colors.white,
      child: Icon(icon, color: color, size: 24),
    );
  }
}