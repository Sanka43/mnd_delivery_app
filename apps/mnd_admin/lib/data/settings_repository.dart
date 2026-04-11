import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mnd_core/mnd_core.dart';

class SettingsValidationException implements Exception {
  SettingsValidationException(this.errors);
  final List<String> errors;
}

/// `settings/global` and audit trail `settings_logs`.
class SettingsRepository {
  SettingsRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const String settingsCollection = 'settings';
  static const String globalDocId = 'global';
  static const String logsCollection = 'settings_logs';

  Future<GlobalSettings?> loadGlobal() async {
    final snap =
        await _db.collection(settingsCollection).doc(globalDocId).get();
    if (!snap.exists || snap.data() == null) return null;
    final data = snap.data()!;
    DateTime? last;
    final raw = data['last_updated'];
    if (raw is Timestamp) last = raw.toDate();
    return GlobalSettings.fromMap(
      Map<String, dynamic>.from(data),
      lastUpdated: last,
    );
  }

  Future<void> saveGlobal({
    required GlobalSettings next,
    required GlobalSettings? previous,
    required String adminUid,
  }) async {
    final errors = validateGlobalSettings(next);
    if (errors.isNotEmpty) {
      throw SettingsValidationException(errors);
    }

    final batch = _db.batch();
    final ref = _db.collection(settingsCollection).doc(globalDocId);
    batch.set(
      ref,
      next.toMap(lastUpdatedField: FieldValue.serverTimestamp()),
      SetOptions(merge: true),
    );

    final message = _changeMessage(previous, next);
    batch.set(_db.collection(logsCollection).doc(), {
      'message': message,
      'created_at': FieldValue.serverTimestamp(),
      'admin_uid': adminUid,
    });

    await batch.commit();
  }

  String _changeMessage(GlobalSettings? previous, GlobalSettings next) {
    if (previous == null) {
      return 'Admin set initial platform settings (commission '
          '${commissionTypeKey(next.commissionType)} ${next.commissionValue}, '
          'delivery ${next.deliveryFee}, delivery cut ${next.deliveryCut}).';
    }
    final parts = <String>[];
    if (previous.commissionType != next.commissionType ||
        previous.commissionValue != next.commissionValue) {
      if (previous.commissionType == next.commissionType) {
        parts.add(
          'commission from ${previous.commissionValue} to ${next.commissionValue}',
        );
      } else {
        parts.add(
          'commission from ${commissionTypeKey(previous.commissionType)} '
          '${previous.commissionValue} to '
          '${commissionTypeKey(next.commissionType)} ${next.commissionValue}',
        );
      }
    }
    if (previous.deliveryFee != next.deliveryFee) {
      parts.add(
        'delivery fee from ${previous.deliveryFee} to ${next.deliveryFee}',
      );
    }
    if (previous.deliveryCut != next.deliveryCut) {
      parts.add(
        'delivery cut from ${previous.deliveryCut} to ${next.deliveryCut}',
      );
    }
    if (parts.isEmpty) {
      return 'Admin saved settings (no effective changes).';
    }
    return 'Admin changed ${parts.join('; ')}.';
  }
}
