import 'package:flutter/material.dart';

import 'app/app_session_controller.dart';
import 'screens/app_shell.dart';
import 'screens/login_screen.dart';

class AppConfig {
  AppConfig._();

  static const String baseHost = String.fromEnvironment(
    'BASE_HOST',
    defaultValue: 'http://10.0.2.2:5011',
  );

  // Mobile istemcide secret varsayilan olarak gomulu tutulmaz.
  static const String appSecret = String.fromEnvironment(
    'APP_SECRET',
    defaultValue: '',
  );

  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );

  static String get apiBaseUrl => '$baseHost/api';
  static String get hubBaseUrl => '$baseHost/hubs/parking';
  static String get mapSvgUrl => '$baseHost/maps/kroki.svg';
  static bool get googleSignInEnabled => googleServerClientId.isNotEmpty;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sessionController = AppSessionController();
  await sessionController.restore();
  runApp(BuLocationApp(sessionController: sessionController));
}

class BuLocationApp extends StatelessWidget {
  const BuLocationApp({super.key, required this.sessionController});

  final AppSessionController sessionController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sessionController,
      builder: (context, _) {
        return MaterialApp(
          title: 'BuLocation',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6366F1),
              secondary: Color(0xFF22D3EE),
              surface: Color(0xFFFFFFFF),
              onSurface: Color(0xFF0F172A),
              outline: Color(0xFFCBD5E1),
            ),
            fontFamily: 'SF Pro Display',
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              foregroundColor: Color(0xFF0F172A),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide:
                    const BorderSide(color: Color(0xFF6366F1), width: 1.2),
              ),
            ),
          ),
          home: sessionController.isAuthenticated
              ? AppShell(sessionController: sessionController)
              : LoginScreen(sessionController: sessionController),
        );
      },
    );
  }
}
