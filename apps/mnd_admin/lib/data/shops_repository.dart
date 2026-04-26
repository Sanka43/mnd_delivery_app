import 'package:cloud_firestore/cloud_firestore.dart';

/// Business type shown to customers (stored as `category` on `shops` docs).
enum ShopCategory {
  restaurant,
  bar,
  hotels,
  superMarket,
  grocery,
}

String shopCategoryFirestoreKey(ShopCategory c) => switch (c) {
      ShopCategory.superMarket => 'super_market',
      _ => c.name,
    };

ShopCategory shopCategoryFromKey(String? key) {
  if (key == null || key.isEmpty) return ShopCategory.restaurant;
  if (key == 'super_market') return ShopCategory.superMarket;
  for (final v in ShopCategory.values) {
    if (v.name == key) return v;
  }
  return ShopCategory.restaurant;
}

extension ShopCategoryDisplay on ShopCategory {
  /// User-facing label (English).
  String get label => switch (this) {
        ShopCategory.restaurant => 'Restaurant',
        ShopCategory.bar => 'Bar',
        ShopCategory.hotels => 'Hotels',
        ShopCategory.superMarket => 'Super market',
        ShopCategory.grocery => 'Grocery',
      };
}

enum ShopRecordStatus { pending, active, suspended }

String shopRecordStatusKey(ShopRecordStatus s) => s.name;

ShopRecordStatus shopRecordStatusFromKey(String? key) {
  if (key == null) return ShopRecordStatus.pending;
  for (final v in ShopRecordStatus.values) {
    if (v.name == key) return v;
  }
  return ShopRecordStatus.pending;
}

/// One row in Firestore `shops` (admin-managed directory).
class ShopRecord {
  const ShopRecord({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.area,
    required this.phone,
    required this.category,
    required this.status,
    this.createdAt,
  });

  final String id;
  final String name;
  final String ownerName;
  final String area;
  final String phone;
  final ShopCategory category;
  final ShopRecordStatus status;
  final DateTime? createdAt;

  factory ShopRecord.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return ShopRecord(
      id: doc.id,
      name: (d['name'] as String?)?.trim() ?? '',
      ownerName: (d['owner_name'] as String?)?.trim() ?? '',
      area: (d['area'] as String?)?.trim() ?? '',
      phone: (d['phone'] as String?)?.trim() ?? '',
      category: shopCategoryFromKey(d['category'] as String?),
      status: shopRecordStatusFromKey(d['status'] as String?),
      createdAt: (d['created_at'] as Timestamp?)?.toDate(),
    );
  }
}

/// Payload from add/edit form (no document id).
class ShopRecordDraft {
  const ShopRecordDraft({
    required this.name,
    required this.ownerName,
    required this.area,
    required this.phone,
    required this.category,
    required this.status,
  });

  final String name;
  final String ownerName;
  final String area;
  final String phone;
  final ShopCategory category;
  final ShopRecordStatus status;
}

class ShopsRepository {
  ShopsRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const String collection = 'shops';

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(collection);

  Stream<List<ShopRecord>> watchShops() {
    return _col.orderBy('created_at', descending: true).snapshots().map(
          (snap) => snap.docs.map(ShopRecord.fromDoc).toList(),
        );
  }

  Stream<ShopRecord?> watchShop(String id) {
    return _col.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ShopRecord.fromDoc(doc);
    });
  }

  Future<void> create(ShopRecordDraft draft) async {
    await _col.add({
      'name': draft.name.trim(),
      'owner_name': draft.ownerName.trim(),
      'area': draft.area.trim(),
      'phone': draft.phone.trim(),
      'category': shopCategoryFirestoreKey(draft.category),
      'status': shopRecordStatusKey(draft.status),
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> update(String id, ShopRecordDraft draft) async {
    await _col.doc(id).update({
      'name': draft.name.trim(),
      'owner_name': draft.ownerName.trim(),
      'area': draft.area.trim(),
      'phone': draft.phone.trim(),
      'category': shopCategoryFirestoreKey(draft.category),
      'status': shopRecordStatusKey(draft.status),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> delete(String id) => _col.doc(id).delete();

  Future<void> setStatus(String id, ShopRecordStatus status) async {
    await _col.doc(id).update({
      'status': shopRecordStatusKey(status),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}
