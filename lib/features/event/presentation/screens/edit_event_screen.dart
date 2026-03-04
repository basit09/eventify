import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../category/data/repositories/firebase_category_repository.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../category/domain/entities/subcategory_entity.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/entities/event_category_item.dart';
import '../../data/repositories/firebase_event_repository.dart';

// ── Provider: manages editable item list for edit form ────────────────────────
final editFormItemsProvider =
    NotifierProvider<EditFormItems, List<EventCategoryItem>>(EditFormItems.new);

class EditFormItems extends Notifier<List<EventCategoryItem>> {
  @override
  List<EventCategoryItem> build() => [];

  void setItems(List<EventCategoryItem> items) => state = items;

  void addItem(EventCategoryItem item) => state = [...state, item];

  void removeItem(String id) => state = state.where((e) => e.id != id).toList();
}

// ── EditEventScreen ───────────────────────────────────────────────────────────
class EditEventScreen extends ConsumerStatefulWidget {
  final EventEntity event;
  const EditEventScreen({super.key, required this.event});

  @override
  ConsumerState<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends ConsumerState<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.event.name);
    _addressController = TextEditingController(text: widget.event.address);
    _startDate = widget.event.startDate;
    _endDate = widget.event.endDate;
    // Seed the editable items provider with existing items
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(editFormItemsProvider.notifier).setItems(widget.event.items);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now().subtract(const Duration(days: 1));
    final range = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
      initialDateRange:
          DateTimeRange(start: _startDate!, end: _endDate!),
    );
    if (range != null) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
      });
    }
  }

  void _showAddItemSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _AddEditItemSheet(
        onAdd: (item) => ref.read(editFormItemsProvider.notifier).addItem(item),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select event dates.')),
      );
      return;
    }

    final items = ref.read(editFormItemsProvider);
    setState(() => _saving = true);

    final updatedEvent = widget.event.copyWith(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      startDate: _startDate!,
      endDate: _endDate!,
      items: items,
    );

    try {
      await ref.read(eventRepositoryProvider).updateEvent(updatedEvent);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event updated successfully!')),
        );
        // Pop back to detail
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = ref.watch(editFormItemsProvider);
    final dateLabel = _startDate == null || _endDate == null
        ? 'Tap to select From → To dates'
        : '${DateFormat('MMM d, yyyy').format(_startDate!)}  →  ${DateFormat('MMM d, yyyy').format(_endDate!)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Event'),
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
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.event_note,
                            size: 18, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text('Event Details',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ]),
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
                      // Date range picker
                      InkWell(
                        onTap: _pickDateRange,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Event Dates (From → To)',
                            prefixIcon: Icon(Icons.date_range),
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

              // ── Items header ─────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Requirements',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  FilledButton.tonal(
                    onPressed: _showAddItemSheet,
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

              // ── Items list ───────────────────────────────────────────
              if (items.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(16),
                    color: theme.colorScheme.surface,
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 48, color: theme.colorScheme.outline),
                      const SizedBox(height: 8),
                      Text('No items. Tap "Add Item" to begin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
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
                                      .read(editFormItemsProvider.notifier)
                                      .removeItem(item.id),
                                ),
                              ],
                            ),
                            if (item.subcategoryName.isNotEmpty &&
                                item.subcategoryName != '—') ...[
                              const SizedBox(height: 4),
                              Text(item.subcategoryName,
                                  style: theme.textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 16,
                              children: [
                                Text('Qty: ${item.quantity}',
                                    style: theme.textTheme.bodySmall),
                                if (item.size != null && item.size!.isNotEmpty)
                                  Text('Size: ${item.size}',
                                      style: theme.textTheme.bodySmall),
                                if (item.additionalNotes != null &&
                                    item.additionalNotes!.isNotEmpty)
                                  Text(item.additionalNotes!,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                              color: theme.colorScheme
                                                  .onSurfaceVariant)),
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
      // ── Save FAB ────────────────────────────────────────────────────────
      floatingActionButton: _saving
          ? FloatingActionButton.extended(
              onPressed: null,
              icon: const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              ),
              label: const Text('Saving...'),
            )
          : FloatingActionButton.extended(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save Changes'),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// ── Bottom sheet to add an item while editing ─────────────────────────────────
class _AddEditItemSheet extends ConsumerStatefulWidget {
  final void Function(EventCategoryItem) onAdd;
  const _AddEditItemSheet({required this.onAdd});

  @override
  ConsumerState<_AddEditItemSheet> createState() => _AddEditItemSheetState();
}

class _AddEditItemSheetState extends ConsumerState<_AddEditItemSheet> {
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

    widget.onAdd(item);
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
            child: Center(child: Text('Error: $e'))),
        data: (categories) {
          if (categories.isEmpty) {
            return const SizedBox(
              height: 200,
              child: Center(
                  child: Text('No categories found. Add them first.',
                      textAlign: TextAlign.center)),
            );
          }
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                  DropdownButtonFormField<CategoryEntity>(
                    decoration: const InputDecoration(
                      labelText: 'Category *',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: categories
                        .map((c) => DropdownMenuItem(
                            value: c, child: Text(c.name)))
                        .toList(),
                    onChanged: (val) => setState(() {
                      _selectedCategory = val;
                      _selectedSubcategory = null;
                    }),
                    validator: (v) =>
                        v == null ? 'Please select a category' : null,
                  ),
                  const SizedBox(height: 16),
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
                            style: theme.textTheme.titleLarge?.copyWith(
                                color:
                                    theme.colorScheme.onSurfaceVariant)),
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
                  TextFormField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Additional Notes (Optional)',
                      prefixIcon: Icon(Icons.notes),
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
