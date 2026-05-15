import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';
import 'widgets/app_shell.dart';

// DayRescue 진입점.
// "결정은 사용자가 하고, AI는 무너진 계획을 실행 가능한 크기로 줄인다."

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SharedPreferences를 앱 시작 전에 미리 로드해서
  // 첫 화면이 빌드될 때 누적 RP를 즉시 읽을 수 있게 한다.
  await StorageService.warmUp();
  runApp(const DayRescueApp());
}

class DayRescueApp extends StatelessWidget {
  const DayRescueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DayRescue',
      debugShowCheckedModeBanner: false,
      builder: (context, child) => AppShell(child: child ?? const SizedBox()),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFAF9FC),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAF9FC),
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: false,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
