import '../entities/user_entity.dart';

abstract class FirestoreRepository {
  // User operations
  Future<void> createUser(UserEntity user);
  Future<UserEntity?> getUser(String userId);
  Future<void> updateUser(UserEntity user);
  Future<void> deleteUser(String userId);
  Stream<List<UserEntity>> getAllUsers();
  
  // Order operations (específico para tu app de delivery)
  Future<void> createOrder(Map<String, dynamic> orderData);
  Stream<List<Map<String, dynamic>>> getUserOrders(String userId);
  Future<void> updateOrderStatus(String orderId, String status);
}