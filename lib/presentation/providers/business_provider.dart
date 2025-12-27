import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/business.dart';

/// Provider simple para el negocio seleccionado por el cliente
final selectedBusinessProvider = StateProvider<Business?>((ref) => null);
