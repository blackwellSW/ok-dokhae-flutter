import 'package:flutter/material.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // [배경] 리액트의 from-[#F5F5F7] via-[#F5F5F7] to-primary-100(#E0EEFF) 구현
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F5F7), // 위쪽
              Color(0xFFF5F5F7), // 중간
              Color(0xFFE0EEFF), // 아래쪽 (primary-100)
            ],
          ),
        ),
        // [반응형] 웹에서 너무 퍼지지 않게 가운데 정렬
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800), // 웹에서 보기 좋게 폭 제한
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 1. 상단 네비게이션 (로고 + 로그인 버튼)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // [여기가 질문하신 로고 부분!] Row로 묶으면 옆에 나옵니다.
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/logo.png', // PNG 로고
                              height: 32, // 높이 조절 (웹 8rem -> 약 32px)
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 8), // 로고와 텍스트 사이 간격
                            const Text(
                              'OK-DOKHAE',
                              style: TextStyle(
                                fontFamily: 'Pretendard', // 폰트 적용
                                fontSize: 22,
                                fontWeight: FontWeight.w900, // ExtraBold
                                color: Color(0xFF0F172A), // 진한 네이비
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        // 우측 상단 Login 버튼 (타원형 테두리)
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 2. 메인 히어로 섹션 (가운데 텍스트 + 버튼)
                    Column(
                      mainAxisSize: MainAxisSize.min, // 내용물 크기만큼만 차지
                      children: [
                        const Text(
                          'AI로 완성하는 완벽한 논리 독해',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 42, // 제목 크기 키움
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                            color: Color(0xFF0F172A),
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '당신의 독해 파트너 AI가 글의 뼈대를 분석합니다.\n헷갈리는 문장 속에서 명확한 논리를 발견하는 경험을 시작해 보세요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16,
                            color: Colors.grey[600], // text-gray-400 느낌
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 48), // 텍스트와 버튼 사이 간격

                        // 중앙 "시작하기" 버튼 (스크린샷과 동일한 스타일)
                        OutlinedButton(
                          onPressed: () {
                            // 버튼 클릭 시 동작
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.transparent, // 배경 투명
                            side: const BorderSide(color: Color(0xFF0F172A), width: 1.5), // 검정 테두리
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50), // 완전 둥근 알약 모양
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                          ),
                          child: const Text(
                            '시작하기',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A), // 글자색 검정
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 3. 하단 여백용 (화면 균형 맞추기)
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}