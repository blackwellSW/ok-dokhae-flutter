import 'package:flutter/material.dart';
import 'screens/landing_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OK독해',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // [CSS] --font-sans: "Pretendard" (폰트는 나중에 assets에 추가해야 적용됨)
        fontFamily: 'Pretendard', 
        
        // [CSS] --bg: white
        scaffoldBackgroundColor: Colors.white,

        // [CSS] --color-primary-500: #4B8BFF
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4B8BFF), // 메인 컬러
          primary: const Color(0xFF4B8BFF),
          background: Colors.white,
        ),

        // 앱바 스타일 통일
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F172A), // --fg 색상
          elevation: 0, // 그림자 제거 (요즘 스타일)
        ),
        
        useMaterial3: true,
      ),
      home: const LandingScreen(), // 첫 화면 연결
    );
  }
}