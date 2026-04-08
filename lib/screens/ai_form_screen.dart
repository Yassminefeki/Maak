// lib/screens/ai_form_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../core/providers/language_provider.dart';
import '../core/providers/accessibility_provider.dart';
import '../core/database/database_helper.dart';
import '../models/user_profile.dart';

class AiFormScreen extends StatefulWidget {
  const AiFormScreen({super.key});

  @override
  State<AiFormScreen> createState() => _AiFormScreenState();
}

class _AiFormScreenState extends State<AiFormScreen> {
  File? _scannedImage;
  bool _isScanning = false;
  Map<String, String> _detectedFields = {};
  UserProfile? _profile;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await DatabaseHelper.instance.getProfile();
    if (mounted) setState(() => _profile = profile);
  }

  Future<void> _simulateScan() async {
    setState(() => _isScanning = true);

    // Simulate camera / gallery pick (demo)
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => _scannedImage = File(image.path));
      
      // Simulate OCR + AI field detection (realistic for demo)
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _detectedFields = {
          'Nom complet': _profile?.fullName ?? 'Non renseigné',
          'CIN': _profile?.cin ?? 'Non renseigné',
          'Adresse': _profile?.address ?? 'Non renseigné',
          'Date de naissance': _profile?.dob ?? 'Non renseigné',
          'Téléphone': _profile?.phone ?? 'Non renseigné',
        };
      });
    }
    setState(() => _isScanning = false);
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final accessibility = Provider.of<AccessibilityProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(lang.t('ai_form'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scan button - large for accessibility
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isScanning ? null : _simulateScan,
                icon: const Icon(Icons.camera_alt, size: 32),
                label: Text(
                  _isScanning ? 'Scan en cours...' : '📸 Scanner un formulaire vierge',
                  style: const TextStyle(fontSize: 20),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                ),
              ),
            ),

            if (_scannedImage != null) ...[
              const SizedBox(height: 24),
              Text('Formulaire scanné', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(_scannedImage!, height: 220, fit: BoxFit.cover),
              ),
            ],

            if (_detectedFields.isNotEmpty) ...[
              const SizedBox(height: 32),
              Text('Champs détectés et auto-remplis', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              ..._detectedFields.entries.map((entry) => Card(
                child: ListTile(
                  title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(entry.value),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                ),
              )),

              const SizedBox(height: 32),
              // Preview filled form (simulated realistic layout)
              Text('Aperçu du formulaire rempli (PDF prêt à imprimer)', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _detectedFields.entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        SizedBox(width: 140, child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w500))),
                        const Text(': '),
                        Expanded(child: Text(e.value, style: const TextStyle(fontSize: 16))),
                      ],
                    ),
                  )).toList(),
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Formulaire PDF généré et prêt à imprimer !')),
                    );
                  },
                  child: const Text('📄 Télécharger PDF imprimable', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],

            if (accessibility.voiceMode)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text('🔊 Mode voix activé – tout sera lu à haute voix', style: TextStyle(color: Colors.blue)),
              ),
          ],
        ),
      ),
    );
  }
}