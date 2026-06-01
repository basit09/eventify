import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _nameController         = TextEditingController();
  final _addressController      = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _contactPhoneController  = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _setupDate;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactPersonController.dispose();
    _contactPhoneController.dispose();
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

  Future<void> _pickSetupDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _setupDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _setupDate = picked);
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

    if (_setupDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a setup date.')),
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
          setupDate: _setupDate!,
          address: _addressController.text.trim(),
          contactPerson: _contactPersonController.text.trim(),
          contactPhone: _contactPhoneController.text.trim(),
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
    final setupDateLabel = _setupDate == null
        ? 'Tap to select setup date'
        : DateFormat('MMM d, yyyy').format(_setupDate!);

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
                      // ── Event Date Range ─────────────────────────────
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
                      const SizedBox(height: 16),
                      // ── Setup Date (mandatory) ────────────────────────
                      InkWell(
                        onTap: _pickSetupDate,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Setup Date *',
                            prefixIcon: const Icon(Icons.build_circle_outlined),
                            suffixIcon: const Icon(Icons.calendar_today, size: 18),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _setupDate == null
                                    ? theme.colorScheme.outline
                                    : theme.colorScheme.primary,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                            ),
                          ),
                          child: Text(
                            setupDateLabel,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: _setupDate == null
                                  ? theme.colorScheme.onSurfaceVariant
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // ── Contact Person ────────────────────────────────
                      TextFormField(
                        controller: _contactPersonController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Person',
                          prefixIcon: Icon(Icons.person_outline),
                          hintText: 'e.g. Ali Hassan',
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                      // ── Contact Phone ─────────────────────────────────
                      TextFormField(
                        controller: _contactPhoneController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Person Phone',
                          prefixIcon: Icon(Icons.phone_outlined),
                          hintText: 'e.g. 3001234567',
                          counterText: '', // hide the built-in maxLength counter
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null; // optional field
                          if (v.trim().length != 10) {
                            return 'Phone number must be exactly 10 digits';
                          }
                          return null;
                        },
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
                                if (_hasDimensions(item))
                                  _InfoChip(
                                      icon: Icons.straighten,
                                      label: _dimensionLabel(item)),
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
              heroTag: null,
              onPressed: null,
              icon: const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white)),
              label: const Text('Saving...'),
            )
          : FloatingActionButton.extended(
              heroTag: null,
              onPressed: _submit,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save Event'),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// ── Small info chip widget ────────────────────────────────────────────────────
/// Reusable row widget for dimension pairs.
/// [showMultiply] controls whether a "×" separator appears between the fields.
class _DimRow extends StatelessWidget {
  final TextEditingController leftController;
  final String leftLabel;
  final IconData leftIcon;
  final TextEditingController rightController;
  final String rightLabel;
  final IconData rightIcon;
  final bool showMultiply;

  const _DimRow({
    required this.leftController,
    required this.leftLabel,
    required this.leftIcon,
    required this.rightController,
    required this.rightLabel,
    required this.rightIcon,
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
            controller: leftController,
            decoration: InputDecoration(
              labelText: leftLabel,
              hintText: 'e.g. 10ft',
              prefixIcon: Icon(leftIcon),
            ),
          ),
        ),
        if (showMultiply)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '×',
              style: theme.textTheme.titleLarge
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          )
        else
          const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: rightController,
            decoration: InputDecoration(
              labelText: rightLabel,
              hintText: 'e.g. 10ft',
              prefixIcon: Icon(rightIcon),
            ),
          ),
        ),
      ],
    );
  }
}

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

// ── Dimension helpers (shared by create & display) ────────────────────────────
bool _hasDimensions(EventCategoryItem item) =>
    item.height?.isNotEmpty == true ||
    item.length?.isNotEmpty == true ||
    item.lengthB?.isNotEmpty == true ||
    item.width?.isNotEmpty == true ||
    item.itemHeight?.isNotEmpty == true ||
    item.depth?.isNotEmpty == true ||
    item.size?.isNotEmpty == true;

