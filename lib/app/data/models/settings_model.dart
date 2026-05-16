import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsModel {
  final String? userId;
  final String? currency;
  final String? currencySymbol;
  final double? cgst;
  final double? sgst;
  final double? igst;
  final List<String>? units;
  final DateTime? updatedAt;

  SettingsModel({
    this.userId,
    this.currency,
    this.currencySymbol,
    this.cgst,
    this.sgst,
    this.igst,
    this.units,
    this.updatedAt,
  });

  factory SettingsModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return SettingsModel(
      userId: id ?? map['userId'],
      currency: map['currency'],
      currencySymbol: map['currencySymbol'],
      cgst: map['cgst']?.toDouble(),
      sgst: map['sgst']?.toDouble(),
      igst: map['igst']?.toDouble(),
      units: (map['units'] as List?)?.map((u) => u.toString()).toList(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currency': currency,
      'currencySymbol': currencySymbol,
      'cgst': cgst,
      'sgst': sgst,
      'igst': igst,
      'units': units,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
