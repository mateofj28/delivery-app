import '../entities/business.dart';

/// Repository interface para operaciones de negocios
/// Sigue el principio de Segregación de Interfaces (ISP)
abstract class BusinessRepository {
  // CRUD de Negocios
  Future<String> createBusiness(Business business);
  Future<Business?> getBusinessById(String businessId);
  Future<List<Business>> getAllBusinesses();
  Future<List<Business>> getActiveBusinesses();
  Future<void> updateBusiness(Business business);
  Future<void> deleteBusiness(String businessId);
  Future<void> toggleBusinessStatus(String businessId, bool isActive);
  
  // Stream para actualizaciones en tiempo real
  Stream<List<Business>> watchAllBusinesses();
  Stream<List<Business>> watchActiveBusinesses();
  Stream<Business?> watchBusiness(String businessId);
}