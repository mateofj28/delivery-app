import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import 'auth_provider.dart';

// Provider para obtener datos del usuario desde Firestore
final userDataProvider = FutureProvider.family<UserEntity?, String>((ref, userId) async {
  try {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists && userDoc.data() != null) {
      return UserEntity.fromMap({
        'id': userDoc.id,
        ...userDoc.data()!,
      });
    }
    return null;
  } catch (e) {
    print('❌ [FIRESTORE] Error al obtener usuario: $e');
    return null;
  }
});

// Provider para obtener todos los usuarios
final allUsersProvider = StreamProvider<List<UserEntity>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return UserEntity.fromMap({
        'id': doc.id,
        ...doc.data(),
      });
    }).toList();
  });
});

// Provider para obtener pedidos del usuario actual
final userOrdersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  
  if (currentUser == null) {
    return Stream.value([]);
  }
  
  return FirebaseFirestore.instance
      .collection('orders')
      .where('userId', isEqualTo: currentUser.id)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();
  });
});

// Notifier para manejar operaciones de Firestore
class FirestoreNotifier extends StateNotifier<AsyncValue<void>> {
  FirestoreNotifier() : super(const AsyncValue.data(null));

  Future<void> updateUser(UserEntity user) async {
    state = const AsyncValue.loading();
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.id).update({
        ...user.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      state = const AsyncValue.data(null);
      print('✅ [FIRESTORE] Usuario actualizado');
    } catch (e) {
      print('❌ [FIRESTORE] Error al actualizar usuario: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> createOrder(Map<String, dynamic> orderData) async {
    state = const AsyncValue.loading();
    try {
      await FirebaseFirestore.instance.collection('orders').add({
        ...orderData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      state = const AsyncValue.data(null);
      print('✅ [FIRESTORE] Pedido creado');
    } catch (e) {
      print('❌ [FIRESTORE] Error al crear pedido: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    state = const AsyncValue.loading();
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      state = const AsyncValue.data(null);
      print('✅ [FIRESTORE] Estado del pedido actualizado');
    } catch (e) {
      print('❌ [FIRESTORE] Error al actualizar estado: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Provider del FirestoreNotifier
final firestoreNotifierProvider = StateNotifierProvider<FirestoreNotifier, AsyncValue<void>>((ref) {
  return FirestoreNotifier();
});