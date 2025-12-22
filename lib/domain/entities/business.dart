class Business {
  final String id;
  final String name;
  final String icon;
  final String whatsappNumber;
  final List<Product> products;

  const Business({
    required this.id,
    required this.name,
    required this.icon,
    required this.whatsappNumber,
    required this.products,
  });
}

class Product {
  final String id;
  final String name;
  final double price;
  final String description;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
  });
}
