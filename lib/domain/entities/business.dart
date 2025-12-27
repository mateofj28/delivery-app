class Business {
  final String id;
  final String name;
  final String icon;
  final String whatsappNumber;
  final List<Product> products;
  final bool isActive;
  final String? description;
  final String? address;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Business({
    required this.id,
    required this.name,
    required this.icon,
    required this.whatsappNumber,
    required this.products,
    this.isActive = true,
    this.description,
    this.address,
    required this.createdAt,
    required this.updatedAt,
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
    DateTime? createdAt,
    DateTime? updatedAt,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Serialización para Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'whatsappNumber': whatsappNumber,
      'products': products.map((product) => product.toJson()).toList(),
      'isActive': isActive,
      'description': description,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Deserialización desde Firestore
  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      whatsappNumber: json['whatsappNumber'] as String,
      products: (json['products'] as List<dynamic>?)
              ?.map((productJson) => Product.fromJson(productJson as Map<String, dynamic>))
              .toList() ??
          [],
      isActive: json['isActive'] as bool? ?? true,
      description: json['description'] as String?,
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Factory para crear nuevo negocio
  factory Business.create({
    required String name,
    required String icon,
    required String whatsappNumber,
    String? description,
    String? address,
  }) {
    final now = DateTime.now();
    return Business(
      id: '', // Se asignará por Firestore
      name: name,
      icon: icon,
      whatsappNumber: whatsappNumber,
      products: [],
      isActive: true,
      description: description,
      address: address,
      createdAt: now,
      updatedAt: now,
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
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    this.category,
    this.isAvailable = true,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    String? category,
    bool? isAvailable,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Serialización para Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'category': category,
      'isAvailable': isAvailable,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Deserialización desde Firestore
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      category: json['category'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Factory para crear nuevo producto
  factory Product.create({
    required String name,
    required double price,
    required String description,
    String? category,
    String? imageUrl,
  }) {
    final now = DateTime.now();
    return Product(
      id: '', // Se asignará por Firestore
      name: name,
      price: price,
      description: description,
      category: category,
      isAvailable: true,
      imageUrl: imageUrl,
      createdAt: now,
      updatedAt: now,
    );
  }
}
