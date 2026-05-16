import 'package:cloud_firestore/cloud_firestore.dart';

class SettingModel {
  final String? id;
  final String? userId;
  final List<String>? unitTypes;
  final TaxSettings? taxSettings;
  final String? currency;

  SettingModel({
    this.id,
    this.userId,
    this.unitTypes,
    this.taxSettings,
    this.currency,
  });

  factory SettingModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return SettingModel(
      id: id,
      userId: map['userId']?.toString(),
      unitTypes: map['unitTypes'] != null ? List<String>.from(map['unitTypes']) : null,
      taxSettings: map['taxSettings'] != null ? TaxSettings.fromMap(map['taxSettings']) : null,
      currency: map['currency']?.toString() ?? '₹',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'unitTypes': unitTypes,
      'taxSettings': taxSettings?.toMap(),
      'currency': currency,
    };
  }
}

class TaxSettings {
  final bool? enableCGST;
  final bool? enableSGST;
  final bool? enableIGST;
  final String? defaultTax;

  TaxSettings({
    this.enableCGST,
    this.enableSGST,
    this.enableIGST,
    this.defaultTax,
  });

  factory TaxSettings.fromMap(Map<String, dynamic> map) {
    return TaxSettings(
      enableCGST: map['enableCGST'] is bool ? map['enableCGST'] : true,
      enableSGST: map['enableSGST'] is bool ? map['enableSGST'] : true,
      enableIGST: map['enableIGST'] is bool ? map['enableIGST'] : false,
      defaultTax: map['defaultTax']?.toString() ?? '18',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enableCGST': enableCGST,
      'enableSGST': enableSGST,
      'enableIGST': enableIGST,
      'defaultTax': defaultTax,
    };
  }
}
