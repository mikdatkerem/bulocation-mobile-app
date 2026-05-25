import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app_session_controller.dart';
import 'screens/app_shell.dart';
import 'screens/login_screen.dart';

class AppConfig {
  AppConfig._();

  static const String baseHost = String.fromEnvironment(
    'BASE_HOST',
    defaultValue: 'http://10.0.2.2:5011',
  );

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

  static String? get releaseConfigurationError {
    if (!kReleaseMode) {
      return null;
    }

    final host = baseHost.trim().toLowerCase();
    if (host.isEmpty) {
      return 'BASE_HOST release build için boş bırakılamaz.';
    }

    if (!host.startsWith('https://')) {
      return 'Release build için BASE_HOST https ile başlamalıdır.';
    }

    if (host.contains('10.0.2.2') ||
        host.contains('localhost') ||
        host.contains('127.0.0.1')) {
      return 'Release build emulator veya localhost adresi ile açılamaz.';
    }

    return null;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
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
        final configurationError = AppConfig.releaseConfigurationError;

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
                borderSide: const BorderSide(
                  color: Color(0xFF6366F1),
                  width: 1.2,
                ),
              ),
            ),
          ),
          home: configurationError != null
              ? _ConfigurationErrorScreen(message: configurationError)
              : sessionController.isAuthenticated
                  ? AppShell(sessionController: sessionController)
                  : LoginScreen(sessionController: sessionController),
        );
      },
    );
  }
}

class _ConfigurationErrorScreen extends StatelessWidget {
  const _ConfigurationErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x120F172A),
                    blurRadius: 32,
                    offset: Offset(0, 18),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFF6366F1),
                      size: 34,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Konfigürasyon gerekli',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
