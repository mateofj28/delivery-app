import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/order.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/business_list_screen.dart';
import '../../presentation/screens/products_screen.dart';
import '../../presentation/screens/cart_screen.dart';
import '../../presentation/screens/order_form_screen.dart';
import '../../presentation/screens/confirmation_screen.dart';
import '../../presentation/screens/admin/admin_login_screen.dart';
import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/admin/business_management_screen.dart';
import '../../presentation/screens/admin/business_form_screen.dart';
import '../../presentation/screens/admin/product_management_screen.dart';
import '../../presentation/screens/admin/product_form_screen.dart';

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

    // Rutas de administración
    GoRoute(
      path: '/admin/login',
      builder: (context, state) => const AdminLoginScreen(),
    ),
    GoRoute(
      path: '/admin/dashboard',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/admin/businesses',
      builder: (context, state) => const BusinessManagementScreen(),
    ),
    GoRoute(
      path: '/admin/business/create',
      builder: (context, state) => const BusinessFormScreen(),
    ),
    GoRoute(
      path: '/admin/business/:businessId/edit',
      builder: (context, state) {
        final businessId = state.pathParameters['businessId']!;
        return BusinessFormScreen(businessId: businessId);
      },
    ),
    GoRoute(
      path: '/admin/business/:businessId/products',
      builder: (context, state) {
        final businessId = state.pathParameters['businessId']!;
        return ProductManagementScreen(businessId: businessId);
      },
    ),
    GoRoute(
      path: '/admin/business/:businessId/product/create',
      builder: (context, state) {
        final businessId = state.pathParameters['businessId']!;
        return ProductFormScreen(businessId: businessId);
      },
    ),
    GoRoute(
      path: '/admin/business/:businessId/product/:productId/edit',
      builder: (context, state) {
        final businessId = state.pathParameters['businessId']!;
        final productId = state.pathParameters['productId']!;
        return ProductFormScreen(
          businessId: businessId,
          productId: productId,
        );
      },
    ),
  ],
);
