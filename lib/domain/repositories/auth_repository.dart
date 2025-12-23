import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  UserEntity? get currentUser;
  
  Future<UserEntity?> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  
  Future<UserEntity?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });
  
  Future<void> signOut();
  Future<void> resetPassword(String email);
}