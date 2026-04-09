import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../core/providers/language_provider.dart';
import '../core/providers/accessibility_provider.dart';
import '../core/utils/voice_service.dart';
import '../core/constants/app_strings.dart';
import '../models/procedure.dart';
import 'procedure_detail_screen.dart';

class ProcedureAssistantScreen extends StatefulWidget {
  const ProcedureAssistantScreen({super.key});

  @override
  State<ProcedureAssistantScreen> createState() => _ProcedureAssistantScreenState();
}

class _ProcedureAssistantScreenState extends State<ProcedureAssistantScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isListening = false;
  bool _isSpeaking = false;
  late FlutterTts _tts;

  // ✅ Provide all required fields for Procedure
  final List<Procedure> _commonProcedures = [
    Procedure(
      key: 'lost_cin',
      title: 'Lost CIN',
      description: 'Procedure to report a lost CIN and request a new one',
      steps: ['Report loss', 'Submit required documents', 'Receive new CIN'],
      requiredDocuments: ['Old CIN (if available)', 'Identity proof'],
      cost: 'Free',
      timeRequired: '3 days',
      whereToGo: 'Civil Affairs Office',
      importantNotes: 'Bring your ID copy if available',
      icon: Icons.credit_card_outlined,
      titleKey: 'lost_cin',
      subtitleKey: 'lost_cin_desc',
    ),
    Procedure(
      key: 'register_cnam',
      title: 'Register CNAM',
      description: 'Procedure to register with CNAM for health insurance',
      steps: ['Fill registration form', 'Submit documents', 'Receive confirmation'],
      requiredDocuments: ['National ID', 'Birth certificate'],
      cost: 'Free',
      timeRequired: '1 week',
      whereToGo: 'CNAM office',
      importantNotes: 'Ensure your documents are valid',
      icon: Icons.health_and_safety_outlined,
      titleKey: 'register_cnam',
      subtitleKey: 'register_cnam_desc',
    ),
    Procedure(
      key: 'birth_certificate',
      title: 'Birth Certificate',
      description: 'Procedure to obtain a copy of birth certificate',
      steps: ['Request form', 'Submit ID', 'Receive certificate'],
      requiredDocuments: ['Parent ID', 'Hospital record if available'],
      cost: '5 TND',
      timeRequired: '2 days',
      whereToGo: 'Civil Affairs Office',
      importantNotes: 'Original documents required',
      icon: Icons.child_care_outlined,
      titleKey: 'birth_certificate',
      subtitleKey: 'birth_certificate_desc',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _initTTS();
    // Speak welcome message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakWelcomeMessage();
    });
  }

  Future<void> _initTTS() async {
    await _tts.setLanguage('ar_TN');
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
  }

  Future<void> _speakText(String text) async {
    if (text.isEmpty) return;
    setState(() => _isSpeaking = true);
    try {
      await _tts.speak(text);
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint('TTS error: $e');
    } finally {
      setState(() => _isSpeaking = false);
    }
  }

  Future<void> _speakWelcomeMessage() async {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    await _speakText(lang.t('welcome_procedure') ?? 'Welcome to Procedure Assistant. You can search for administrative procedures by voice or text.');
  }

  void _showVoiceInstructionsBottomSheet(LanguageProvider lang) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.mic, color: const Color(0xFF1E3A8A), size: 28),
                const SizedBox(width: 12),
                Text(
                  lang.t('voice_search_instructions'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildInstructionStep(
              number: 1,
              title: lang.t('say_procedure'),
              description: lang.t('say_procedure_desc') ?? 'Say what administrative procedure you need help with',
              icon: Icons.record_voice_over,
            ),
            const SizedBox(height: 16),
            _buildInstructionStep(
              number: 2,
              title: lang.t('wait_recognition'),
              description: lang.t('wait_recognition_desc') ?? 'Wait for the system to recognize and process your request',
              icon: Icons.hourglass_empty,
            ),
            const SizedBox(height: 16),
            _buildInstructionStep(
              number: 3,
              title: lang.t('view_results'),
              description: lang.t('view_results_desc') ?? 'Review the procedures that match your needs',
              icon: Icons.checklist,
            ),
            const SizedBox(height: 24),
            _buildTipsContainer(lang),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _startVoiceInput();
                },
                icon: const Icon(Icons.mic),
                label: Text(lang.t('start_voice_search')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep({
    required int number,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A).withOpacity(0.1),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipsContainer(LanguageProvider lang) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                lang.t('helpful_tips'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• ${lang.t('tip_speak_clearly')}\n'
            '• ${lang.t('tip_natural_language')}\n'
            '• ${lang.t('tip_pause_between')}',
            style: TextStyle(
              fontSize: 13,
              color: Colors.amber.shade700,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startVoiceInput() async {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    
    // Provide audio instruction
    await _speakText(lang.t('say_procedure_name') ?? 'Please say the procedure you need help with');
    
    setState(() => _isListening = true);
    try {
      final text = await VoiceService.listen();
      if (text.isNotEmpty) {
        setState(() => _searchController.text = text);
        await _speakText(lang.t('search_in_progress') ?? 'Searching for matching procedures...');
      }
    } catch (e) {
      await _speakText(lang.t('voice_error') ?? 'Error with voice input. Please try again.');
    } finally {
      setState(() => _isListening = false);
    }
  }

  void _onProcedureTap(Procedure procedure, LanguageProvider lang) {
    // Announce procedure selection
    _speakText('${lang.t('selected')}: ${procedure.title}');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProcedureDetailScreen(procedureKey: procedure.key),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final bool isRtl = langProvider.currentLanguage == AppLanguage.arabic ||
        langProvider.currentLanguage == AppLanguage.darija;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E3A8A),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            AppStrings.get(context, 'procedure_assistant') ?? 'Procedure Assistant',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              color: Colors.white,
              onPressed: () => _showVoiceInstructionsBottomSheet(langProvider),
              tooltip: langProvider.t('help'),
            ),
          ],
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.get(context, 'how_can_we_help') ?? 'How can we help you today?',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.get(context, 'search_procedures_desc') ??
                    'Search for administrative procedures or documents in simple terms.',
                style: const TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Voice Indicator
              if (_isListening)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.red,
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        langProvider.t('listening'),
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              if (_isListening) const SizedBox(height: 16),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, spreadRadius: 2),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      _speakText(langProvider.t('searching') ?? 'Searching for procedures...');
                    }
                  },
                  decoration: InputDecoration(
                    hintText: AppStrings.get(context, 'search_hint_procedure') ?? 'I lost my CIN...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isListening ? Icons.stop_circle : Icons.mic,
                        color: _isListening ? Colors.red : const Color(0xFF1E3A8A),
                        size: 28,
                      ),
                      onPressed: _isListening ? null : () => _showVoiceInstructionsBottomSheet(langProvider),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Text(
                AppStrings.get(context, 'common_procedures') ?? 'Common Procedures',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              ..._commonProcedures.map((proc) => _buildProcedureItem(
                    procedure: proc,
                    onTap: () => _onProcedureTap(proc, langProvider),
                  )),
            ],
          ),
        ),

        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: 1,
          selectedItemColor: const Color(0xFF1E3A8A),
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.home), label: AppStrings.get(context, 'home') ?? 'Home'),
            BottomNavigationBarItem(icon: const Icon(Icons.assistant), label: AppStrings.get(context, 'assistant') ?? 'Assistant'),
            BottomNavigationBarItem(icon: const Icon(Icons.location_on), label: AppStrings.get(context, 'offices') ?? 'Offices'),
            BottomNavigationBarItem(icon: const Icon(Icons.person), label: AppStrings.get(context, 'profile') ?? 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildProcedureItem({
    required Procedure procedure,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(procedure.icon ?? Icons.description, color: const Color(0xFF1E3A8A), size: 28),
        ),
        title: Text(
          AppStrings.get(context, procedure.titleKey ?? '') ?? procedure.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          AppStrings.get(context, procedure.subtitleKey ?? '') ?? procedure.description,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tts.stop();
    super.dispose();
  }
}