import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/business.dart';
import '../../domain/repositories/business_repository.dart';

/// Implementación concreta del repositorio de negocios con Firestore
/// Sigue el principio de Inversión de Dependencias (DIP)
class BusinessRepositoryImpl implements BusinessRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'businesses';

  BusinessRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<String> createBusiness(Business business) async {
    try {
      final docRef = _firestore.collection(_collection).doc();
      final businessWithId = business.copyWith(
        id: docRef.id,
        updatedAt: DateTime.now(),
      );

      await docRef.set(businessWithId.toJson());
      return docRef.id;
    } catch (e) {
      throw _handleFirestoreException(e, 'Error creating business');
    }
  }

  @override
  Future<Business?> getBusinessById(String businessId) async {
    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(businessId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return Business.fromJson(doc.data()!);
    } catch (e) {
      throw _handleFirestoreException(e, 'Error getting business');
    }
  }

  @override
  Future<List<Business>> getAllBusinesses() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();

      final businesses = querySnapshot.docs
          .map((doc) => Business.fromJson(doc.data()))
          .toList();

      // Ordenar en memoria por createdAt descendente
      businesses.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return businesses;
    } catch (e) {
      throw _handleFirestoreException(e, 'Error getting all businesses');
    }
  }

  @override
  Future<List<Business>> getActiveBusinesses() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      final businesses = querySnapshot.docs
          .map((doc) => Business.fromJson(doc.data()))
          .toList();

      // Ordenar en memoria por createdAt descendente
      businesses.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return businesses;
    } catch (e) {
      throw _handleFirestoreException(e, 'Error getting active businesses');
    }
  }

  @override
  Future<void> updateBusiness(Business business) async {
    try {
      final updatedBusiness = business.copyWith(updatedAt: DateTime.now());
      await _firestore
          .collection(_collection)
          .doc(business.id)
          .update(updatedBusiness.toJson());
    } catch (e) {
      throw _handleFirestoreException(e, 'Error updating business');
    }
  }

  @override
  Future<void> deleteBusiness(String businessId) async {
    try {
      await _firestore.collection(_collection).doc(businessId).delete();
    } catch (e) {
      throw _handleFirestoreException(e, 'Error deleting business');
    }
  }

  @override
  Future<void> toggleBusinessStatus(String businessId, bool isActive) async {
    try {
      await _firestore.collection(_collection).doc(businessId).update({
        'isActive': isActive,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw _handleFirestoreException(e, 'Error toggling business status');
    }
  }

  @override
  Stream<List<Business>> watchAllBusinesses() {
    try {
      return _firestore.collection(_collection).snapshots().map((snapshot) {
        final businesses = snapshot.docs
            .map((doc) => Business.fromJson(doc.data()))
            .toList();

        // Ordenar en memoria por createdAt descendente
        businesses.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return businesses;
      });
    } catch (e) {
      throw _handleFirestoreException(e, 'Error watching all businesses');
    }
  }

  @override
  Stream<List<Business>> watchActiveBusinesses() {
    try {
      return _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
            final businesses = snapshot.docs
                .map((doc) => Business.fromJson(doc.data()))
                .toList();

            // Ordenar en memoria por createdAt descendente
            businesses.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return businesses;
          });
    } catch (e) {
      throw _handleFirestoreException(e, 'Error watching active businesses');
    }
  }

  @override
  Stream<Business?> watchBusiness(String businessId) {
    try {
      return _firestore.collection(_collection).doc(businessId).snapshots().map(
        (doc) {
          if (!doc.exists || doc.data() == null) {
            return null;
          }
          return Business.fromJson(doc.data()!);
        },
      );
    } catch (e) {
      throw _handleFirestoreException(e, 'Error watching business');
    }
  }

  /// Manejo centralizado de excepciones de Firestore
  Exception _handleFirestoreException(dynamic error, String message) {
    if (error is FirebaseException) {
      return Exception('$message: ${error.message}');
    }
    return Exception('$message: $error');
  }
}
