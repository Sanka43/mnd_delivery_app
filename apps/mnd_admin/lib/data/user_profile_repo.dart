import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mnd_core/mnd_core.dart';

/// Expects `users/{uid}` with field `role` matching [userRoleKey].
class UserProfileRepo {
  UserProfileRepo({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<UserRole?> roleFor(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return userRoleFromKey(doc.data()?['role'] as String?);
  }
}
