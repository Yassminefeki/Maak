import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/constants/app_strings.dart';
import 'core/providers/language_provider.dart';
import 'core/providers/accessibility_provider.dart';
import 'screens/tunisia_connect_screen.dart';
import 'screens/optimizer_screen.dart';
import 'screens/cv_navigation_screen.dart';
import 'screens/ai_form_screen.dart';
<<<<<<< HEAD
import 'screens/accessible_map.dart';
=======
import 'screens/splash_screen.dart';
>>>>>>> b8b738e2a5618a8c219acc7c3c95cd88cdae92b7
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await NotificationService.init();

  // Optional: Lock app in portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
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

          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          initialRoute: '/',
          routes: {
            '/': (_) => const SplashScreen(),
            '/connect': (_) => const TunisiaConnectScreen(),
            '/optimizer': (_) => const OptimizerScreen(),
            '/cv': (_) => const CVNavigationScreen(
                  targetGuichet: 'Guichet 3',
                  userQueueNumber: 53,
                ),
            '/ai_form': (_) => const AiFormScreen(),
            '/accessible_map': (_) => const AccessibleMap(),
          },
        );
      },
    );
  }
}
