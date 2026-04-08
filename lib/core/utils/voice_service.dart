import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  static final stt.SpeechToText _speech = stt.SpeechToText();
  static final FlutterTts _tts = FlutterTts();

  static Future<bool> init() async {
    await _speech.initialize();
    await _tts.setLanguage("fr-FR"); // change dynamically later
    return true;
  }

  static Future<String> listen() async {
    String result = '';
    await _speech.listen(
      onResult: (val) => result = val.recognizedWords,
      localeId: 'fr-FR',
    );
    await Future.delayed(const Duration(seconds: 4));
    await _speech.stop();
    return result;
  }

  static Future<void> speak(String text) async {
    await _tts.speak(text);
  }
}