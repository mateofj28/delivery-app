import '../../domain/entities/business.dart';
import '../../domain/repositories/business_repository.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  @override
  Future<List<Business>> getBusinesses() async {
    // Simulamos datos estáticos
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      const Business(
        id: '1',
        name: 'Pizza Express',
        icon: '🍕',
        whatsappNumber: '+573026699574',
        description: 'Las mejores pizzas artesanales de la ciudad',
        address: 'Calle 123 #45-67, Centro',
        isActive: true,
        products: [
          Product(
            id: '1',
            name: 'Pizza Margherita',
            price: 25000,
            description: 'Pizza clásica con tomate, mozzarella y albahaca',
            category: 'Platos principales',
            isAvailable: true,
          ),
          Product(
            id: '2',
            name: 'Pizza Pepperoni',
            price: 28000,
            description: 'Pizza con pepperoni y queso mozzarella',
            category: 'Platos principales',
            isAvailable: true,
          ),
          Product(
            id: '3',
            name: 'Pizza Hawaiana',
            price: 30000,
            description: 'Pizza con jamón, piña y queso',
            category: 'Platos principales',
            isAvailable: true,
          ),
        ],
      ),
      const Business(
        id: '2',
        name: 'Burger House',
        icon: '🍔',
        whatsappNumber: '+573026699574',
        description: 'Hamburguesas gourmet y papas crujientes',
        address: 'Carrera 98 #76-54, Norte',
        isActive: true,
        products: [
          Product(
            id: '4',
            name: 'Hamburguesa Clásica',
            price: 18000,
            description: 'Carne, lechuga, tomate, cebolla y salsas',
            category: 'Platos principales',
            isAvailable: true,
          ),
          Product(
            id: '5',
            name: 'Hamburguesa BBQ',
            price: 22000,
            description: 'Carne, queso, cebolla caramelizada y salsa BBQ',
            category: 'Platos principales',
            isAvailable: true,
          ),
          Product(
            id: '6',
            name: 'Papas Fritas',
            price: 8000,
            description: 'Papas fritas crujientes',
            category: 'Acompañamientos',
            isAvailable: true,
          ),
        ],
      ),
      const Business(
        id: '3',
        name: 'Sushi Zen',
        icon: '🍣',
        whatsappNumber: '+573026699574',
        description: 'Auténtica comida japonesa',
        address: 'Avenida 15 #23-89, Sur',
        isActive: true,
        products: [
          Product(
            id: '7',
            name: 'Roll California',
            price: 35000,
            description: 'Salmón, aguacate, pepino y ajonjolí',
            category: 'Platos principales',
            isAvailable: true,
          ),
          Product(
            id: '8',
            name: 'Roll Philadelphia',
            price: 38000,
            description: 'Salmón, queso crema y cebollín',
            category: 'Platos principales',
            isAvailable: true,
          ),
          Product(
            id: '9',
            name: 'Sopa Miso',
            price: 12000,
            description: 'Sopa tradicional japonesa',
            category: 'Entradas',
            isAvailable: true,
          ),
        ],
      ),
    ];
  }
}
