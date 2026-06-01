import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/category_controller.dart';
import '../../domain/entities/category_entity.dart';

/// Unified bottom sheet — Category Name (required) + Subcategory Name (optional).
class AddCategorySheet extends ConsumerStatefulWidget {
  const AddCategorySheet({super.key});

  @override
  ConsumerState<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends ConsumerState<AddCategorySheet> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _subcategoryController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    // Compress heavily before uploading to save Firebase Storage costs
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 60,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (pickedFile != null) {
      if (!mounted) return;
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _subcategoryController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final categoryName = _categoryController.text.trim();
    final subcategoryName = _subcategoryController.text.trim();

    await ref.read(categoryControllerProvider.notifier).addCategoryWithSubcategory(
          categoryName,
          subcategoryName.isEmpty ? null : subcategoryName,
          imageFile: _selectedImage,
        );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isLoading = ref.watch(categoryControllerProvider).isLoading;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottomInset),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Text(
              'Add Category',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Subcategory is optional — leave blank if none.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Category Name (required)
            TextFormField(
              controller: _categoryController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Category Name *',
                hintText: 'e.g. Tent, Furniture, Lighting',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Category name is required' : null,
            ),
            const SizedBox(height: 16),

            // Subcategory Name (optional)
            TextFormField(
              controller: _subcategoryController,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'Subcategory Name (Optional)',
                hintText: 'e.g. Chairs, LED Lights, Round Tables',
                prefixIcon: Icon(Icons.subdirectory_arrow_right),
              ),
            ),
            const SizedBox(height: 16),
            
            // Image Picker Section (only makes sense if a subcategory is added, but we show it anyway)
            if (_selectedImage != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_selectedImage!, height: 120, width: double.infinity, fit: BoxFit.cover),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(backgroundColor: Colors.black54),
                    onPressed: () => setState(() => _selectedImage = null),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Camera'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.image_outlined),
                      label: const Text('Gallery'),
                    ),
                  ),
                ],
              ),
              
            const SizedBox(height: 28),

            FilledButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Add Category'),
            ),
          ],
        ),
      ),
    );
  }
}

// Old single-field AlertDialog — kept for reference (no longer used by the FAB)
class AddCategoryDialog extends ConsumerStatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  ConsumerState<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends ConsumerState<AddCategoryDialog> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref.read(categoryControllerProvider.notifier).addCategory(
            _nameController.text.trim(),
          );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Category'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            hintText: 'e.g. Wedding, Setup, Decor',
          ),
          autofocus: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a name';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}

// Adds an extra subcategory to an existing category — rendered as a bottom sheet
// to avoid AlertDialog + Image layout constraint issues that cause a blank/white dialog.
class AddSubcategorySheet extends ConsumerStatefulWidget {
  final CategoryEntity category;
  const AddSubcategorySheet({super.key, required this.category});

  @override
  ConsumerState<AddSubcategorySheet> createState() => _AddSubcategorySheetState();
}

class _AddSubcategorySheetState extends ConsumerState<AddSubcategorySheet> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 60,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (pickedFile != null) {
      if (!mounted) return;
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(categoryControllerProvider.notifier).addSubcategory(
          widget.category.id,
          _nameController.text.trim(),
          imageFile: _selectedImage,
        );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isLoading = ref.watch(categoryControllerProvider).isLoading;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottomInset),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Text(
              'Add Subcategory',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Adding to: ${widget.category.name}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'Subcategory Name *',
                hintText: 'e.g. Chairs, Stages, Lighting',
                prefixIcon: Icon(Icons.subdirectory_arrow_right),
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 16),
            if (_selectedImage != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImage!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(backgroundColor: Colors.black54),
                    onPressed: () => setState(() => _selectedImage = null),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isLoading ? null : () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Camera'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isLoading ? null : () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.image_outlined),
                      label: const Text('Gallery'),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Add Subcategory'),
            ),
          ],
        ),
      ),
    );
  }
}
