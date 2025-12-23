import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import 'auth_provider.dart';
import 'firestore_provider.dart';

// Provider para obtener el perfil completo del usuario actual
final currentUserProfileProvider = FutureProvider<UserEntity?>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  
  if (currentUser == null) {
    return null;
  }
  
  try {
    // Intentar obtener datos completos desde Firestore
    final userFromFirestore = await ref.read(userDataProvider(currentUser.id).future);
    
    if (userFromFirestore != null) {
      print('✅ [PROFILE] Datos obtenidos desde Firestore: ${userFromFirestore.name}');
      return userFromFirestore;
    }
  } catch (e) {
    print('⚠️ [PROFILE] Error al obtener datos de Firestore: $e');
  }
  
  // Fallback: usar datos de Firebase Auth
  print('⚠️ [PROFILE] Usando datos de Firebase Auth como fallback');
  return currentUser;
});

// Provider para el nombre del usuario actual
final currentUserNameProvider = Provider<String>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  final userProfile = ref.watch(currentUserProfileProvider);
  
  return userProfile.when(
    data: (profile) => profile?.name ?? currentUser?.email ?? 'Usuario',
    loading: () => currentUser?.name ?? currentUser?.email ?? 'Usuario',
    error: (_, __) => currentUser?.name ?? currentUser?.email ?? 'Usuario',
  );
});