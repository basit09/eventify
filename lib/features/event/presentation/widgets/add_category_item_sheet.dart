import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../category/data/repositories/firebase_category_repository.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../category/domain/entities/subcategory_entity.dart';
import '../../domain/entities/event_category_item.dart';

/// Bottom sheet for adding a new [EventCategoryItem].
///
/// Fully self-contained — calls [onAdd] with the completed item so the
/// parent screen can decide how to store it (provider or local state).
class AddCategoryItemSheet extends ConsumerStatefulWidget {
  final void Function(EventCategoryItem item) onAdd;

  const AddCategoryItemSheet({super.key, required this.onAdd});

  @override
  ConsumerState<AddCategoryItemSheet> createState() =>
      _AddCategoryItemSheetState();
}

class _AddCategoryItemSheetState extends ConsumerState<AddCategoryItemSheet> {
  CategoryEntity?    _selectedCategory;
  SubcategoryEntity? _selectedSubcategory;

  final _qtyController    = TextEditingController(text: '1');
  final _lengthController = TextEditingController();
  final _widthController  = TextEditingController();
  final _heightController = TextEditingController();
  final _depthController  = TextEditingController();
  final _notesController  = TextEditingController();
  final _formKey          = GlobalKey<FormState>();

  @override
  void dispose() {
    _qtyController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _depthController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _nullIfEmpty(String v) => v.trim().isEmpty ? null : v.trim();

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) return;

    final item = EventCategoryItem(
      id:              const Uuid().v4(),
      categoryId:      _selectedCategory!.id,
      categoryName:    _selectedCategory!.name,
      subcategoryId:   _selectedSubcategory?.id   ?? '',
      subcategoryName: _selectedSubcategory?.name ?? '—',
      quantity:        int.tryParse(_qtyController.text) ?? 1,
      length:          _nullIfEmpty(_lengthController.text),
      width:           _nullIfEmpty(_widthController.text),
      height:          _nullIfEmpty(_heightController.text),
      depth:           _nullIfEmpty(_depthController.text),
      additionalNotes: _nullIfEmpty(_notesController.text),
    );

    widget.onAdd(item);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final theme           = Theme.of(context);
    final bottomInset     = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: _buildContent(
        categoriesAsync,
        theme,
        _selectedCategory?.subcategories ?? [],
      ),
    );
  }

  Widget _buildContent(
    AsyncValue<List<CategoryEntity>> categoriesAsync,
    ThemeData theme,
    List<SubcategoryEntity> subcategories,
  ) {
    if (categoriesAsync.isLoading && !categoriesAsync.hasValue) {
      return const SizedBox(
          height: 200, child: Center(child: CircularProgressIndicator()));
    }
    if (categoriesAsync.hasError && !categoriesAsync.hasValue) {
      return SizedBox(
          height: 200,
          child: Center(
              child: Text(
                  'Error loading categories: ${categoriesAsync.error}')));
    }

    final categories = categoriesAsync.value ?? [];
    if (categories.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.category_outlined,
                  size: 48, color: theme.colorScheme.outline),
              const SizedBox(height: 8),
              const Text('No categories found.\nAdd categories first.',
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color:        theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Text('Add Category Item',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Category
            DropdownButtonFormField<CategoryEntity>(
              decoration: const InputDecoration(
                labelText:  'Category *',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: categories.map((c) =>
                  DropdownMenuItem(value: c, child: Text(c.name))).toList(),
              onChanged: (val) => setState(() {
                _selectedCategory    = val;
                _selectedSubcategory = null;
              }),
              validator: (v) =>
                  v == null ? 'Please select a category' : null,
            ),
            const SizedBox(height: 16),

            // Subcategory
            DropdownButtonFormField<SubcategoryEntity>(
              decoration: const InputDecoration(
                labelText:  'Subcategory (Optional)',
                prefixIcon: Icon(Icons.subdirectory_arrow_right),
              ),
              items: [
                const DropdownMenuItem<SubcategoryEntity>(
                    value: null, child: Text('— None —')),
                ...subcategories.map((s) =>
                    DropdownMenuItem(value: s, child: Text(s.name))),
              ],
              onChanged: (val) =>
                  setState(() => _selectedSubcategory = val),
            ),
            const SizedBox(height: 16),

            // Quantity
            TextFormField(
              controller: _qtyController,
              decoration: const InputDecoration(
                labelText:  'Quantity *',
                prefixIcon: Icon(Icons.format_list_numbered),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if ((int.tryParse(v) ?? 0) < 1) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Row 1 — Length × Width
            _DimRow(
              leftCtrl: _lengthController, leftLabel: 'Length',
              leftIcon: Icons.straighten,
              rightCtrl: _widthController, rightLabel: 'Width',
              rightIcon: Icons.swap_horiz,
              showMultiply: true,
            ),
            const SizedBox(height: 12),

            // Row 2 — Height   Depth  (no ×)
            _DimRow(
              leftCtrl: _heightController, leftLabel: 'Height',
              leftIcon: Icons.height,
              rightCtrl: _depthController, rightLabel: 'Depth',
              rightIcon: Icons.layers_outlined,
              showMultiply: false,
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText:  'Additional Notes (Optional)',
                prefixIcon: Icon(Icons.notes),
                hintText:   'Special requirements...',
              ),
            ),
            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text('Add to Event'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Local dimension-row widget ────────────────────────────────────────────────
class _DimRow extends StatelessWidget {
  final TextEditingController leftCtrl;
  final String leftLabel;
  final IconData leftIcon;
  final TextEditingController rightCtrl;
  final String rightLabel;
  final IconData rightIcon;
  final bool showMultiply;

  const _DimRow({
    required this.leftCtrl,   required this.leftLabel,  required this.leftIcon,
    required this.rightCtrl,  required this.rightLabel, required this.rightIcon,
    required this.showMultiply,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextFormField(
            controller: leftCtrl,
            decoration: InputDecoration(
              labelText: leftLabel, hintText: 'e.g. 10ft',
              prefixIcon: Icon(leftIcon),
            ),
          ),
        ),
        if (showMultiply)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('×',
                style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
          )
        else
          const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: rightCtrl,
            decoration: InputDecoration(
              labelText: rightLabel, hintText: 'e.g. 10ft',
              prefixIcon: Icon(rightIcon),
            ),
          ),
        ),
      ],
    );
  }
}
