import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/app_strings.dart';
import '../core/providers/language_provider.dart';
import 'home_screen.dart';

class ProfileCreationScreen extends StatefulWidget {
  const ProfileCreationScreen({super.key});

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();

  // Controllers
  final fullNameController = TextEditingController();
  final cinController = TextEditingController();
  final birthDateController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  int currentStep = 0;

  // Voice
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isProcessing = false;
  String _spokenText = '';

  // Gemini AI
  late GenerativeModel _geminiModel;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initGemini();
    _initDatabaseKey();
  }

  Future<void> _initGemini() async {
    const apiKey = 'YOUR_API_KEY_HERE';
    _geminiModel = GenerativeModel(model: 'gemini-2.0-flash-exp', apiKey: apiKey);
  }

  Future<void> _initDatabaseKey() async {
    String? key = await storage.read(key: 'db_encryption_key');
    if (key == null) {
      key = _generateSecureKey();
      await storage.write(key: 'db_encryption_key', value: key);
    }
  }

  String _generateSecureKey() => '32characterstrongrandomkey12345678';

  // ==================== Voice AI ====================
  Future<void> _startVoiceInput() async {
    bool available = await _speech.initialize(
      onStatus: (val) => debugPrint('Speech status: $val'),
      onError: (val) => debugPrint('Speech error: $val'),
    );
    if (available) {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) => setState(() => _spokenText = result.recognizedWords),
        localeId: 'ar_TN',
      );
    }
  }

  Future<void> _stopListeningAndProcess() async {
    await _speech.stop();
    setState(() => _isListening = false);
    if (_spokenText.trim().isEmpty) return;

    setState(() => _isProcessing = true);
    await _processWithGemini(_spokenText);
    setState(() => _isProcessing = false);
  }

  Future<void> _processWithGemini(String transcript) async {
    final prompt = '''
Extract the personal information from the following spoken text (Tunisian Arabic, French, or mixed) for step ${currentStep + 1}.
Return **only** a valid JSON object with these keys:

{
  "full_name": "string",
  "cin": "8 digits string",
  "date_of_birth": "DD/MM/YYYY",
  "phone_number": "+216 XX XXX XXX",
  "home_address": "string"
}

Spoken text: "$transcript"
''';

    try {
      final response = await _geminiModel.generateContent([Content.text(prompt)]);
      String jsonStr = response.text ?? '';
      jsonStr = jsonStr.replaceAll('```json', '').replaceAll('```', '').trim();

      final Map<String, dynamic>? extracted = jsonDecode(jsonStr);
      if (extracted != null && extracted.isNotEmpty) _fillFormFromVoice(extracted);
    } catch (e) {
      _showError('Gemini error: $e');
    }
  }

  void _fillFormFromVoice(Map<String, dynamic> data) {
    setState(() {
      if (currentStep == 0) {
        fullNameController.text = data['full_name']?.toString() ?? '';
        cinController.text = data['cin']?.toString() ?? '';
      } else if (currentStep == 1) {
        birthDateController.text = data['date_of_birth']?.toString() ?? '';
        phoneController.text = data['phone_number']?.toString() ?? '';
      } else if (currentStep == 2) {
        addressController.text = data['home_address']?.toString() ?? '';
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  // ==================== Step Navigation ====================
  void nextStep() {
    if (_formKey.currentState!.validate()) {
      if (currentStep < 2) setState(() => currentStep += 1);
      else _saveProfile();
    }
  }

  void previousStep() {
    if (currentStep > 0) setState(() => currentStep -= 1);
  }

  Widget stepContent(LanguageProvider lang) {
    switch (currentStep) {
      case 0:
        return Column(
          children: [
            _buildTextField(lang.t('full_name'), fullNameController),
            const SizedBox(height: 20),
            _buildTextField(lang.t('cin_number'), cinController),
          ],
        );
      case 1:
        return Column(
          children: [
            _buildTextField(lang.t('date_of_birth'), birthDateController),
            const SizedBox(height: 20),
            _buildTextField(lang.t('phone_number'), phoneController),
          ],
        );
      case 2:
        return Column(
          children: [
            _buildTextField(lang.t('home_address'), addressController, maxLines: 2),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }

  Future<void> _saveProfile() async {
    String? key = await storage.read(key: 'db_encryption_key');
    if (key == null) {
      _showError('Encryption key not found');
      return;
    }

    final db = await openDatabase(
      'profile.db',
      password: key,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE profile (
            id INTEGER PRIMARY KEY,
            full_name TEXT,
            cin TEXT,
            birth_date TEXT,
            phone TEXT,
            address TEXT
          )
        ''');
      },
    );

    await db.insert('profile', {
      'full_name': fullNameController.text,
      'cin': cinController.text,
      'birth_date': birthDateController.text,
      'phone': phoneController.text,
      'address': addressController.text,
    });

    await db.close();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${lang.t('step')} ${currentStep + 1} ${lang.t('of')} 3'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              stepContent(lang),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isProcessing
                    ? null
                    : (_isListening ? _stopListeningAndProcess : _startVoiceInput),
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Icon(_isListening ? Icons.stop : Icons.mic),
                label: Text(
                  _isProcessing
                      ? lang.t('processing')
                      : (_isListening ? lang.t('stop_and_fill') : lang.t('speak_to_fill')),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isListening ? Colors.red : const Color(0xFF0A2A6E),
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (currentStep > 0)
                    ElevatedButton(
                        onPressed: previousStep,
                        child: Text(lang.t('back'))),
                  ElevatedButton(
                      onPressed: nextStep,
                      child: Text(currentStep < 2 ? lang.t('next') : lang.t('submit'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    cinController.dispose();
    birthDateController.dispose();
    phoneController.dispose();
    addressController.dispose();
    _speech.stop();
    super.dispose();
  }
}