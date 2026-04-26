import 'package:firebase_auth/firebase_auth.dart';

const String _kDevEmail = 'dev@mnd.delivery';
const String _kDevPassword = 'MndDevOnly123!';

Future<void> signInWithDevOtpBypass({required String displayName}) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _kDevEmail,
      password: _kDevPassword,
    );
  } on FirebaseAuthException catch (_) {
    await FirebaseAuth.instance.signInAnonymously();
  }
  await FirebaseAuth.instance.currentUser?.updateDisplayName(displayName);
}
