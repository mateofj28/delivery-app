import '../entities/business.dart';

abstract class BusinessRepository {
  Future<List<Business>> getBusinesses();
}
