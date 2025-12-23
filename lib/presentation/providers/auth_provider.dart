import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

// Provider del estado de autenticación - SIMPLIFICADO
final authStateProvider = StreamProvider<UserEntity?>((ref) {
  return Stream.value(null); // Deshabilitado por ahora
});

// Provider del usuario actual
final currentUserProvider = Provider<UserEntity?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Provider para el estado de carga de autenticación
final authLoadingProvider = StateProvider<bool>((ref) => false);

// Provider para mensajes de error
final authErrorProvider = StateProvider<String?>((ref) => null);

// Notifier para manejar las acciones de autenticación
class AuthNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  AuthNotifier() : super(const AsyncValue.data(null));

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      print('🔵 [AUTH] Iniciando login para: $email');
      
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        final user = credential.user!;
        
        // Intentar obtener nombre desde Firestore
        String userName = '';
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          
          if (userDoc.exists && userDoc.data() != null) {
            userName = userDoc.data()!['name'] ?? '';
          }
        } catch (e) {
          print('⚠️ [AUTH] No se pudo obtener nombre de Firestore: $e');
        }
        
        final userEntity = UserEntity(
          id: user.uid,
          email: user.email ?? '',
          name: userName.isNotEmpty ? userName : (user.displayName ?? ''),
        );
        
        state = AsyncValue.data(userEntity);
        print('✅ [AUTH] Login exitoso');
      }
    } on FirebaseAuthException catch (e) {
      print('❌ [AUTH] Error en login: ${e.code} - ${e.message}');
      String errorMessage = _getErrorMessage(e.code);
      state = AsyncValue.error(errorMessage, StackTrace.current);
    } catch (e) {
      print('❌ [AUTH] Error general en login: $e');
      state = AsyncValue.error('Error de login: $e', StackTrace.current);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncValue.loading();
    
    UserCredential? userCredential;
    
    try {
      print('🔵 [AUTH] Iniciando registro para: $email');
      
      // Paso 1: Crear usuario - SIN VARIABLES INTERMEDIAS
      userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('✅ [AUTH] Usuario creado: ${userCredential.user?.uid}');
      
    } catch (e) {
      print('❌ [AUTH] Error al crear usuario: $e');
      state = AsyncValue.error('Error al crear usuario: $e', StackTrace.current);
      return;
    }
    
    // Paso 2: Verificar que el usuario existe
    if (userCredential.user == null) {
      state = AsyncValue.error('Error: Usuario no creado', StackTrace.current);
      return;
    }
    
    final uid = userCredential.user!.uid;
    final userEmail = userCredential.user!.email ?? email;
    
    try {
      print('🔵 [FIRESTORE] Creando documento...');
      
      // Paso 3: Crear documento en Firestore - SIN VARIABLES INTERMEDIAS
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'id': uid,
        'email': userEmail,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ [FIRESTORE] Documento creado');
      
    } catch (e) {
      print('⚠️ [FIRESTORE] Error (continuando): $e');
    }
    
    // Paso 4: Crear UserEntity y actualizar estado
    final userEntity = UserEntity(
      id: uid,
      email: userEmail,
      name: name,
    );
    
    state = AsyncValue.data(userEntity);
    print('✅ [AUTH] Registro completado exitosamente');
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese email';
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'invalid-email':
        return 'Email inválido';
      default:
        return 'Error de registro: $code';
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      state = const AsyncValue.data(null);
      print('✅ [AUTH] Logout exitoso');
    } catch (e) {
      print('❌ [AUTH] Error en logout: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      print('✅ [AUTH] Email de recuperación enviado');
    } catch (e) {
      print('❌ [AUTH] Error al enviar email de recuperación: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Provider del AuthNotifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserEntity?>>((ref) {
  return AuthNotifier();
});