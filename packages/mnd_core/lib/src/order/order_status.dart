/// Locked order lifecycle for MND Delivery (Firestore `orders.status`).
enum OrderStatus {
  pending,
  confirmed,
  assignedToShop,
  preparing,
  ready,
  assignedToRider,
  onTheWay,
  delivered,
  cancelled,
}

String orderStatusKey(OrderStatus s) => s.name;

OrderStatus? orderStatusFromKey(String? key) {
  if (key == null) return null;
  for (final v in OrderStatus.values) {
    if (v.name == key) return v;
  }
  return null;
}
