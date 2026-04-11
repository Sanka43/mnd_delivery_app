import 'package:mnd_core/mnd_core.dart';
import 'package:test/test.dart';

void main() {
  test('orderStatusFromKey roundtrip', () {
    expect(orderStatusFromKey('pending'), OrderStatus.pending);
    expect(orderStatusFromKey('invalid'), isNull);
  });

  test('userRoleFromKey roundtrip', () {
    expect(userRoleFromKey('admin'), UserRole.admin);
  });

  test('computeOrderPricing matches spec example', () {
    const settings = GlobalSettings(
      commissionType: CommissionType.fixed,
      commissionValue: 30,
      deliveryFee: 220,
      deliveryCut: 20,
    );
    final snap = computeOrderPricing(itemPrice: 1000, settings: settings);
    expect(snap.commission, 30);
    expect(snap.deliveryFee, 220);
    expect(snap.deliveryCut, 20);
    expect(snap.riderEarning, 200);
    expect(snap.adminEarning, 1050);
    expect(snap.totalAmount, 1250);
  });

  test('validateGlobalSettings catches delivery cut >= fee', () {
    const bad = GlobalSettings(
      commissionType: CommissionType.fixed,
      commissionValue: 10,
      deliveryFee: 100,
      deliveryCut: 100,
    );
    expect(validateGlobalSettings(bad), isNotEmpty);
  });
}
