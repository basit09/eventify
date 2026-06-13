import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/event_category_item.dart';
import '../controllers/create_event_controller.dart';
import '../widgets/add_category_item_sheet.dart';

// ── Time-of-day options  (label, time-range) ──────────────────────────────────
const _kTimeSlots = [
  ('Early Morning', '12–6 AM'),
  ('Morning',       '6–12 PM'),
  ('Afternoon',     '12–4 PM'),
  ('Evening',       '4–8 PM'),
  ('Night',         '8–12 AM'),
];

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey                = GlobalKey<FormState>();
  final _nameController          = TextEditingController();
  final _addressController       = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _contactPhoneController  = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  // Setup date state
  DateTime? _setupPickedDate;
  String    _setupTimeOfDay = '';

  String get _composedSetupDate {
    if (_setupPickedDate == null) return '';
    final d = DateFormat('d MMMM yyyy').format(_setupPickedDate!);
    return _setupTimeOfDay.isEmpty ? d : '$d ($_setupTimeOfDay)';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactPersonController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  // ── Date pickers ─────────────────────────────────────────────────────────

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
        _endDate   = range.end;
      });
    }
  }

  Future<void> _pickSetupDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _setupPickedDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _setupPickedDate = picked);
  }

  // ── Add item sheet ────────────────────────────────────────────────────────

  void _showAddCategorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => AddCategoryItemSheet(
        onAdd: (item) =>
            ref.read(eventFormItemsProvider.notifier).addItem(item),
      ),
    );
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a date range for the event.')),
      );
      return;
    }

    if (_setupPickedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a setup date.')),
      );
      return;
    }

    final items = ref.read(eventFormItemsProvider);
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please add at least one category item.')),
      );
      return;
    }

    await ref.read(createEventControllerProvider.notifier).createEvent(
          name:          _nameController.text.trim(),
          startDate:     _startDate!,
          endDate:       _endDate!,
          setupDate:     _composedSetupDate,
          address:       _addressController.text.trim(),
          contactPerson: _contactPersonController.text.trim(),
          contactPhone:  _contactPhoneController.text.trim(),
          items:         items,
        );

    if (mounted && !ref.read(createEventControllerProvider).hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event Created Successfully!')),
      );
      context.pop();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme            = Theme.of(context);
    final items            = ref.watch(eventFormItemsProvider);
    final createEventState = ref.watch(createEventControllerProvider);

    ref.listen<AsyncValue<void>>(createEventControllerProvider, (_, state) {
      state.whenOrNull(
        error: (error, st) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:         Text(error.toString()),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        },
      );
    });

    final dateLabel = _startDate == null || _endDate == null
        ? 'Tap to select From → To dates'
        : '${DateFormat('MMM d, yyyy').format(_startDate!)}  →  '
            '${DateFormat('MMM d, yyyy').format(_endDate!)}';

    final setupLabel = _setupPickedDate == null
        ? 'Tap to select setup date'
        : DateFormat('d MMMM yyyy').format(_setupPickedDate!);

    return Scaffold(
      appBar: AppBar(title: const Text('Create New Event')),
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
                          labelText:  'Event Name',
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText:  'Event Address',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),

                      // Event date range
                      InkWell(
                        onTap: _pickDateRange,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText:  'Event Dates (From → To)',
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

                      // ── Setup Date picker + time chips ─────────────
                      _SetupDateField(
                        pickedDate:    _setupPickedDate,
                        setupLabel:    setupLabel,
                        selectedTime:  _setupTimeOfDay,
                        onPickDate:    _pickSetupDate,
                        onSelectTime:  (t) =>
                            setState(() => _setupTimeOfDay = t),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _contactPersonController,
                        decoration: const InputDecoration(
                          labelText:  'Contact Person',
                          prefixIcon: Icon(Icons.person_outline),
                          hintText:   'e.g. Ali Hassan',
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _contactPhoneController,
                        decoration: const InputDecoration(
                          labelText:   'Contact Person Phone',
                          prefixIcon:  Icon(Icons.phone_outlined),
                          hintText:    'e.g. 3001234567',
                          counterText: '',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
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

              // ── Requirements header ────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Requirements',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
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

              // ── Items list ─────────────────────────────────────────
              if (items.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: theme.colorScheme.outlineVariant),
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
                  separatorBuilder: (context, i) =>
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
                                _ItemBadge(label: 'Item ${index + 1}'),
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
                            Text(item.subcategoryName,
                                style: theme.textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold)),
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

      // ── FAB ───────────────────────────────────────────────────────────────
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

// ── Setup Date Field (date picker row + time chips) ───────────────────────────
class _SetupDateField extends StatelessWidget {
  final DateTime? pickedDate;
  final String    setupLabel;
  final String    selectedTime;
  final VoidCallback          onPickDate;
  final ValueChanged<String>  onSelectTime;

  const _SetupDateField({
    required this.pickedDate,
    required this.setupLabel,
    required this.selectedTime,
    required this.onPickDate,
    required this.onSelectTime,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date picker row
        InkWell(
          onTap: onPickDate,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText:  'Setup Date *',
              prefixIcon: const Icon(Icons.build_circle_outlined),
              suffixIcon: const Icon(Icons.calendar_today, size: 18),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: pickedDate == null
                      ? theme.colorScheme.outline
                      : theme.colorScheme.primary,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
            ),
            child: Text(
              setupLabel,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: pickedDate == null
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),

        // Time-of-day chips (only show when date is picked)
        if (pickedDate != null) ...[
          const SizedBox(height: 10),
          Text(
            'Time of Day',
            style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _kTimeSlots.map((slot) {
              final value    = '${slot.$1} · ${slot.$2}';
              final selected = selectedTime == value;
              return ChoiceChip(
                selected:     selected,
                onSelected:   (_) => onSelectTime(selected ? '' : value),
                selectedColor: theme.colorScheme.primaryContainer,
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 6),
                label: Column(
                  mainAxisSize:     MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      slot.$1,
                      style: TextStyle(
                        color: selected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurface,
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      slot.$2,
                      style: TextStyle(
                        color: selected
                            ? theme.colorScheme.onPrimaryContainer
                                .withValues(alpha: 0.75)
                            : theme.colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          if (selectedTime.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 14, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Will save as: '
                      '${DateFormat('d MMMM yyyy').format(pickedDate!)} '
                      '($selectedTime)',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

// ── Dimension helpers ─────────────────────────────────────────────────────────
bool _hasDimensions(EventCategoryItem item) =>
    item.length?.isNotEmpty == true ||
    item.width?.isNotEmpty  == true ||
    item.height?.isNotEmpty == true ||
    item.depth?.isNotEmpty  == true;

String _dimensionLabel(EventCategoryItem item) {
  final parts = <String>[];
  if (item.length?.isNotEmpty == true && item.width?.isNotEmpty == true) {
    parts.add('${item.length} × ${item.width}');
  } else {
    if (item.length?.isNotEmpty == true) parts.add('L:${item.length}');
    if (item.width?.isNotEmpty  == true) parts.add('W:${item.width}');
  }
  if (item.height?.isNotEmpty == true) parts.add('H:${item.height}');
  if (item.depth?.isNotEmpty  == true) parts.add('D:${item.depth}');
  return parts.join('  ');
}

// ── Small shared widgets ──────────────────────────────────────────────────────
class _ItemBadge extends StatelessWidget {
  final String label;
  const _ItemBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
            color:      theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
            fontSize:   12,
          )),
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
