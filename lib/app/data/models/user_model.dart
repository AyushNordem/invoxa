import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? uid;
  final String? fullName;
  final String? email;
  final String? mobile;
  final String? businessName;
  final String? profileImageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    this.uid,
    this.fullName,
    this.email,
    this.mobile,
    this.businessName,
    this.profileImageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return UserModel(
      uid: id ?? (map['uid']?.toString()),
      fullName: map['fullName']?.toString(),
      email: map['email']?.toString(),
      mobile: map['mobile']?.toString(),
      businessName: map['businessName']?.toString(),
      profileImageUrl: map['profileImageUrl']?.toString(),
      createdAt: map['createdAt'] is Timestamp ? (map['createdAt'] as Timestamp).toDate() : null,
      updatedAt: map['updatedAt'] is Timestamp ? (map['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'mobile': mobile,
      'businessName': businessName,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
