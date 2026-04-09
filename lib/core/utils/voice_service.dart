import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

/// Voice Service for handling both Text-to-Speech and Speech-to-Text operations
class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  static late stt.SpeechToText _speechToText;
  static late FlutterTts _textToSpeech;
  static bool _initialized = false;
  static bool _speaking = false;

  factory VoiceService() => _instance;

  VoiceService._internal() {
    _speechToText = stt.SpeechToText();
    _textToSpeech = FlutterTts();
  }

  /// Initialize voice services
  static Future<void> initialize({
    String languageCode = 'ar_TN',
    double speechRate = 0.5,
    double pitch = 1.0,
  }) async {
    if (_initialized) return;

    try {
      // Initialize Speech-to-Text
      bool available = await _speechToText.initialize(
        onError: (error) => debugPrint('STT Error: $error'),
        onStatus: (status) => debugPrint('STT Status: $status'),
      );

      if (!available) {
        debugPrint('Speech to Text not available on this device');
      }

      // Initialize Text-to-Speech
      await _textToSpeech.setLanguage(languageCode);
      await _textToSpeech.setSpeechRate(speechRate);
      await _textToSpeech.setPitch(pitch);
      await _textToSpeech.setVolume(1.0);

      // Track speaking state
      _textToSpeech.setStartHandler(() => _speaking = true);
      _textToSpeech.setCompletionHandler(() => _speaking = false);
      _textToSpeech.setCancelHandler(() => _speaking = false);
      _textToSpeech.setErrorHandler((msg) => _speaking = false);

      _initialized = true;
    } catch (e) {
      debugPrint('Voice Service initialization error: $e');
    }
  }

  /// Speak text using Text-to-Speech
  static Future<void> speak(
    String text, {
    String? languageCode,
    double? speechRate,
    double? pitch,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      if (languageCode != null) await _textToSpeech.setLanguage(languageCode);
      if (speechRate != null) await _textToSpeech.setSpeechRate(speechRate);
      if (pitch != null) await _textToSpeech.setPitch(pitch);

      await _textToSpeech.speak(text);
    } catch (e) {
      debugPrint('TTS Error: $e');
    }
  }

  /// Listen to speech and return recognized text
  static Future<String> listen({
    String localeId = 'ar_TN',
    Duration timeout = const Duration(seconds: 10),
    VoidCallback? onListeningStarted,
    VoidCallback? onListeningStopped,
  }) async {
    if (!_initialized) await initialize();

    String recognizedText = '';

    try {
      bool available = await _speechToText.initialize();

      if (!available) {
        debugPrint('Speech recognition not available');
        return '';
      }

      onListeningStarted?.call();

      await _speechToText.listen(
        onResult: (result) {
          recognizedText = result.recognizedWords;
          debugPrint('Recognized: $recognizedText (Final: ${result.finalResult})');
        },
        localeId: localeId,
        listenMode: stt.ListenMode.confirmation,
      );

      // Wait for listening to complete or timeout
      await Future.delayed(timeout);

      onListeningStopped?.call();
      await _speechToText.stop();
    } catch (e) {
      debugPrint('Listen Error: $e');
      onListeningStopped?.call();
      await _speechToText.stop();
    }

    return recognizedText;
  }

  /// Start continuous listening with callback
  static Future<void> startListening({
    required Function(String) onResult,
    String localeId = 'ar_TN',
    Function(String)? onError,
    Function(String)? onStatus,
  }) async {
    if (!_initialized) await initialize();

    try {
      bool available = await _speechToText.initialize(
        onError: (error) {
          debugPrint('STT Error: $error');
          onError?.call(error.toString());
        },
        onStatus: (status) {
          debugPrint('STT Status: $status');
          onStatus?.call(status);
        },
      );

      if (!available) {
        onError?.call('Speech recognition not available');
        return;
      }

      await _speechToText.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
        },
        localeId: localeId,
        listenMode: stt.ListenMode.confirmation,
      );
    } catch (e) {
      debugPrint('Start Listening Error: $e');
      onError?.call(e.toString());
    }
  }

  /// Stop listening
  static Future<void> stopListening() async {
    try {
      await _speechToText.stop();
    } catch (e) {
      debugPrint('Stop Listening Error: $e');
    }
  }

  /// Check if device is currently listening
  static bool isListening() => _speechToText.isListening;

  /// Cancel speech
  static Future<void> cancel() async {
    try {
      await _speechToText.cancel();
    } catch (e) {
      debugPrint('Cancel Error: $e');
    }
  }

  /// Stop TTS
  static Future<void> stopSpeaking() async {
    try {
      await _textToSpeech.stop();
      _speaking = false;
    } catch (e) {
      debugPrint('Stop Speaking Error: $e');
    }
  }

  /// Check if TTS is currently speaking
  static bool isSpeaking() => _speaking;

  /// Get list of available languages
  static Future<List<String>> getAvailableLanguages() async {
    try {
      var languages = await _textToSpeech.getLanguages;
      return languages.cast<String>();
    } catch (e) {
      debugPrint('Get Languages Error: $e');
      return [];
    }
  }

  /// Set language for both STT and TTS
  static Future<void> setLanguage(String languageCode) async {
    try {
      await _textToSpeech.setLanguage(languageCode);
    } catch (e) {
      debugPrint('Set Language Error: $e');
    }
  }

  /// Dispose all voice resources
  static Future<void> dispose() async {
    try {
      await _speechToText.stop();
      await _textToSpeech.stop();
      _speaking = false;
      _initialized = false;
    } catch (e) {
      debugPrint('Dispose Error: $e');
    }
  }
}