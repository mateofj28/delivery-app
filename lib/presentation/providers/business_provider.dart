import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/business_repository_impl.dart';
import '../../domain/entities/business.dart';
import '../../domain/repositories/business_repository.dart';

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  return BusinessRepositoryImpl();
});

final businessListProvider = FutureProvider<List<Business>>((ref) async {
  final repository = ref.read(businessRepositoryProvider);
  return repository.getBusinesses();
});

final selectedBusinessProvider = StateProvider<Business?>((ref) => null);
