import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/admin.dart';

class AdminNotifier extends StateNotifier<Admin?> {
  AdminNotifier() : super(null);

  bool login(String username, String password) {
    // Credenciales hardcodeadas para demo
    if (username == 'admin' && password == 'admin123') {
      state = const Admin(
        id: '1',
        username: 'admin',
        password: 'admin123',
      );
      return true;
    }
    return false;
  }

  void logout() {
    state = null;
  }

  bool get isLoggedIn => state != null;
}

final adminProvider = StateNotifierProvider<AdminNotifier, Admin?>((ref) {
  return AdminNotifier();
});
