/// How platform commission is applied (`settings/global.commission_type`).
enum CommissionType {
  fixed,
  percentage,
}

String commissionTypeKey(CommissionType t) => t.name;

CommissionType? commissionTypeFromKey(String? key) {
  if (key == null) return null;
  for (final v in CommissionType.values) {
    if (v.name == key) return v;
  }
  return null;
}
