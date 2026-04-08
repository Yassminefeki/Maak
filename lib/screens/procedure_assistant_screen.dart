// lib/screens/procedure_assistant_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/language_provider.dart';
import '../core/providers/accessibility_provider.dart';
import '../core/utils/voice_service.dart';

class ProcedureAssistantScreen extends StatefulWidget {
  const ProcedureAssistantScreen({super.key});

  @override
  State<ProcedureAssistantScreen> createState() => _ProcedureAssistantScreenState();
}

class _ProcedureAssistantScreenState extends State<ProcedureAssistantScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isListening = false;

  Future<void> _startVoiceInput() async {
    setState(() => _isListening = true);
    final text = await VoiceService.listen();
    if (text.isNotEmpty) {
      setState(() {
        _searchController.text = text;
      });
      // You can process the query here if needed
    }
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final accessibility = Provider.of<AccessibilityProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Procedure Assistant',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Text
            const Text(
              "How can we help you today?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Search for administrative procedures or documents in simple terms.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Search Bar with Voice
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "I lost my CIN...",
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

            // Common Procedures
            const Text(
              "Common Procedures",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildProcedureItem(
              icon: Icons.credit_card_outlined,
              title: "I lost my CIN",
              subtitle: "Replacement & reporting guide",
            ),
            _buildProcedureItem(
              icon: Icons.health_and_safety_outlined,
              title: "Register for CNAM",
              subtitle: "Social security enrollment",
            ),
            _buildProcedureItem(
              icon: Icons.child_care_outlined,
              title: "Birth Certificate",
              subtitle: "Instant digital request",
            ),
            
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1, // Assistant is active
        selectedItemColor: const Color(0xFF1E3A8A),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.assistant), label: "Assistant"),
          BottomNavigationBarItem(
              icon: Icon(Icons.location_on), label: "Offices"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildProcedureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF1E3A8A), size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          // TODO: Navigate to detailed procedure screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Opening procedure: $title")),
          );
        },
      ),
    );
  }
}