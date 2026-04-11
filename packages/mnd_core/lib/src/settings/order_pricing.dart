import 'commission_type.dart';
import 'global_settings.dart';

/// Immutable snapshot stored on each order — never re-derived from [GlobalSettings].
class OrderPricingSnapshot {
  const OrderPricingSnapshot({
    required this.itemPrice,
    required this.commission,
    required this.deliveryFee,
    required this.deliveryCut,
    required this.riderEarning,
    required this.adminEarning,
    required this.totalAmount,
  });

  final num itemPrice;
  final num commission;
  final num deliveryFee;
  final num deliveryCut;
  final num riderEarning;
  final num adminEarning;
  final num totalAmount;

  Map<String, dynamic> toOrderFields() {
    return {
      'item_price': itemPrice,
      'commission': commission,
      'delivery_fee': deliveryFee,
      'delivery_cut': deliveryCut,
      'rider_earning': riderEarning,
      'admin_earning': adminEarning,
      'total_amount': totalAmount,
    };
  }

  factory OrderPricingSnapshot.fromMap(Map<String, dynamic> map) {
    num req(String k) {
      final v = map[k];
      if (v is num) return v;
      return num.parse(v.toString());
    }

    return OrderPricingSnapshot(
      itemPrice: req('item_price'),
      commission: req('commission'),
      deliveryFee: req('delivery_fee'),
      deliveryCut: req('delivery_cut'),
      riderEarning: req('rider_earning'),
      adminEarning: req('admin_earning'),
      totalAmount: req('total_amount'),
    );
  }
}

/// Rounds money to two decimals (LKR).
num _roundMoney(num n) => (n * 100).round() / 100;

num computeCommission({
  required num itemPrice,
  required CommissionType commissionType,
  required num commissionValue,
}) {
  switch (commissionType) {
    case CommissionType.fixed:
      return _roundMoney(commissionValue);
    case CommissionType.percentage:
      return _roundMoney(itemPrice * commissionValue / 100);
  }
}

/// Builds pricing for a new order from current [settings] and [itemPrice].
OrderPricingSnapshot computeOrderPricing({
  required num itemPrice,
  required GlobalSettings settings,
}) {
  final commission = computeCommission(
    itemPrice: itemPrice,
    commissionType: settings.commissionType,
    commissionValue: settings.commissionValue,
  );
  final deliveryFee = _roundMoney(settings.deliveryFee);
  final deliveryCut = _roundMoney(settings.deliveryCut);
  final riderEarning = _roundMoney(deliveryFee - deliveryCut);
  final totalAmount = _roundMoney(itemPrice + commission + deliveryFee);
  final adminEarning = _roundMoney(itemPrice + commission + deliveryCut);

  return OrderPricingSnapshot(
    itemPrice: _roundMoney(itemPrice),
    commission: commission,
    deliveryFee: deliveryFee,
    deliveryCut: deliveryCut,
    riderEarning: riderEarning,
    adminEarning: adminEarning,
    totalAmount: totalAmount,
  );
}

/// Validation for editable global settings (before save).
List<String> validateGlobalSettings(GlobalSettings s) {
  final errors = <String>[];

  if (s.commissionValue < 0) {
    errors.add('Commission must not be negative.');
  }

  if (s.commissionType == CommissionType.percentage) {
    if (s.commissionValue < 0 || s.commissionValue > 100) {
      errors.add('Percentage must be between 0 and 100.');
    }
  }

  if (s.deliveryCut >= s.deliveryFee) {
    errors.add('Delivery cut must be less than delivery fee.');
  }

  if (s.deliveryFee < 0) {
    errors.add('Delivery fee must not be negative.');
  }

  if (s.deliveryCut < 0) {
    errors.add('Delivery cut must not be negative.');
  }

  return errors;
}
