// lib/services/local_assistant_service.dart
import '../core/constants/app_strings.dart';
import '../core/database/database_helper.dart';

class LocalAssistantResponse {
  final String text;
  final String? actionRoute;
  final String? actionLabel;

  LocalAssistantResponse({
    required this.text,
    this.actionRoute,
    this.actionLabel,
  });
}

class LocalAssistantService {
  static Future<LocalAssistantResponse> handleOfflineQuery(String query, AppLanguage lang) async {
    final lowerQuery = query.toLowerCase();

    // 1. Check for User Profile Info
    if (lowerQuery.contains('cin') || lowerQuery.contains('nom') || lowerQuery.contains('adresse') || lowerQuery.contains('prénom')) {
      final profile = await DatabaseHelper.instance.getProfile();
      if (profile != null) {
        String msg = '';
        if (lang == AppLanguage.french) {
          msg = "Je peux accéder à vos données locales : Votre nom est ${profile.fullName}, votre CIN est ${profile.cin} et vous habitez à ${profile.address}.";
        } else {
          msg = "تنجم نشوف معلوماتك المخزنة: اسمك ${profile.fullName}، رقم بطاقة تعريفك ${profile.cin} وتسكن في ${profile.address}.";
        }
        return LocalAssistantResponse(text: msg);
      }
    }

    // 2. Check for App Features & Redirections
    
    // Optimizer
    if (lowerQuery.contains('temps') || lowerQuery.contains('affluence') || lowerQuery.contains('visite') || lowerQuery.contains('zham')) {
      String msg = (lang == AppLanguage.french) 
        ? "Je ne peux pas joindre le serveur IA, mais vous pouvez utiliser l'Optimizer pour voir les temps d'attente."
        : "منجمش نتصل بـ IA توا، أما تنجم تستعمل الـ Optimizer باش تشوف أوقات الزحمة.";
      return LocalAssistantResponse(
        text: msg,
        actionRoute: '/optimizer',
        actionLabel: (lang == AppLanguage.french) ? "Ouvrir l'Optimizer" : "حل الـ Optimizer",
      );
    }

    // AR Navigation
    if (lowerQuery.contains('direction') || lowerQuery.contains('navigation') || lowerQuery.contains('guichet') || lowerQuery.contains('caméra')) {
      String msg = (lang == AppLanguage.french)
        ? "Je vous suggère d'utiliser notre navigation en réalité augmentée pour trouver votre guichet."
        : "ننصحك تستعمل الكاميرا والـ AR باش تلقى الشباك متاعك بسهولة.";
      return LocalAssistantResponse(
        text: msg,
        actionRoute: '/cv',
        actionLabel: (lang == AppLanguage.french) ? "Lancer la Caméra" : "حل الكاميرا",
      );
    }

    // AI Forms
    if (lowerQuery.contains('formulaire') || lowerQuery.contains('remplir') || lowerQuery.contains('papiers') || lowerQuery.contains('document')) {
      String msg = (lang == AppLanguage.french)
        ? "Vous pouvez remplir vos documents automatiquement via notre assistant de formulaires."
        : "تنجم تعمر أوراقك فيسع باستعمال مساعد الأوراق الذكي.";
      return LocalAssistantResponse(
        text: msg,
        actionRoute: '/ai_form',
        actionLabel: (lang == AppLanguage.french) ? "Remplir un Formulaire" : "تعمير الأوراق",
      );
    }

    // Default Fallback Message
    String fallback = (lang == AppLanguage.french)
      ? "Je n'ai pas pu me connecter à mon intelligence centrale, mais je reste à votre disposition pour vos données locales."
      : "منجمتش نتصل بالذكاء الاصطناعي، أما راني معاك باش نعاونك بالمعلومات المخزنة في التليفون.";
    
    return LocalAssistantResponse(text: fallback);
  }
}
