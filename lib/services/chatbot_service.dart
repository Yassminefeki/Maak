// lib/services/chatbot_service.dart
import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/constants/app_strings.dart';
import '../core/database/database_helper.dart';
import 'local_assistant_service.dart';

class ChatBotResponse {
  final String text;
  final String? actionRoute;
  final String? actionLabel;

  ChatBotResponse({required this.text, this.actionRoute, this.actionLabel});
}

class ChatbotService {
  static Future<ChatBotResponse> getBotReply(String userText, AppLanguage lang) async {
    final _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    // Check for API key presence
    if (_apiKey.isEmpty || _apiKey == 'your_real_api_key_here') {
      final local = await LocalAssistantService.handleOfflineQuery(userText, lang);
      return ChatBotResponse(
        text: local.text,
        actionRoute: local.actionRoute,
        actionLabel: local.actionLabel,
      );
    }

    String userInfo = "Aucune information personnelle disponible.";

    try {
      final profile = await DatabaseHelper.instance.getProfile();
      if (profile != null) {
        userInfo = "Nom: ${profile.fullName}, CIN: ${profile.cin}, Adresse: ${profile.address}";
      }
    } catch (e) {
      print("⚠️ Could not load user profile: $e");
    }

    String langInstruction = 'Tu es MaakBot, un assistant consulaire tunisien.';
    if (lang == AppLanguage.french) {
      langInstruction += ' Réponds en français.';
    } else if (lang == AppLanguage.darija) {
      langInstruction += ' Réponds en dialecte tunisien (darija).';
    } else {
      langInstruction += ' Réponds en arabe classique.';
    }

    final String fullContext = '''
$langInstruction
Utilisateur : $userInfo
Question : $userText
''';

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
      );

      final content = [Content.text(fullContext)];
      final response = await model.generateContent(content).timeout(const Duration(seconds: 8));

      if (response.text == null) {
        throw Exception("Empty response");
      }

      return ChatBotResponse(text: response.text!);
    } catch (e) {
      print("❌ Gemini API Error, falling back to Local Assistant: $e");
      // IF API Fails, trigger the Local Keyword Fallback
      final local = await LocalAssistantService.handleOfflineQuery(userText, lang);
      return ChatBotResponse(
        text: "Assistant local en relais : ${local.text}",
        actionRoute: local.actionRoute,
        actionLabel: local.actionLabel,
      );
    }
  }
}
