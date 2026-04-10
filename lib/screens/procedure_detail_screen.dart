import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/language_provider.dart';
import '../models/procedure.dart';
import '../core/constants/app_strings.dart';

class ProcedureDetailScreen extends StatelessWidget {
  final String procedureKey;

  const ProcedureDetailScreen({super.key, required this.procedureKey});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final isRtl = lang.currentLanguage == AppLanguage.arabic ||
        lang.currentLanguage == AppLanguage.darija;

    // In a real app, you should fetch the Procedure by key from a provider or list.
    // For simplicity, we show a basic detail screen.
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppStrings.get(context, procedureKey) ?? 'Procedure Details',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF1E3A8A),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.assignment_turned_in, size: 80, color: Color(0xFF1E3A8A)),
              const SizedBox(height: 16),
              Text(
                'Procedure: ${procedureKey.replaceAll('_', ' ').toUpperCase()}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildSection('Steps', [
                'Step 1: Go to the concerned office',
                'Step 2: Prepare required documents',
                'Step 3: Submit and pay fees',
                'Step 4: Wait for processing',
              ]),
              const SizedBox(height: 16),
              _buildSection('Required Documents', [
                'National ID (CIN)',
                'Recent photos',
                'Proof of address',
              ]),
              const SizedBox(height: 16),
              _buildInfoRow('Cost', 'Free / Variable'),
              _buildInfoRow('Time Required', '3-15 working days'),
              _buildInfoRow('Where to Go', 'Civil Affairs Office'),
              const SizedBox(height: 30),
              const Text(
                'Important Notes:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Text(
                '• Bring original + photocopies\n'
                '• Check office working hours\n'
                '• Some procedures require online pre-registration',
                style: TextStyle(fontSize: 15, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item)),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }
}