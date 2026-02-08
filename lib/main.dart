import 'package:flutter/material.dart';
import 'screens/landing_screen.dart';
import 'screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // [수정] Firebase 초기화 시 옵션 직접 입력
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      // 1. Firebase 콘솔에서 복사한 '웹 API 키'를 여기에 붙여넣으세요
      apiKey: "AIzaSyArhgKS-n0J1RDwOvmv4ufZLbMCAeUUN84", 
      
      // 2. Firebase 콘솔에서 복사한 '앱 ID'를 여기에 붙여넣으세요
      appId: "1:84537953160:web:a31921d1e2f92958dc883d", 
      
      // 아래 2개는 제가 찾아서 이미 채워뒀습니다.
      messagingSenderId: "84537953160", 
      projectId: "knu-team-03",
    ),
  );

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
        fontFamily: 'Pretendard',
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5D4037),
          primary: const Color(0xFF5D4037),
          secondary: const Color(0xFFD7CCC8),
          background: Colors.white,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF3E2723),
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      // [중요] 로그인 여부에 따라 첫 화면 결정 로직이 있으면 좋지만, 
      // 일단 LandingScreen으로 시작해서 로그인하게 유도
      home: const LandingScreen(),
    );
  }
}