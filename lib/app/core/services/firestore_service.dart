import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveBusinessDetails(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore
        .collection(AppConstants.collectionBusinesses)
        .doc(user.uid)
        .set(data, SetOptions(merge: true));
    
    // Also update user profile to mark business as setup
    await _firestore
        .collection(AppConstants.collectionUsers)
        .doc(user.uid)
        .update({'isBusinessSetup': true});
  }

  Future<bool> isBusinessSetupComplete() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _firestore
        .collection(AppConstants.collectionUsers)
        .doc(user.uid)
        .get();

    if (doc.exists && doc.data() != null) {
      return (doc.data() as Map<String, dynamic>)['isBusinessSetup'] ?? false;
    }
    return false;
  }
}
