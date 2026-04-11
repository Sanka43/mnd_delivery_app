import 'commission_type.dart';

/// Firestore document: `settings/global`
class GlobalSettings {
  const GlobalSettings({
    required this.commissionType,
    required this.commissionValue,
    required this.deliveryFee,
    required this.deliveryCut,
    this.lastUpdated,
  });

  final CommissionType commissionType;
  final num commissionValue;
  final num deliveryFee;
  final num deliveryCut;
  final DateTime? lastUpdated;

  /// [lastUpdated] must be supplied by the app when reading Firestore `Timestamp`.
  factory GlobalSettings.fromMap(
    Map<String, dynamic> map, {
    DateTime? lastUpdated,
  }) {
    final type = commissionTypeFromKey(map['commission_type'] as String?) ??
        CommissionType.fixed;
    return GlobalSettings(
      commissionType: type,
      commissionValue: _asNum(map['commission_value']) ?? 0,
      deliveryFee: _asNum(map['delivery_fee']) ?? 0,
      deliveryCut: _asNum(map['delivery_cut']) ?? 0,
      lastUpdated: lastUpdated,
    );
  }

  Map<String, dynamic> toMap({Object? lastUpdatedField}) {
    return {
      'commission_type': commissionTypeKey(commissionType),
      'commission_value': commissionValue,
      'delivery_fee': deliveryFee,
      'delivery_cut': deliveryCut,
      if (lastUpdatedField != null) 'last_updated': lastUpdatedField,
    };
  }

  static num? _asNum(Object? v) {
    if (v == null) return null;
    if (v is num) return v;
    return num.tryParse(v.toString());
  }
}
