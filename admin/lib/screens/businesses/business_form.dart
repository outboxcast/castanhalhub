import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../config/app_colors.dart';
import '../../providers/business_provider.dart';
import '../../services/supabase_service.dart';

class BusinessFormDialog extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const BusinessFormDialog({super.key, this.initialData});

  @override
  State<BusinessFormDialog> createState() => _BusinessFormDialogState();
}

class _BusinessFormDialogState extends State<BusinessFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _whatsappController;
  late TextEditingController _instagramController;
  late TextEditingController _imageUrlController;

  String? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;
  bool _isFetching = false;
  bool _isPremium = false;
  bool _isUploadingImage = false;
  String? _uploadedImageUrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadCategories();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(
      text: widget.initialData?['name'] ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialData?['description'] ?? '',
    );
    _addressController = TextEditingController(
      text: widget.initialData?['address'] ?? '',
    );
    _latitudeController = TextEditingController(
      text: widget.initialData?['latitude']?.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: widget.initialData?['longitude']?.toString() ?? '',
    );
    _whatsappController = TextEditingController(
      text: widget.initialData?['whatsapp_number'] ?? '',
    );
    _instagramController = TextEditingController(
      text: widget.initialData?['instagram_url'] ?? '',
    );
    _imageUrlController = TextEditingController(
      text: widget.initialData?['image_url'] ?? '',
    );
    _selectedCategoryId = widget.initialData?['category_id'];
    _isPremium = widget.initialData?['is_premium'] ?? false;
  }

  Future<void> _loadCategories() async {
    setState(() => _isFetching = true);
    try {
      final categories = await SupabaseService().getCategories();
      setState(() {
        _categories = categories;
        _isFetching = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar categorias: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
      setState(() => _isFetching = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      setState(() => _isUploadingImage = true);

      final file = result.files.first;
      final bytes = file.bytes;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';

      if (bytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao ler o arquivo selecionado'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
        setState(() => _isUploadingImage = false);
        return;
      }

      // Faz upload para o Supabase Storage
      final imageUrl = await SupabaseService().uploadBusinessImage(
        fileName: fileName,
        bytes: bytes,
      );

      setState(() {
        _uploadedImageUrl = imageUrl;
        _imageUrlController.text = imageUrl;
        _isUploadingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Imagem enviada com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar imagem: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
      setState(() => _isUploadingImage = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _whatsappController.dispose();
    _instagramController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialData != null;

    return AlertDialog(
      title: Text(isEditing ? 'Editar Loja' : 'Nova Loja'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nome
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome da Loja *',
                    hintText: 'Ex: Loja XYZ',
                    prefixIcon: Icon(Icons.store_outlined),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Nome é obrigatório';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Categoria
                _isFetching
                    ? const CircularProgressIndicator()
                    : DropdownButtonFormField<String>(
                        initialValue: _selectedCategoryId,
                        items: _categories
                            .map<DropdownMenuItem<String>>(
                              (cat) => DropdownMenuItem<String>(
                                value: cat['id'] as String,
                                child: Text(cat['name'] ?? 'Sem nome'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedCategoryId = value);
                        },
                        decoration: const InputDecoration(
                          labelText: 'Categoria *',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'Categoria é obrigatória';
                          }
                          return null;
                        },
                      ),

                const SizedBox(height: 16),

                // Descrição
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    hintText: 'Descreva sua loja',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  maxLines: 3,
                ),

                const SizedBox(height: 16),

                // Endereço
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Endereço',
                    hintText: 'Ex: Rua Principal, 123',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),

                const SizedBox(height: 16),

                // Latitude e Longitude
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latitudeController,
                        decoration: const InputDecoration(
                          labelText: 'Latitude',
                          prefixIcon: Icon(Icons.map_outlined),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _longitudeController,
                        decoration: const InputDecoration(
                          labelText: 'Longitude',
                          prefixIcon: Icon(Icons.map_outlined),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // WhatsApp
                TextFormField(
                  controller: _whatsappController,
                  decoration: const InputDecoration(
                    labelText: 'WhatsApp',
                    hintText: '(XX) 99999-9999',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),

                const SizedBox(height: 16),

                // Instagram
                TextFormField(
                  controller: _instagramController,
                  decoration: const InputDecoration(
                    labelText: 'URL Instagram',
                    hintText: 'https://instagram.com/...',
                    prefixIcon: Icon(Icons.link_outlined),
                  ),
                ),

                const SizedBox(height: 16),

                // Imagem
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.image_outlined, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Imagem do Negócio',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          if (_isUploadingImage)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Preview da imagem
                      if (_uploadedImageUrl != null || _imageUrlController.text.isNotEmpty)
                        Container(
                          height: 150,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(
                                _uploadedImageUrl ?? _imageUrlController.text,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                      // Botão de upload
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isUploadingImage ? null : _pickImage,
                          icon: const Icon(Icons.upload),
                          label: const Text('Selecionar Imagem'),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Ou URL manual
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Ou cole uma URL de imagem',
                          hintText: 'https://...',
                          prefixIcon: Icon(Icons.link),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Premium
                CheckboxListTile(
                  title: const Text('Marcar como Premium'),
                  value: _isPremium,
                  onChanged: (value) {
                    setState(() => _isPremium = value ?? false);
                  },
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : () => _handleSubmit(context),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Atualizar' : 'Criar'),
        ),
      ],
    );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final businessProvider = context.read<BusinessProvider>();
      final isEditing = widget.initialData != null;

      if (isEditing) {
        final success = await businessProvider.updateBusiness(
          id: widget.initialData!['id'],
          name: _nameController.text,
          categoryId: _selectedCategoryId,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
          address: _addressController.text.isNotEmpty
              ? _addressController.text
              : null,
          latitude: _latitudeController.text.isNotEmpty
              ? double.tryParse(_latitudeController.text)
              : null,
          longitude: _longitudeController.text.isNotEmpty
              ? double.tryParse(_longitudeController.text)
              : null,
          whatsappNumber: _whatsappController.text.isNotEmpty
              ? _whatsappController.text
              : null,
          instagramUrl: _instagramController.text.isNotEmpty
              ? _instagramController.text
              : null,
          imageUrl: _imageUrlController.text.isNotEmpty
              ? _imageUrlController.text
              : null,
          isPremium: _isPremium,
        );

        if (success && mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Loja atualizada com sucesso!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        final success = await businessProvider.createBusiness(
          name: _nameController.text,
          categoryId: _selectedCategoryId!,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
          address: _addressController.text.isNotEmpty
              ? _addressController.text
              : null,
          latitude: _latitudeController.text.isNotEmpty
              ? double.tryParse(_latitudeController.text)
              : null,
          longitude: _longitudeController.text.isNotEmpty
              ? double.tryParse(_longitudeController.text)
              : null,
          whatsappNumber: _whatsappController.text.isNotEmpty
              ? _whatsappController.text
              : null,
          instagramUrl: _instagramController.text.isNotEmpty
              ? _instagramController.text
              : null,
          imageUrl: _imageUrlController.text.isNotEmpty
              ? _imageUrlController.text
              : null,
          isPremium: _isPremium,
        );

        if (success && mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Loja criada com sucesso!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
