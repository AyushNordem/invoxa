import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessModel {
  final String? id;
  final String? businessName;
  final String? ownerName;
  final String? mobile;
  final String? email;
  final String? website;
  final String? logoUrl;
  final String? signatureUrl;
  final AddressInfo? address;
  final BankDetails? bankDetails;
  final TaxSettings? taxSettings;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BusinessModel({
    this.id,
    this.businessName,
    this.ownerName,
    this.mobile,
    this.email,
    this.website,
    this.logoUrl,
    this.signatureUrl,
    this.address,
    this.bankDetails,
    this.taxSettings,
    this.createdAt,
    this.updatedAt,
  });

  factory BusinessModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return BusinessModel(
      id: id,
      businessName: map['businessName']?.toString(),
      ownerName: map['ownerName']?.toString(),
      mobile: map['mobile']?.toString(),
      email: map['email']?.toString(),
      website: map['website']?.toString(),
      logoUrl: map['logoUrl']?.toString(),
      signatureUrl: map['signatureUrl']?.toString(),
      address: map['address'] != null ? AddressInfo.fromMap(map['address']) : null,
      bankDetails: map['bankDetails'] != null ? BankDetails.fromMap(map['bankDetails']) : null,
      taxSettings: map['taxSettings'] != null ? TaxSettings.fromMap(map['taxSettings']) : null,
      createdAt: map['createdAt'] is Timestamp ? (map['createdAt'] as Timestamp).toDate() : null,
      updatedAt: map['updatedAt'] is Timestamp ? (map['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'businessName': businessName,
      'ownerName': ownerName,
      'mobile': mobile,
      'email': email,
      'website': website,
      'logoUrl': logoUrl,
      'signatureUrl': signatureUrl,
      'address': address?.toMap(),
      'bankDetails': bankDetails?.toMap(),
      'taxSettings': taxSettings?.toMap(),
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class AddressInfo {
  final String? street;
  final String? state;
  final String? city;
  final String? pincode;

  AddressInfo({this.street, this.state, this.city, this.pincode});

  factory AddressInfo.fromMap(Map<String, dynamic> map) {
    return AddressInfo(
      street: map['street']?.toString(),
      state: map['state']?.toString(),
      city: map['city']?.toString(),
      pincode: map['pincode']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'street': street,
      'state': state,
      'city': city,
      'pincode': pincode,
    };
  }
}

class BankDetails {
  final String? accountHolder;
  final String? bankName;
  final String? accountNumber;
  final String? ifsc;
  final String? branch;

  BankDetails({this.accountHolder, this.bankName, this.accountNumber, this.ifsc, this.branch});

  factory BankDetails.fromMap(Map<String, dynamic> map) {
    return BankDetails(
      accountHolder: map['accountHolder']?.toString(),
      bankName: map['bankName']?.toString(),
      accountNumber: map['accountNumber']?.toString(),
      ifsc: map['ifsc']?.toString(),
      branch: map['branch']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accountHolder': accountHolder,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'ifsc': ifsc,
      'branch': branch,
    };
  }
}

class TaxSettings {
  final String? gstNumber;
  final String? taxNumber;
  final String? currency;
  final String? defaultTax;
  final bool? enableCGST;
  final bool? enableSGST;
  final bool? enableIGST;

  TaxSettings({this.gstNumber, this.taxNumber, this.currency, this.defaultTax, this.enableCGST, this.enableSGST, this.enableIGST});

  factory TaxSettings.fromMap(Map<String, dynamic> map) {
    return TaxSettings(
      gstNumber: map['gstNumber']?.toString(),
      taxNumber: map['taxNumber']?.toString(),
      currency: map['currency']?.toString(),
      defaultTax: map['defaultTax']?.toString(),
      enableCGST: map['enableCGST'] is bool ? map['enableCGST'] : true,
      enableSGST: map['enableSGST'] is bool ? map['enableSGST'] : true,
      enableIGST: map['enableIGST'] is bool ? map['enableIGST'] : false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gstNumber': gstNumber,
      'taxNumber': taxNumber,
      'currency': currency,
      'defaultTax': defaultTax,
      'enableCGST': enableCGST,
      'enableSGST': enableSGST,
      'enableIGST': enableIGST,
    };
  }
}
