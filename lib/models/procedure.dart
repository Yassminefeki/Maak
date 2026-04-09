import 'package:flutter/material.dart';

class Procedure {
  final int? id;
  final String key;
  final String title;
  final String description;
  final List<String> steps;
  final List<String> requiredDocuments;
  final String cost;
  final String timeRequired;
  final String whereToGo;
  final String importantNotes;

  // ✅ ADD THESE (fixes your crash)
  final IconData? icon;
  final String? titleKey;
  final String? subtitleKey;

  Procedure({
    this.id,
    required this.key,
    required this.title,
    required this.description,
    required this.steps,
    required this.requiredDocuments,
    required this.cost,
    required this.timeRequired,
    required this.whereToGo,
    required this.importantNotes,
    this.icon,
    this.titleKey,
    this.subtitleKey,
  });

  factory Procedure.fromMap(Map<String, dynamic> map) {
    return Procedure(
      id: map['id'],
      key: map['key'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      steps: map['steps'] != null
          ? (map['steps'] as String).split('||')
          : [],
      requiredDocuments: map['required_documents'] != null
          ? (map['required_documents'] as String).split('||')
          : [],
      cost: map['cost'] ?? '',
      timeRequired: map['time_required'] ?? '',
      whereToGo: map['where_to_go'] ?? '',
      importantNotes: map['important_notes'] ?? '',

      // optional (not from DB)
      icon: null,
      titleKey: null,
      subtitleKey: null,
    );
  }
}