import 'package:flutter/material.dart';
import 'screens/landing_screen.dart';
import 'screens/home_screen.dart'; // [필수] 홈 화면 파일 import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OK독해',
      debugShowCheckedModeBanner: false, // 오른쪽 위 'Debug' 리본 제거
      
      // [테마 설정] 고전문학에 어울리는 '모던 한옥' 스타일
      theme: ThemeData(
        fontFamily: 'Pretendard', // 폰트 설정
        
        // 기본 배경색 (깨끗한 흰색/종이 질감)
        scaffoldBackgroundColor: Colors.white,

        // 메인 색상 팔레트 (갈색 계열)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5D4037), // 짙은 고동색 (Primary)
          primary: const Color(0xFF5D4037),
          secondary: const Color(0xFFD7CCC8), // 연한 갈색 (Secondary)
          background: Colors.white,
          surface: Colors.white,
        ),

        // 상단 앱바 스타일 통일
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF3E2723), // 제목 글씨색 (진한 갈색)
          elevation: 0, // 그림자 없음 (플랫 디자인)
          scrolledUnderElevation: 0, // 스크롤 시 색상 변경 방지
        ),
        
        useMaterial3: true,
      ),

      // [화면 이동 경로 설정]
      initialRoute: '/', // 앱이 켜지면 '/' 주소로 시작
      routes: {
        '/': (context) => const LandingScreen(), // 랜딩(온보딩) 페이지
        '/home': (context) => const HomeScreen(), // 서재(메인) 페이지
      },
    );
  }
}