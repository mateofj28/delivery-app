import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/business.dart';
import '../../providers/admin_provider.dart';
import '../../providers/product_management_provider.dart';
import '../../providers/business_management_provider.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final String businessId;
  final String? productId;

  const ProductFormScreen({
    super.key,
    required this.businessId,
    this.productId,
  });

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _isAvailable = true;
  bool _isLoading = false;

  Product? _existingProduct;
  String? _businessName;

  final List<String> _commonCategories = [
    'Platos principales',
    'Entradas',
    'Bebidas',
    'Postres',
    'Acompañamientos',
    'Especiales',
    'Promociones',
  ];

  @override
  void initState() {
    super.initState();
    // Retrasar la carga de datos hasta después de que el widget tree termine de construirse
    Future.microtask(() => _loadData());
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Cargar productos del negocio
      await ref
          .read(productManagementProvider.notifier)
          .loadProductsByBusiness(widget.businessId);

      if (widget.productId != null) {
        final repository = ref.read(productRepositoryProvider);
        _existingProduct = await repository.getProductById(
          widget.businessId,
          widget.productId!,
        );

        if (_existingProduct != null) {
          _nameController.text = _existingProduct!.name;
          _priceController.text = _existingProduct!.price.toString();
          _descriptionController.text = _existingProduct!.description;
          _categoryController.text = _existingProduct!.category ?? '';
          _imageUrlController.text = _existingProduct!.imageUrl ?? '';
          _isAvailable = _existingProduct!.isAvailable;
        }
      }

      // Obtener nombre del negocio
      final businessRepository = ref.read(businessRepositoryProvider);
      final business = await businessRepository.getBusinessById(
        widget.businessId,
      );
      _businessName = business?.name ?? 'Negocio';
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final product = widget.productId != null
            ? _existingProduct!.copyWith(
                name: _nameController.text.trim(),
                price: double.parse(_priceController.text.trim()),
                description: _descriptionController.text.trim(),
                category: _categoryController.text.trim().isEmpty
                    ? null
                    : _categoryController.text.trim(),
                isAvailable: _isAvailable,
                imageUrl: _imageUrlController.text.trim().isEmpty
                    ? null
                    : _imageUrlController.text.trim(),
              )
            : Product.create(
                name: _nameController.text.trim(),
                price: double.parse(_priceController.text.trim()),
                description: _descriptionController.text.trim(),
                category: _categoryController.text.trim().isEmpty
                    ? null
                    : _categoryController.text.trim(),
                imageUrl: _imageUrlController.text.trim().isEmpty
                    ? null
                    : _imageUrlController.text.trim(),
              );

        bool success;
        if (widget.productId != null) {
          success = await ref
              .read(productManagementProvider.notifier)
              .updateProduct(widget.businessId, product);
        } else {
          final productId = await ref
              .read(productManagementProvider.notifier)
              .createProduct(widget.businessId, product);
          success = productId != null;
        }

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.productId != null
                      ? 'Producto actualizado exitosamente'
                      : 'Producto creado exitosamente',
                ),
                backgroundColor: Colors.green,
              ),
            );
            context.go('/admin/business/${widget.businessId}/products');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.productId != null
                      ? 'Error al actualizar el producto'
                      : 'Error al crear el producto',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seleccionar Categoría',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: _commonCategories
                    .map(
                      (category) => ListTile(
                        title: Text(category),
                        onTap: () {
                          _categoryController.text = category;
                          Navigator.of(context).pop();
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = ref.watch(adminProvider);

    if (admin == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/admin/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isLoading && widget.productId != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Cargando...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.productId != null ? 'Editar Producto' : 'Crear Producto',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.go('/admin/business/${widget.businessId}/products'),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información del Producto',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Negocio: ${_businessName ?? 'Cargando...'}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del producto *',
                        hintText: 'Ej: Pizza Margherita',
                        prefixIcon: Icon(Icons.restaurant_menu),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es requerido';
                        }
                        if (value.trim().length < 2) {
                          return 'El nombre debe tener al menos 2 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Precio *',
                        hintText: '25000',
                        prefixIcon: Icon(Icons.attach_money),
                        suffixText: 'COP',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El precio es requerido';
                        }
                        final price = double.tryParse(value);
                        if (price == null || price <= 0) {
                          return 'Ingresa un precio válido mayor a 0';
                        }
                        if (price > 1000000) {
                          return 'El precio no puede ser mayor a \$1.000.000';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción *',
                        hintText: 'Describe el producto...',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La descripción es requerida';
                        }
                        if (value.trim().length < 10) {
                          return 'La descripción debe tener al menos 10 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _categoryController,
                      decoration: InputDecoration(
                        labelText: 'Categoría (opcional)',
                        hintText: 'Ej: Platos principales',
                        prefixIcon: const Icon(Icons.category),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_drop_down),
                          onPressed: _showCategoryPicker,
                        ),
                      ),
                      readOnly: true,
                      onTap: _showCategoryPicker,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL de imagen (opcional)',
                        hintText: 'https://ejemplo.com/imagen.jpg',
                        prefixIcon: Icon(Icons.image),
                      ),
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final uri = Uri.tryParse(value.trim());
                          if (uri == null || !uri.hasScheme) {
                            return 'Ingresa una URL válida';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SwitchListTile(
                      title: const Text('Producto disponible'),
                      subtitle: const Text(
                        'Los clientes pueden ordenar este producto',
                      ),
                      value: _isAvailable,
                      onChanged: (value) {
                        setState(() {
                          _isAvailable = value;
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppColors.accent,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Consejos',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accent,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '• Usa nombres descriptivos y atractivos\n'
                            '• Incluye ingredientes principales en la descripción\n'
                            '• Las categorías ayudan a organizar el menú\n'
                            '• Las imágenes aumentan las ventas',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProduct,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: AppColors.onAccent,
                          )
                        : Text(
                            widget.productId != null
                                ? 'Actualizar Producto'
                                : 'Crear Producto',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
