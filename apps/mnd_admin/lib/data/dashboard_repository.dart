import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mnd_core/mnd_core.dart';

/// Snapshot of headline metrics for the admin dashboard (aggregate queries).
class DashboardStats {
  const DashboardStats({
    required this.ordersTotal,
    required this.ordersToday,
    required this.pendingOrders,
    required this.ridersRegistered,
    required this.revenueDeliveredTotal,
    required this.revenueDeliveredToday,
    this.warnings = const [],
  });

  final int ordersTotal;
  final int ordersToday;
  final int pendingOrders;
  final int ridersRegistered;
  final num revenueDeliveredTotal;
  final num revenueDeliveredToday;

  /// Non-fatal issues — only when both aggregate and fallback fail.
  final List<String> warnings;

  bool get hasWarnings => warnings.isNotEmpty;
}

class DashboardRepository {
  DashboardRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static Timestamp _startOfLocalDay(DateTime now) {
    final local = DateTime(now.year, now.month, now.day);
    return Timestamp.fromDate(local);
  }

  /// User-facing hint; do not guess wrong composite fields for every error.
  static String _formatFailure(String whatFailed, Object e) {
    final s = e.toString();
    final buf = StringBuffer('$whatFailed\n');
    if (s.contains('permission') || s.contains('PERMISSION_DENIED')) {
      buf.write('Check Firestore security rules for admin reads.');
    } else if (s.contains('failed-precondition') ||
        s.contains('FAILED_PRECONDITION') ||
        s.contains('index')) {
      buf.write(
        'If this mentions an index, open the link below in Firebase Console '
        'or deploy firebase/firestore.indexes.json.\n',
      );
    }
    buf.write(s);
    return buf.toString();
  }

  static num _readAmount(dynamic v) {
    if (v is num) return v;
    if (v == null) return 0;
    return num.tryParse(v.toString()) ?? 0;
  }

  Future<int> _ordersTotalCount({
    required CollectionReference<Map<String, dynamic>> orders,
    required List<String> warnings,
  }) async {
    try {
      final snap = await orders.aggregate(count()).get();
      return snap.count ?? 0;
    } catch (e, st) {
      assert(() {
        // ignore: avoid_print
        print('DashboardRepository.ordersTotal aggregate: $e\n$st');
        return true;
      }());
      try {
        final qs = await orders.get();
        return qs.docs.length;
      } catch (e2, st2) {
        assert(() {
          // ignore: avoid_print
          print('DashboardRepository.ordersTotal fallback: $e2\n$st2');
          return true;
        }());
        warnings.add(_formatFailure('Could not count all orders.', e2));
        return 0;
      }
    }
  }

  Future<int> _ordersTodayCount({
    required CollectionReference<Map<String, dynamic>> orders,
    required Timestamp dayStart,
    required List<String> warnings,
  }) async {
    try {
      final snap = await orders
          .where('created_at', isGreaterThanOrEqualTo: dayStart)
          .aggregate(count())
          .get();
      return snap.count ?? 0;
    } catch (e, st) {
      assert(() {
        // ignore: avoid_print
        print('DashboardRepository.ordersToday aggregate: $e\n$st');
        return true;
      }());
      try {
        final qs = await orders
            .where('created_at', isGreaterThanOrEqualTo: dayStart)
            .get();
        return qs.docs.length;
      } catch (e2, st2) {
        assert(() {
          // ignore: avoid_print
          print('DashboardRepository.ordersToday fallback: $e2\n$st2');
          return true;
        }());
        warnings.add(_formatFailure(
          'Could not count today’s orders (field: created_at).',
          e2,
        ));
        return 0;
      }
    }
  }

  Future<int> _pendingCount({
    required CollectionReference<Map<String, dynamic>> orders,
    required List<String> warnings,
  }) async {
    final pending = orderStatusKey(OrderStatus.pending);
    try {
      final snap = await orders
          .where('status', isEqualTo: pending)
          .aggregate(count())
          .get();
      return snap.count ?? 0;
    } catch (e, st) {
      assert(() {
        // ignore: avoid_print
        print('DashboardRepository.pending aggregate: $e\n$st');
        return true;
      }());
      try {
        final qs = await orders.where('status', isEqualTo: pending).get();
        return qs.docs.length;
      } catch (e2, st2) {
        assert(() {
          // ignore: avoid_print
          print('DashboardRepository.pending fallback: $e2\n$st2');
          return true;
        }());
        warnings.add(_formatFailure(
          'Could not count pending orders (field: status).',
          e2,
        ));
        return 0;
      }
    }
  }

