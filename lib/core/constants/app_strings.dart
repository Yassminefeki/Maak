// lib/core/constants/app_strings.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

enum AppLanguage { arabic, french, darija }

class AppStrings {
  static final Map<AppLanguage, Map<String, String>> translations = {
    // 🇸🇦 ARABIC
    AppLanguage.arabic: {
      'app_title': 'تونيسيا كونكت',
      'smart_admin_assistant': 'مساعدك الإداري الذكي',
      'get_started': 'ابدأ الآن',
      'choose_language': 'اختر لغتك',
      'step_1_of_3': 'الخطوة 1 من 3',
      'personal_identity': 'الهوية الشخصية',
      'create_profile': 'إنشاء ملفك الشخصي',
      'stored_securely': 'يتم تخزينه محليًا وبأمان على جهازك',
      'need_help_speak': 'هل تحتاج مساعدة؟ تحدث لملء الحقول',
      'full_name': 'الاسم الكامل',
      'cin_number': 'رقم بطاقة التعريف',
      'date_of_birth': 'تاريخ الميلاد',
      'phone_number': 'رقم الهاتف',
      'home_address': 'العنوان السكني',
      'next': 'التالي',

      // ✅ NEW (voice)
      'voice_input': 'الإدخال الصوتي متاح',
      'voice_desc': 'جميع اللغات تدعم الأوامر الصوتية',
    },

    // 🇫🇷 FRENCH
    AppLanguage.french: {
      'app_title': 'Tunisia Connect',
      'smart_admin_assistant': 'Votre assistant administratif intelligent',
      'get_started': 'Commencer',
      'choose_language': 'Choisir votre langue',
      'step_1_of_3': 'Étape 1 sur 3',
      'personal_identity': 'Identité personnelle',
      'create_profile': 'Créer votre profil',
      'stored_securely': 'Stocké localement et en sécurité sur votre appareil',
      'need_help_speak': 'Besoin d\'aide ? Parlez pour remplir les champs',
      'full_name': 'NOM COMPLET',
      'cin_number': 'NUMÉRO CIN',
      'date_of_birth': 'DATE DE NAISSANCE',
      'phone_number': 'NUMÉRO DE TÉLÉPHONE',
      'home_address': 'ADRESSE DOMICILE',
      'next': 'Suivant',

      // ✅ NEW
      'voice_input': 'Entrée vocale disponible',
      'voice_desc': 'Toutes les langues supportent les commandes vocales',
    },

    // 🇹🇳 DARIJA
    AppLanguage.darija: {
      'app_title': 'تونيسيا كونكت',
      'smart_admin_assistant': 'مساعدك الإداري الذكي',
      'get_started': 'نبداو',
      'choose_language': 'اختر لغتك',
      'step_1_of_3': 'خطوة 1 من 3',
      'personal_identity': 'الهوية الشخصية',
      'create_profile': 'عمل بروفيلك',
      'stored_securely': 'يتخزن محليا وبأمان على جهازك',
      'need_help_speak': 'تحتاج مساعدة؟ احكي باش تعمّر الحقول',
      'full_name': 'الاسم الكامل',
      'cin_number': 'رقم البطاقة',
      'date_of_birth': 'تاريخ الولادة',
      'phone_number': 'رقم التليفون',
      'home_address': 'العنوان',
      'next': 'اللي بعدو',

      // ✅ NEW
      'voice_input': 'الإدخال بالصوت متوفر',
      'voice_desc': 'اللغات الكل تدعم الأوامر الصوتية',
    },
  };

  /// ✅ GET TRANSLATION
  static String get(BuildContext context, String key) {
    final provider = Provider.of<LanguageProvider>(context, listen: false);
    return translations[provider.currentLanguage]?[key] ?? key;
  }
}