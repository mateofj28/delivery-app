import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/business.dart';
import '../../providers/admin_provider.dart';
import '../../providers/business_management_provider.dart';

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
      // Retrasar la carga de datos hasta después de que el widget tree termine de construirse
      Future.microtask(() => _loadBusinessData());
    } else {
      // Valores por defecto para nuevo negocio
      _whatsappController.text = '+573026699574';
    }
  }

  Future<void> _loadBusinessData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(businessRepositoryProvider);
      _existingBusiness = await repository.getBusinessById(widget.businessId!);

      if (_existingBusiness != null) {
        _nameController.text = _existingBusiness!.name;
        _iconController.text = _existingBusiness!.icon;
        _whatsappController.text = _existingBusiness!.whatsappNumber;
        _descriptionController.text = _existingBusiness!.description ?? '';
        _addressController.text = _existingBusiness!.address ?? '';
        _isActive = _existingBusiness!.isActive;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar el negocio: $e'),
            backgroundColor: Colors.red,
          ),
        );
        context.go('/admin/businesses');
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

      try {
        final business = widget.businessId != null
            ? _existingBusiness!.copyWith(
                name: _nameController.text.trim(),
                icon: _iconController.text.trim(),
                whatsappNumber: _whatsappController.text.trim(),
                isActive: _isActive,
                description: _descriptionController.text.trim().isEmpty
                    ? null
                    : _descriptionController.text.trim(),
                address: _addressController.text.trim().isEmpty
                    ? null
                    : _addressController.text.trim(),
              )
            : Business.create(
                name: _nameController.text.trim(),
                icon: _iconController.text.trim(),
                whatsappNumber: _whatsappController.text.trim(),
                description: _descriptionController.text.trim().isEmpty
                    ? null
                    : _descriptionController.text.trim(),
                address: _addressController.text.trim().isEmpty
                    ? null
                    : _addressController.text.trim(),
              );

        bool success;
        if (widget.businessId != null) {
          success = await ref
              .read(businessManagementProvider.notifier)
              .updateBusiness(business);
        } else {
          final businessId = await ref
              .read(businessManagementProvider.notifier)
              .createBusiness(business);
          success = businessId != null;
        }

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.businessId != null
                      ? 'Negocio actualizado exitosamente'
                      : 'Negocio creado exitosamente',
                ),
                backgroundColor: Colors.green,
              ),
            );
            context.go('/admin/businesses');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.businessId != null
                      ? 'Error al actualizar el negocio'
                      : 'Error al crear el negocio',
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

    if (_isLoading && widget.businessId != null) {
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
                        if (value.trim().length < 2) {
                          return 'El nombre debe tener al menos 2 caracteres';
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
                        helperText: 'Incluye el código de país (+57)',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El número de WhatsApp es requerido';
                        }
                        if (!value.startsWith('+')) {
                          return 'El número debe incluir el código de país (+57)';
                        }
                        if (value.length < 10) {
                          return 'Número de teléfono inválido';
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
                      validator: (value) {
                        if (value != null &&
                            value.trim().isNotEmpty &&
                            value.trim().length < 10) {
                          return 'La descripción debe tener al menos 10 caracteres';
                        }
                        return null;
                      },
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
                      subtitle: const Text(
                        'Los clientes pueden ver este negocio',
                      ),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
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
                                'Información importante',
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
                            '• Los pedidos se enviarán al número de WhatsApp configurado\n'
                            '• El ícono aparecerá en la lista de negocios\n'
                            '• Solo los negocios activos son visibles para los clientes',
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
