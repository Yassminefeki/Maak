import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  final TextEditingController fullNameController = TextEditingController(text: "Mohamed Ben Ali");
  final TextEditingController cinController = TextEditingController(text: "01234567");
  final TextEditingController birthDateController = TextEditingController(text: "15/03/1990");
  final TextEditingController phoneController = TextEditingController(text: "+216 98 000 000");
  final TextEditingController addressController = TextEditingController(text: "Rue Ibn Khaldoun, Tunis");

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A2A6E),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.get(context, 'app_title')),
            Text('${AppStrings.get(context, 'step_1_of_3')} — ${AppStrings.get(context, 'personal_identity')}',
                style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.get(context, 'create_profile'),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.get(context, 'stored_securely'),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Voice Help
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(30)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.mic, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(AppStrings.get(context, 'need_help_speak')),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              _buildTextField(AppStrings.get(context, 'full_name'), fullNameController),
              const SizedBox(height: 20),
              _buildTextField(AppStrings.get(context, 'cin_number'), cinController),
              const SizedBox(height: 20),
              _buildTextField(AppStrings.get(context, 'date_of_birth'), birthDateController),
              const SizedBox(height: 20),
              _buildTextField(AppStrings.get(context, 'phone_number'), phoneController),
              const SizedBox(height: 20),
              _buildTextField(AppStrings.get(context, 'home_address'), addressController, maxLines: 2),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, navigate to HomeScreen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A2A6E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  AppStrings.get(context, 'next'),
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    cinController.dispose();
    birthDateController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }
}