/// Compact chip label — e.g. "10 × 5  8 × 4  H:3  D:2"
String _dimensionLabel(EventCategoryItem item) {
  final parts = <String>[];
  // Row 1: H × L
  final row1 = <String>[];
  if (item.height?.isNotEmpty == true) row1.add(item.height!);
  if (item.length?.isNotEmpty == true) row1.add(item.length!);
  if (row1.isNotEmpty) parts.add(row1.join(' × '));
  // Row 2: L × W
  final row2 = <String>[];
  if (item.lengthB?.isNotEmpty == true) row2.add(item.lengthB!);
  if (item.width?.isNotEmpty == true) row2.add(item.width!);
  if (row2.isNotEmpty) parts.add(row2.join(' × '));
  // Row 3: H  D
  if (item.itemHeight?.isNotEmpty == true) parts.add('H:${item.itemHeight}');
  if (item.depth?.isNotEmpty == true) parts.add('D:${item.depth}');
  if (parts.isNotEmpty) return parts.join('  ');
  return item.size ?? '';
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

  final _qtyController        = TextEditingController(text: '1');
  // Row 1 — H × L
  final _heightController     = TextEditingController();
  final _lengthController     = TextEditingController();
  // Row 2 — L × W
  final _lengthBController    = TextEditingController();
  final _widthController      = TextEditingController();
  // Row 3 — H  D  (no ×)
  final _itemHeightController = TextEditingController();
  final _depthController      = TextEditingController();

  final _notesController      = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _qtyController.dispose();
    _heightController.dispose();
    _lengthController.dispose();
    _lengthBController.dispose();
    _widthController.dispose();
    _itemHeightController.dispose();
    _depthController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _nullIfEmpty(String v) => v.isEmpty ? null : v;

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) return;

    final item = EventCategoryItem(
      id: const Uuid().v4(),
      categoryId: _selectedCategory!.id,
      categoryName: _selectedCategory!.name,
      subcategoryId: _selectedSubcategory?.id ?? '',
      subcategoryName: _selectedSubcategory?.name ?? '—',
      quantity:   int.tryParse(_qtyController.text) ?? 1,
      height:     _nullIfEmpty(_heightController.text.trim()),
      length:     _nullIfEmpty(_lengthController.text.trim()),
      lengthB:    _nullIfEmpty(_lengthBController.text.trim()),
      width:      _nullIfEmpty(_widthController.text.trim()),
      itemHeight: _nullIfEmpty(_itemHeightController.text.trim()),
      depth:      _nullIfEmpty(_depthController.text.trim()),
      additionalNotes: _nullIfEmpty(_notesController.text.trim()),
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
      child: _buildSheetContent(categoriesAsync, theme, subcategories),
    );
  }

  Widget _buildSheetContent(AsyncValue<List<CategoryEntity>> categoriesAsync,
      ThemeData theme, List<SubcategoryEntity> subcategories) {
    // Only show loading on the very first fetch
    if (categoriesAsync.isLoading && !categoriesAsync.hasValue) {
      return const SizedBox(
          height: 200, child: Center(child: CircularProgressIndicator()));
    }

    if (categoriesAsync.hasError && !categoriesAsync.hasValue) {
      return SizedBox(
          height: 200,
          child: Center(child: Text('Error loading categories: ${categoriesAsync.error}')));
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

            // Row 1 — H × L
            _DimRow(
              leftController: _heightController,
              leftLabel: 'H',
              leftIcon: Icons.height,
              rightController: _lengthController,
              rightLabel: 'L',
              rightIcon: Icons.straighten,
              showMultiply: true,
            ),
            const SizedBox(height: 12),

            // Row 2 — L × W
            _DimRow(
              leftController: _lengthBController,
              leftLabel: 'L',
              leftIcon: Icons.straighten,
              rightController: _widthController,
              rightLabel: 'W',
              rightIcon: Icons.swap_horiz,
              showMultiply: true,
            ),
            const SizedBox(height: 12),

            // Row 3 — H  D  (no ×)
            _DimRow(
              leftController: _itemHeightController,
              leftLabel: 'H',
              leftIcon: Icons.height_outlined,
              rightController: _depthController,
              rightLabel: 'D',
              rightIcon: Icons.layers_outlined,
              showMultiply: false,
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
  }
}
