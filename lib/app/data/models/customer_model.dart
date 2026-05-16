import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String? id;
  final String? userId;
  final String? name;
  final String? email;
  final String? mobile;
  final String? address;
  final String? gstNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CustomerModel({
    this.id,
    this.userId,
    this.name,
    this.email,
    this.mobile,
    this.address,
    this.gstNumber,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return CustomerModel(
      id: id,
      userId: map['userId'],
      name: map['name'],
      email: map['email'],
      mobile: map['mobile'],
      address: map['address'],
      gstNumber: map['gstNumber'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'mobile': mobile,
      'address': address,
      'gstNumber': gstNumber,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
