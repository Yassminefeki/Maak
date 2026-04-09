import 'package:flutter/material.dart';
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

  Future<void> _startVoiceInput() async {
    setState(() => _isListening = true);
    final text = await VoiceService.listen();
    if (text.isNotEmpty) {
      setState(() => _searchController.text = text);
    }
    setState(() => _isListening = false);
  }

  void _onProcedureTap(Procedure procedure) {
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
                      onPressed: _startVoiceInput,
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
                    onTap: () => _onProcedureTap(proc),
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
}