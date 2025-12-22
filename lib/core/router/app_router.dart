import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/order.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/business_list_screen.dart';
import '../../presentation/screens/products_screen.dart';
import '../../presentation/screens/cart_screen.dart';
import '../../presentation/screens/order_form_screen.dart';
import '../../presentation/screens/confirmation_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/businesses',
      builder: (context, state) => const BusinessListScreen(),
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductsScreen(),
    ),
    GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
    GoRoute(
      path: '/order-form',
      builder: (context, state) => const OrderFormScreen(),
    ),
    GoRoute(
      path: '/confirmation',
      builder: (context, state) {
        final order = state.extra as Order?;
        if (order == null) {
          return const Scaffold(
            body: Center(
              child: Text('Error: No se encontró información del pedido'),
            ),
          );
        }
        return ConfirmationScreen(order: order);
      },
    ),
  ],
);
