import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mnd_core/mnd_core.dart';

/// Loads live [GlobalSettings] only to create new orders; each order stores a
/// frozen [OrderPricingSnapshot] via [computeOrderPricing].
class OrderRepository {
  OrderRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<GlobalSettings?> _loadGlobal() async {
    final snap = await _db.collection('settings').doc('global').get();
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

  /// Persists snapshot fields on the order document — never recomputed from settings.
  Future<String> createOrder({
    required String shopUid,
    required num itemPrice,
  }) async {
    final settings = await _loadGlobal();
    if (settings == null) {
      throw StateError(
        'Missing settings/global. Configure commission and delivery in the admin app.',
      );
    }
    final pricing = computeOrderPricing(itemPrice: itemPrice, settings: settings);
    final doc = await _db.collection('orders').add({
      ...pricing.toOrderFields(),
      'status': orderStatusKey(OrderStatus.pending),
      'shop_id': shopUid,
      'created_at': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  /// Requires a composite index: `shop_id` ASC + `created_at` DESC (see firebase/firestore.indexes.json).
  Stream<QuerySnapshot<Map<String, dynamic>>> ordersForShop(String shopUid) {
    return _db
        .collection('orders')
        .where('shop_id', isEqualTo: shopUid)
        .orderBy('created_at', descending: true)
        .limit(50)
        .snapshots();
  }
}
