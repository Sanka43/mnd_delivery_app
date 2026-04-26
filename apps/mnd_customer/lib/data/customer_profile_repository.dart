import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerProfileRepository {
  CustomerProfileRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> upsertProfile({
    required String uid,
    required String fullName,
    required String phoneNumber,
  }) async {
    final now = FieldValue.serverTimestamp();
    await _firestore.collection('customers').doc(uid).set({
      'uid': uid,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'updatedAt': now,
      'createdAt': now,
      'isActive': true,
    }, SetOptions(merge: true));
  }
}
