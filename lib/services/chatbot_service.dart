// lib/services/chatbot_service.dart
import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/constants/app_strings.dart';
import '../core/database/database_helper.dart';

class ChatbotService {
  static Future<String> getBotReply(String userText, AppLanguage lang) async {
    final _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    if (_apiKey.isEmpty || _apiKey == 'your_real_api_key_here') {
      if (lang == AppLanguage.french) {
        return "Clé API manquante. Veuillez configurer GEMINI_API_KEY dans le fichier .env";
      } else if (lang == AppLanguage.darija) {
        return "المفتاح متع API ناقص. ثبت في ملف .env";
      } else {
        return "مفتاح API غير موجود. يرجى إعداد GEMINI_API_KEY في ملف .env";
      }
    }

    String userInfo =
        "Aucune information personnelle disponible."; // default fallback

    try {
      // 1. Safely try to load profile (this is where it was crashing)
      final profile = await DatabaseHelper.instance.getProfile();

      if (profile != null) {
        userInfo =
            "Nom: ${profile.fullName}, CIN: ${profile.cin}, Naissance: ${profile.dob}, "
            "Téléphone: ${profile.phone}, Adresse: ${profile.address}";
      }
    } catch (e) {
      // This catches the sqflite web error + any other DB issues
      print("⚠️ Could not load user profile from database: $e");
      // On web, we just continue with empty profile (no crash)
    }

    // Rest of your code stays exactly the same
    String langInstruction = 'Tu es MaakBot, un assistant consulaire tunisien.';

    if (lang == AppLanguage.french) {
      langInstruction += ' Réponds obligatoirement en français.';
    } else if (lang == AppLanguage.darija) {
      langInstruction +=
          ' Réponds obligatoirement en dialecte tunisien (darija).';
    } else {
      langInstruction += ' Réponds obligatoirement en arabe classique.';
    }

    final String fullContext = '''
$langInstruction
Voici les informations privées de l'utilisateur avec qui tu discutes : $userInfo
Si la question de l'utilisateur porte sur ses informations (ex: "quel est mon CIN ?", "quel est mon âge ?"), tu dois utiliser les informations ci-dessus pour lui répondre.
Ne mentionne pas que tu as accès à ces informations à moins qu'il le demande.

Question de l'utilisateur : $userText
''';

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
      );

      final content = [Content.text(fullContext)];
      final response = await model.generateContent(content);

      if (response.text == null) {
        return "L'IA n'a pas pu répondre (possiblement bloqué par les filtres de sécurité).";
      }

      return response.text!;
    } catch (e) {
      print("❌ Gemini API Error: $e");
      String errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains("api_key_invalid")) {
        return "Clé API invalide. Vérifiez votre configuration dans .env";
      } else if (errorMsg.contains("quota")) {
        return "Quota épuisé ou API non activée. Vérifiez votre console Google AI Studio.";
      }
      return "Erreur : ${e.toString().split('\n').first}";
    }
  }
}
