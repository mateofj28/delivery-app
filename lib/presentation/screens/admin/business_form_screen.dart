import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/business.dart';
import '../../providers/admin_provider.dart';
import '../../providers/business_provider.dart';

class BusinessFormScreen extends ConsumerStatefulWidget {
  final String? businessId;

  const BusinessFormScreen({
    super.key,
    this.businessId,
  });

  @override
  ConsumerState<BusinessFormScreen> createState() => _BusinessFormScreenState();
}

class _BusinessFormScreenState extends ConsumerState<BusinessFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _iconController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;

  Business? _existingBusiness;

  @override
  void initState() {
    super.initState();
    if (widget.businessId != null) {
      _loadBusinessData();
    }
  }

  void _loadBusinessData() {
    final businesses = ref.read(businessManagementProvider);
    _existingBusiness = businesses.firstWhere(
      (b) => b.id == widget.businessId,
      orElse: () => throw Exception('Negocio no encontrado'),
    );

    _nameController.text = _existingBusiness!.name;
    _iconController.text = _existingBusiness!.icon;
    _whatsappController.text = _existingBusiness!.whatsappNumber;
    _descriptionController.text = _existingBusiness!.description ?? '';
    _addressController.text = _existingBusiness!.address ?? '';
    _isActive = _existingBusiness!.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    _whatsappController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveBusiness() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final business = Business(
        id: widget.businessId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        icon: _iconController.text.trim(),
        whatsappNumber: _whatsappController.text.trim(),
        products: _existingBusiness?.products ?? [],
        isActive: _isActive,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
      );

      if (widget.businessId != null) {
        ref.read(businessManagementProvider.notifier).updateBusiness(business);
      } else {
        ref.read(businessManagementProvider.notifier).addBusiness(business);
      }

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.businessId != null
                  ? 'Negocio actualizado'
                  : 'Negocio creado exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/admin/businesses');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = ref.watch(adminProvider);

    if (admin == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/admin/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
            widget.businessId != null ? 'Editar Negocio' : 'Crear Negocio'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin/businesses'),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información del Negocio',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del negocio *',
                        hintText: 'Ej: Pizza Express',
                        prefixIcon: Icon(Icons.store),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _iconController,
                      decoration: const InputDecoration(
                        labelText: 'Ícono (emoji) *',
                        hintText: 'Ej: 🍕',
                        prefixIcon: Icon(Icons.emoji_emotions),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El ícono es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _whatsappController,
                      decoration: const InputDecoration(
                        labelText: 'Número de WhatsApp *',
                        hintText: '+573026699574',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El número de WhatsApp es requerido';
                        }
                        if (!value.startsWith('+')) {
                          return 'El número debe incluir el código de país (+57)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción (opcional)',
                        hintText: 'Breve descripción del negocio',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Dirección (opcional)',
                        hintText: 'Dirección física del negocio',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                    SwitchListTile(
                      title: const Text('Negocio activo'),
                      subtitle:
                          const Text('Los clientes pueden ver este negocio'),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveBusiness,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: AppColors.onAccent)
                        : Text(
                            widget.businessId != null
                                ? 'Actualizar Negocio'
                                : 'Crear Negocio',
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
