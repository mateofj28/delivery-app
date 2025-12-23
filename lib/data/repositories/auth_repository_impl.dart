import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Stream<UserEntity?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user != null) {
        print('🔵 [AUTH_REPO] Usuario autenticado: ${user.uid}');
        return UserEntity(
          id: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? '',
        );
      }
      print('🔵 [AUTH_REPO] Usuario no autenticado');
      return null;
    });
  }

  @override
  Future<UserEntity?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('🔵 [AUTH_REPO] Iniciando login para: $email');
      
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = credential.user;
      if (user != null) {
        print('✅ [AUTH_REPO] Login exitoso: ${user.uid}');
        
        return UserEntity(
          id: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? '',
        );
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('❌ [AUTH_REPO] FirebaseAuthException en login: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ [AUTH_REPO] Error general en login: $e');
      rethrow;
    }
  }

  @override
  Future<UserEntity?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('🔵 [AUTH_REPO] Creando usuario en Firebase Auth...');
      
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('✅ [AUTH_REPO] Credencial creada: ${credential.user?.uid}');
      
      final user = credential.user;
      if (user != null) {
        // Crear la entidad sin tocar el perfil de Firebase
        final userEntity = UserEntity(
          id: user.uid,
          email: user.email ?? '',
          name: name,
        );
        
        print('✅ [AUTH_REPO] UserEntity creado: ${userEntity.toMap()}');
        return userEntity;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('❌ [AUTH_REPO] FirebaseAuthException: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ [AUTH_REPO] Error general: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  UserEntity? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return UserEntity(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
      );
    }
    return null;
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No se encontró un usuario con ese email.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese email.';
      case 'weak-password':
        return 'La contraseña es muy débil.';
      case 'invalid-email':
        return 'El email no es válido.';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }
}