import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/firestore_repository.dart';

class FirestoreRepositoryImpl implements FirestoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> createUser(UserEntity user) async {
    try {
      print('🔵 [FIRESTORE_REPO] Iniciando creación de usuario: ${user.id}');
      print('🔵 [FIRESTORE_REPO] Datos a guardar: ${user.toMap()}');
      
      await _firestore.collection('users').doc(user.id).set({
        ...user.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ [FIRESTORE_REPO] Usuario creado exitosamente en Firestore');
    } catch (e) {
      print('❌ [FIRESTORE_REPO] Error detallado: $e');
      print('❌ [FIRESTORE_REPO] Tipo de error: ${e.runtimeType}');
      throw Exception('Error al crear usuario: $e');
    }
  }

  @override
  Future<UserEntity?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserEntity.fromMap({
          'id': doc.id,
          ...doc.data()!,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener usuario: $e');
    }
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    try {
      await _firestore.collection('users').doc(user.id).update({
        ...user.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al actualizar usuario: $e');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception('Error al eliminar usuario: $e');
    }
  }

  @override
  Stream<List<UserEntity>> getAllUsers() {
    return _firestore
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
  }

  // Métodos adicionales para colecciones específicas de tu app
  @override
  Future<void> createOrder(Map<String, dynamic> orderData) async {
    try {
      await _firestore.collection('orders').add({
        ...orderData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al crear pedido: $e');
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
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
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al actualizar estado del pedido: $e');
    }
  }
}