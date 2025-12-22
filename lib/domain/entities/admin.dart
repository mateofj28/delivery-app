class Admin {
  final String id;
  final String username;
  final String password; // En producción debería estar hasheado

  const Admin({
    required this.id,
    required this.username,
    required this.password,
  });
}
