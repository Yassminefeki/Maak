import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/providers/language_provider.dart';
import 'screens/language_selection_screen.dart';

class TunisiaConnectScreen extends StatelessWidget {
  const TunisiaConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A2A6E),
      body: SafeArea(
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light, // White status bar icons
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // App Icon - Rounded Square with Plus (exactly like screenshot)
                // Replace this whole Container (from lines ~25 to ~45) with this:

                Image.asset(
                  '../assets/images/logo.jpeg', // ← Change this path if your logo has a different name
                  width: 108,
                  height: 108,
                ),

                const SizedBox(height: 40),

                const SizedBox(height: 12),

                // Arabic subtitle
                const Text(
                  'إدارتك الرقمية الذكية',
                  style: TextStyle(
                    fontSize: 19,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 6),

                // English subtitle
                const Text(
                  'Your smart administrative assistant',
                  style: TextStyle(
                    fontSize: 16.5,
                    color: Colors.white60,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(flex: 3),

                // Get Started Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LanguageSelectionScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0A2A6E),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
