import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String? id;
  final String? userId;
  final String? name; // Business Name
  final String? contactPerson;
  final String? email;
  final String? mobile;
  final String? gstNumber;
  final CustomerAddress? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CustomerModel({
    this.id,
    this.userId,
    this.name,
    this.contactPerson,
    this.email,
    this.mobile,
    this.gstNumber,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return CustomerModel(
      id: id,
      userId: map['userId']?.toString(),
      name: map['name']?.toString(),
      contactPerson: map['contactPerson']?.toString(),
      email: map['email']?.toString(),
      mobile: map['mobile']?.toString(),
      gstNumber: map['gstNumber']?.toString(),
      address: map['address'] != null ? CustomerAddress.fromMap(map['address']) : null,
      createdAt: map['createdAt'] is Timestamp ? (map['createdAt'] as Timestamp).toDate() : null,
      updatedAt: map['updatedAt'] is Timestamp ? (map['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'contactPerson': contactPerson,
      'email': email,
      'mobile': mobile,
      'gstNumber': gstNumber,
      'address': address?.toMap(),
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class CustomerAddress {
  final String? street;
  final String? city;
  final String? state;
  final String? zipCode;

  CustomerAddress({this.street, this.city, this.state, this.zipCode});

  factory CustomerAddress.fromMap(Map<String, dynamic> map) {
    return CustomerAddress(
      street: map['street']?.toString(),
      city: map['city']?.toString(),
      state: map['state']?.toString(),
      zipCode: map['zipCode']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
    };
  }
}
