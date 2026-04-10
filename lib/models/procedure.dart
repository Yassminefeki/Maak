import 'package:flutter/material.dart';

class Procedure {
  final String key;
  final String title;
  final String description;
  final List<String> steps;
  final List<String> requiredDocuments;
  final String cost;
  final String timeRequired;
  final String whereToGo;
  final String importantNotes;
  final IconData? icon;

  // Optional localization keys
  final String? titleKey;
  final String? subtitleKey;

  Procedure({
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

  // Convert Procedure object → Map (for saving to database)
  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'title': title,
      'description': description,
      'steps': steps.join('||'),                    // Join list with separator
      'requiredDocuments': requiredDocuments.join('||'),
      'cost': cost,
      'timeRequired': timeRequired,
      'whereToGo': whereToGo,
      'importantNotes': importantNotes,
      // icon is not saved (it's a Flutter IconData)
    };
  }

  // Convert Map (from database) → Procedure object
  factory Procedure.fromMap(Map<String, dynamic> map) {
    return Procedure(
      key: map['key'],
      title: map['title'],
      description: map['description'],
      steps: (map['steps'] as String).split('||'),
      requiredDocuments: (map['requiredDocuments'] as String).split('||'),
      cost: map['cost'],
      timeRequired: map['timeRequired'],
      whereToGo: map['whereToGo'],
      importantNotes: map['importantNotes'],
      icon: null, // You can map icon later if needed
      titleKey: map['titleKey'],
      subtitleKey: map['subtitleKey'],
    );
  }
}