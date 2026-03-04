import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../category/data/repositories/firebase_category_repository.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../category/domain/entities/subcategory_entity.dart';
import '../../domain/entities/event_category_item.dart';
import '../controllers/create_event_controller.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (range != null) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
      });
    }
  }

  void _showAddCategorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _AddCategoryItemSheet(),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date range for the event.')),
      );
      return;
    }

    final items = ref.read(eventFormItemsProvider);
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one category item.')),
      );
      return;
    }

    await ref.read(createEventControllerProvider.notifier).createEvent(
          name: _nameController.text.trim(),
          startDate: _startDate!,
          endDate: _endDate!,
          address: _addressController.text.trim(),
          items: items,
        );

    if (mounted && !ref.read(createEventControllerProvider).hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event Created Successfully!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = ref.watch(eventFormItemsProvider);
    final createEventState = ref.watch(createEventControllerProvider);

    ref.listen<AsyncValue<void>>(
      createEventControllerProvider,
      (_, state) {
        state.whenOrNull(
          error: (error, stackTrace) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.toString()),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          },
        );
      },
    );

    final dateLabel = _startDate == null || _endDate == null
        ? 'Tap to select From → To dates'
        : '${DateFormat('MMM d, yyyy').format(_startDate!)}  →  ${DateFormat('MMM d, yyyy').format(_endDate!)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Event'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Event Details Card ───────────────────────────────────
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.event_note, size: 18, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text('Event Details',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Event Name',
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Event Address',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      // ── Date Range Picker ────────────────────────────
                      InkWell(
                        onTap: _pickDateRange,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Event Dates (From → To)',
                            prefixIcon: const Icon(Icons.date_range),
                            errorText: (_startDate == null && _endDate == null)
                                ? null
                                : null,
                          ),
                          child: Text(
                            dateLabel,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: _startDate == null
                                  ? theme.colorScheme.onSurfaceVariant
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Category Requirements Header ─────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Requirements',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  FilledButton.tonal(
                    onPressed: _showAddCategorySheet,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 18),
                        SizedBox(width: 4),
                        Text('Add Item'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Items List ───────────────────────────────────────────
              if (items.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                        style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(16),
                    color: theme.colorScheme.surface,
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 48, color: theme.colorScheme.outline),
                      const SizedBox(height: 8),
                      Text(
                        'No items added yet.\nTap "Add Item" to begin.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.25)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Item ${index + 1}',
                                    style: TextStyle(
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Chip(
                                  label: Text(item.categoryName,
                                      style: const TextStyle(fontSize: 12)),
                                  backgroundColor:
                                      theme.colorScheme.secondaryContainer,
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () => ref
                                      .read(eventFormItemsProvider.notifier)
                                      .removeItem(item.id),
                                ),
                              ],
                            ),
                            const Divider(height: 16),
                            Text(
                              item.subcategoryName,
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 16,
                              runSpacing: 4,
                              children: [
                                _InfoChip(
                                    icon: Icons.format_list_numbered,
                                    label: 'Qty: ${item.quantity}'),
                                if (item.size != null && item.size!.isNotEmpty)
                                  _InfoChip(
                                      icon: Icons.straighten,
                                      label: 'Size: ${item.size}'),
                                if (item.additionalNotes != null &&
                                    item.additionalNotes!.isNotEmpty)
                                  _InfoChip(
                                      icon: Icons.notes,
                                      label: item.additionalNotes!),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      // ── Floating Save Button ────────────────────────────────────────────
      floatingActionButton: createEventState.isLoading
          ? FloatingActionButton.extended(
              onPressed: null,
              icon: const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white)),
              label: const Text('Saving...'),
            )
          : FloatingActionButton.extended(
              onPressed: _submit,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save Event'),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// ── Small info chip widget ────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

// ── Bottom Sheet for adding category items ────────────────────────────────────
class _AddCategoryItemSheet extends ConsumerStatefulWidget {
  const _AddCategoryItemSheet();

  @override
  ConsumerState<_AddCategoryItemSheet> createState() =>
      _AddCategoryItemSheetState();
}

class _AddCategoryItemSheetState
    extends ConsumerState<_AddCategoryItemSheet> {
  CategoryEntity? _selectedCategory;
  SubcategoryEntity? _selectedSubcategory;

  final _qtyController = TextEditingController(text: '1');
  final _heightController = TextEditingController();
  final _widthController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _qtyController.dispose();
    _heightController.dispose();
    _widthController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) return;

    final sizeH = _heightController.text.trim();
    final sizeW = _widthController.text.trim();
    final sizeStr = (sizeH.isNotEmpty && sizeW.isNotEmpty)
        ? '$sizeH x $sizeW'
        : (sizeH.isNotEmpty ? sizeH : sizeW.isNotEmpty ? sizeW : null);

    final item = EventCategoryItem(
      id: const Uuid().v4(),
      categoryId: _selectedCategory!.id,
      categoryName: _selectedCategory!.name,
      subcategoryId: _selectedSubcategory?.id ?? '',
      subcategoryName: _selectedSubcategory?.name ?? '—',
      quantity: int.tryParse(_qtyController.text) ?? 1,
      size: sizeStr,
      additionalNotes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    ref.read(eventFormItemsProvider.notifier).addItem(item);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final subcategories = _selectedCategory?.subcategories ?? [];

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: categoriesAsync.when(
        loading: () => const SizedBox(
            height: 200, child: Center(child: CircularProgressIndicator())),
        error: (e, _) => SizedBox(
            height: 200,
            child: Center(child: Text('Error loading categories: $e'))),
        data: (categories) {
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
                    const Text(
                        'No categories found.\nAdd categories from the Categories tab first.',
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
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Text('Add Category Item',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // Category dropdown
                  DropdownButtonFormField<CategoryEntity>(
                    decoration: const InputDecoration(
                      labelText: 'Category *',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: categories
                        .map((c) =>
                            DropdownMenuItem(value: c, child: Text(c.name)))
                        .toList(),
                    onChanged: (val) => setState(() {
                      _selectedCategory = val;
                      _selectedSubcategory = null;
                    }),
                    validator: (v) => v == null ? 'Please select a category' : null,
                  ),
                  const SizedBox(height: 16),

                  // Subcategory dropdown
                  DropdownButtonFormField<SubcategoryEntity>(
                    decoration: const InputDecoration(
                      labelText: 'Subcategory (Optional)',
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
                      labelText: 'Quantity *',
                      prefixIcon: Icon(Icons.format_list_numbered),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (int.tryParse(v) == null || int.parse(v) < 1) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Size: Height × Width
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _heightController,
                          decoration: const InputDecoration(
                            labelText: 'Height',
                            hintText: 'e.g. 10ft',
                            prefixIcon: Icon(Icons.height),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text('×',
                            style: theme.textTheme.titleLarge
                                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _widthController,
                          decoration: const InputDecoration(
                            labelText: 'Width',
                            hintText: 'e.g. 10ft',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Soft / notes field
                  TextFormField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Additional Notes (Soft Field)',
                      prefixIcon: Icon(Icons.notes),
                      hintText: 'Special requirements...',
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
        },
      ),
    );
  }
}