  Future<int> _ridersCount({
    required CollectionReference<Map<String, dynamic>> users,
    required List<String> warnings,
  }) async {
    try {
      final snap = await users
          .where('role', isEqualTo: userRoleKey(UserRole.rider))
          .aggregate(count())
          .get();
      return snap.count ?? 0;
    } catch (e, st) {
      assert(() {
        // ignore: avoid_print
        print('DashboardRepository.riders aggregate: $e\n$st');
        return true;
      }());
      try {
        final qs = await users
            .where('role', isEqualTo: userRoleKey(UserRole.rider))
            .get();
        return qs.docs.length;
      } catch (e2, st2) {
        assert(() {
          // ignore: avoid_print
          print('DashboardRepository.riders fallback: $e2\n$st2');
          return true;
        }());
        warnings.add(_formatFailure(
          'Could not count riders (users.role).',
          e2,
        ));
        return 0;
      }
    }
  }

  Future<num> _revenueDeliveredTotal({
    required CollectionReference<Map<String, dynamic>> orders,
    required List<String> warnings,
  }) async {
    final delivered = orderStatusKey(OrderStatus.delivered);
    try {
      final snap = await orders
          .where('status', isEqualTo: delivered)
          .aggregate(sum('total_amount'))
          .get();
      return snap.getSum('total_amount') ?? 0;
    } catch (e, st) {
      assert(() {
        // ignore: avoid_print
        print('DashboardRepository.revenueDeliveredTotal aggregate: $e\n$st');
        return true;
      }());
      try {
        final qs = await orders.where('status', isEqualTo: delivered).get();
        num sum = 0;
        for (final doc in qs.docs) {
          sum += _readAmount(doc.data()['total_amount']);
        }
        return sum;
      } catch (e2, st2) {
        assert(() {
          // ignore: avoid_print
          print('DashboardRepository.revenueDeliveredTotal fallback: $e2\n$st2');
          return true;
        }());
        warnings.add(_formatFailure(
          'Could not sum revenue for delivered orders.',
          e2,
        ));
        return 0;
      }
    }
  }

  /// Composite index when available; else today's docs + in-memory filter.
  Future<num> _revenueDeliveredToday({
    required CollectionReference<Map<String, dynamic>> orders,
    required Timestamp dayStart,
    required List<String> warnings,
  }) async {
    final delivered = orderStatusKey(OrderStatus.delivered);
    try {
      final snap = await orders
          .where('status', isEqualTo: delivered)
          .where('created_at', isGreaterThanOrEqualTo: dayStart)
          .aggregate(sum('total_amount'))
          .get();
      return snap.getSum('total_amount') ?? 0;
    } catch (e, st) {
      assert(() {
        // ignore: avoid_print
        print('DashboardRepository.revenueDeliveredToday aggregate: $e\n$st');
        return true;
      }());
      try {
        final qs = await orders
            .where('created_at', isGreaterThanOrEqualTo: dayStart)
            .get();
        num sum = 0;
        for (final doc in qs.docs) {
          final d = doc.data();
          if (d['status'] == delivered) {
            sum += _readAmount(d['total_amount']);
          }
        }
        return sum;
      } catch (e2, st2) {
        assert(() {
          // ignore: avoid_print
          print('DashboardRepository.revenueDeliveredToday fallback: $e2\n$st2');
          return true;
        }());
        warnings.add(_formatFailure(
          'Could not load today’s delivered revenue (created_at / status).',
          e2,
        ));
        return 0;
      }
    }
  }

  Future<DashboardStats> loadStats({DateTime? now}) async {
    final clock = now ?? DateTime.now();
    final dayStart = _startOfLocalDay(clock);

    final orders = _db.collection('orders');
    final users = _db.collection('users');
    final warnings = <String>[];

    final total = await _ordersTotalCount(orders: orders, warnings: warnings);
    final today = await _ordersTodayCount(
      orders: orders,
      dayStart: dayStart,
      warnings: warnings,
    );
    final pending = await _pendingCount(orders: orders, warnings: warnings);
    final riders = await _ridersCount(users: users, warnings: warnings);
    final revTotal =
        await _revenueDeliveredTotal(orders: orders, warnings: warnings);
    final revToday = await _revenueDeliveredToday(
      orders: orders,
      dayStart: dayStart,
      warnings: warnings,
    );

    return DashboardStats(
      ordersTotal: total,
      ordersToday: today,
      pendingOrders: pending,
      ridersRegistered: riders,
      revenueDeliveredTotal: revTotal,
      revenueDeliveredToday: revToday,
      warnings: warnings,
    );
  }
}
