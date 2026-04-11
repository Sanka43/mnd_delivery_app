/// App role (stored on user profile / custom claims).
enum UserRole {
  customer,
  rider,
  shop,
  admin,
}

String userRoleKey(UserRole r) => r.name;

UserRole? userRoleFromKey(String? key) {
  if (key == null) return null;
  final normalized = key.trim().toLowerCase();
  if (normalized.isEmpty) return null;
  for (final v in UserRole.values) {
    if (v.name == normalized) return v;
  }
  return null;
}
