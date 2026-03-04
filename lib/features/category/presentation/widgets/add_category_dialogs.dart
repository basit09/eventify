import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
              autofocus: true,
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

// Adds an extra subcategory to an existing category
class AddSubcategoryDialog extends ConsumerStatefulWidget {
  final CategoryEntity category;
  const AddSubcategoryDialog({super.key, required this.category});

  @override
  ConsumerState<AddSubcategoryDialog> createState() =>
      _AddSubcategoryDialogState();
}

class _AddSubcategoryDialogState extends ConsumerState<AddSubcategoryDialog> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref.read(categoryControllerProvider.notifier).addSubcategory(
            widget.category.id,
            _nameController.text.trim(),
          );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Subcategory to ${widget.category.name}'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Subcategory Name',
            hintText: 'e.g. Chairs, Stages, Lighting',
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
