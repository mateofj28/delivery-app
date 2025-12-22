class Business {
  final String id;
  final String name;
  final String icon;
  final String whatsappNumber;
  final List<Product> products;
  final bool isActive;
  final String? description;
  final String? address;

  const Business({
    required this.id,
    required this.name,
    required this.icon,
    required this.whatsappNumber,
    required this.products,
    this.isActive = true,
    this.description,
    this.address,
  });

  Business copyWith({
    String? id,
    String? name,
    String? icon,
    String? whatsappNumber,
    List<Product>? products,
    bool? isActive,
    String? description,
    String? address,
  }) {
    return Business(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      products: products ?? this.products,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
      address: address ?? this.address,
    );
  }
}

class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final String? category;
  final bool isAvailable;
  final String? imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    this.category,
    this.isAvailable = true,
    this.imageUrl,
  });

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    String? category,
    bool? isAvailable,
    String? imageUrl,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
