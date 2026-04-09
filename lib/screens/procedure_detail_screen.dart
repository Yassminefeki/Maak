import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/language_provider.dart';
import '../core/constants/app_strings.dart';

class ProcedureDetailScreen extends StatelessWidget {
  final String procedureKey;

  const ProcedureDetailScreen({super.key, required this.procedureKey});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final bool isRtl = langProvider.currentLanguage == AppLanguage.arabic ||
        langProvider.currentLanguage == AppLanguage.darija;

    // Full data from your JSON (you can later load it dynamically)
    final Map<String, dynamic> allProcedures = {
      "lost_cin": {
        "titleKey": "lost_cin",
        "stepsKey": "lost_cin_steps",
        "documentsKey": "lost_cin_documents",
        "cost": "25 دينار",
        "time": "15 يوم عمل",
        "locationKey": "lost_cin_location",
        "notesKey": "lost_cin_notes",
      },
      "register_cnam": {
        "titleKey": "register_cnam",
        "stepsKey": "register_cnam_steps",
        "documentsKey": "register_cnam_documents",
        "cost": "مجاني",
        "time": "من أسبوع إلى شهر",
        "locationKey": "register_cnam_location",
        "notesKey": "register_cnam_notes",
      },
      "birth_certificate": {
        "titleKey": "birth_certificate",
        "stepsKey": "birth_certificate_steps",
        "documentsKey": "birth_certificate_documents",
        "cost": "مجاني أو رسوم رمزية",
        "time": "فوري أو خلال يوم",
        "locationKey": "birth_certificate_location",
        "notesKey": "birth_certificate_notes",
      },
    };

    final data = allProcedures[procedureKey] ?? {};

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E3A8A),
          title: Text(
            AppStrings.get(context, 'procedure_details') ?? 'Procedure Details',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.get(context, data['titleKey'] ?? procedureKey) ?? procedureKey,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              _buildSection(context, 'steps', data['stepsKey'], isList: true),
              const SizedBox(height: 24),

              _buildSection(context, 'required_documents', data['documentsKey'], isList: true),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(child: _buildInfoCard(context, Icons.attach_money, 'cost', data['cost'] ?? '-')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInfoCard(context, Icons.access_time, 'time_required', data['time'] ?? '-')),
                ],
              ),
              const SizedBox(height: 12),

              _buildInfoCard(context, Icons.location_on, 'where_to_go', data['locationKey'] ?? '-', fullWidth: true),
              const SizedBox(height: 24),

              _buildSection(context, 'important_notes', data['notesKey'], isList: false),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppStrings.get(context, 'start_procedure') ?? 'Starting procedure...')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    AppStrings.get(context, 'start_procedure') ?? 'Start Procedure',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String titleKey, String? contentKey, {required bool isList}) {
    if (contentKey == null) return const SizedBox.shrink();

    final content = AppStrings.get(context, contentKey);
    if (content == contentKey) return const SizedBox.shrink(); // key not found

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get(context, titleKey) ?? titleKey,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (isList)
          ...content.split('||').map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  ', style: TextStyle(fontSize: 18)),
                    Expanded(child: Text(item.trim())),
                  ],
                ),
              ))
        else
          Text(content, style: const TextStyle(fontSize: 16, height: 1.5)),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, IconData icon, String labelKey, String value, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF1E3A8A), size: 28),
          const SizedBox(height: 12),
          Text(
            AppStrings.get(context, labelKey) ?? labelKey,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}