import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';   // ← Add this import
import 'package:provider/provider.dart';

import 'core/constants/app_strings.dart';
import 'core/providers/language_provider.dart';
import 'core/providers/accessibility_provider.dart';
import 'screens/tunisia_connect_screen.dart';
import 'screens/optimizer_screen.dart';
import 'screens/cv_navigation_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();

  // Optional: Lock app in portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AccessibilityProvider()),
      ],
      child: const AdminProcessApp(),
    ),
  );
}

class AdminProcessApp extends StatelessWidget {
  const AdminProcessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, langProvider, child) {
        return MaterialApp(
          title: 'Admin Connect',
          debugShowCheckedModeBanner: false,

          theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
          ),

          // Locale
          locale: langProvider.currentLanguage == AppLanguage.arabic
              ? const Locale('ar', 'TN')
              : const Locale('fr', 'FR'),

          supportedLocales: const [
            Locale('ar', 'TN'),
            Locale('fr', 'FR'),
          ],

          // ← This was missing → now fixed
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          initialRoute: '/optimizer',
          routes: {
            '/': (_) => const TunisiaConnectScreen(),
            '/optimizer': (_) => const OptimizerScreen(),
            '/cv': (_) => const CVNavigationScreen(
              targetGuichet: 'Guichet 3',
              userQueueNumber: 53,
            ),
          },
        );
      },
    );
  }
}