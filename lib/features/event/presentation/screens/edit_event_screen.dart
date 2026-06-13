import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/entities/event_category_item.dart';
import '../../data/repositories/firebase_event_repository.dart';
import '../widgets/add_category_item_sheet.dart';

// ── Time-of-day options  (label, time-range) ──────────────────────────────────
const _kTimeSlots = [
  ('Early Morning', '12–6 AM'),
  ('Morning',       '6–12 PM'),
  ('Afternoon',     '12–4 PM'),
  ('Evening',       '4–8 PM'),
  ('Night',         '8–12 AM'),
];

// ── Per-item controller bundle ────────────────────────────────────────────────
class _ItemControllers {
  final TextEditingController qty;
  final TextEditingController length;
  final TextEditingController width;
  final TextEditingController height;
  final TextEditingController depth;
  final TextEditingController notes;

  _ItemControllers({required EventCategoryItem item})
      : qty    = TextEditingController(text: item.quantity.toString()),
        length = TextEditingController(text: item.length ?? ''),
        width  = TextEditingController(text: item.width  ?? ''),
        height = TextEditingController(text: item.height ?? ''),
        depth  = TextEditingController(text: item.depth  ?? ''),
        notes  = TextEditingController(text: item.additionalNotes ?? '');

  void dispose() {
    qty.dispose();
    length.dispose();
    width.dispose();
    height.dispose();
    depth.dispose();
    notes.dispose();
  }

  EventCategoryItem applyTo(EventCategoryItem original) {
    String? n(String v) => v.trim().isEmpty ? null : v.trim();
    return original.copyWith(
      quantity:        int.tryParse(qty.text.trim()) ?? original.quantity,
      length:          n(length.text),
      width:           n(width.text),
      height:          n(height.text),
      depth:           n(depth.text),
      additionalNotes: n(notes.text),
    );
  }
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
  late final TextEditingController _contactPersonController;
  late final TextEditingController _contactPhoneController;

  DateTime? _startDate;
  DateTime? _endDate;
  bool _saving = false;

  // Setup date state
  DateTime? _setupPickedDate;
  String    _setupTimeOfDay = '';

  String get _composedSetupDate {
    if (_setupPickedDate == null) return '';
    final d = DateFormat('d MMMM yyyy').format(_setupPickedDate!);
    return _setupTimeOfDay.isEmpty ? d : '$d ($_setupTimeOfDay)';
  }

  // Mutable items + per-item controllers
  late List<EventCategoryItem>       _items;
  late Map<String, _ItemControllers> _itemControllers;

  @override
  void initState() {
    super.initState();

    _nameController          = TextEditingController(text: widget.event.name);
    _addressController       = TextEditingController(text: widget.event.address);
    _contactPersonController = TextEditingController(text: widget.event.contactPerson ?? '');
    _contactPhoneController  = TextEditingController(text: widget.event.contactPhone  ?? '');
    _startDate = widget.event.startDate;
    _endDate   = widget.event.endDate;

    // Parse existing setupDate (e.g. "6 June 2026 (Morning)")
    _parseExistingSetupDate(widget.event.setupDate);

    // Mutable items list
    _items = List.from(widget.event.items);
    _itemControllers = {
      for (final item in _items) item.id: _ItemControllers(item: item),
    };
  }

  void _parseExistingSetupDate(String raw) {
    if (raw.isEmpty) return;
    final timeMatch = RegExp(r'\((.+?)\)').firstMatch(raw);
    if (timeMatch != null) {
      _setupTimeOfDay = timeMatch.group(1) ?? '';
      final datePart = raw.replaceFirst(timeMatch.group(0)!, '').trim();
      try {
        _setupPickedDate = DateFormat('d MMMM yyyy').parse(datePart);
      } catch (_) {}
    } else {
      try {
        _setupPickedDate = DateFormat('d MMMM yyyy').parse(raw);
      } catch (_) {
        // Legacy free-text — leave picker empty, existing string will be used
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactPersonController.dispose();
    _contactPhoneController.dispose();
    for (final c in _itemControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Date pickers ─────────────────────────────────────────────────────────

  Future<void> _pickDateRange() async {
    final now = DateTime.now().subtract(const Duration(days: 1));
    final range = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
      initialDateRange: DateTimeRange(start: _startDate!, end: _endDate!),
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

  // ── Item management ───────────────────────────────────────────────────────

  void _showAddItemSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => AddCategoryItemSheet(onAdd: _onItemAdded),
    );
  }

  void _onItemAdded(EventCategoryItem item) {
    setState(() {
      _items.add(item);
      _itemControllers[item.id] = _ItemControllers(item: item);
    });
  }

  void _removeItem(String id) {
    setState(() {
      _items.removeWhere((e) => e.id == id);
      _itemControllers.remove(id)?.dispose();
    });
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select event dates.')),
      );
      return;
    }

    final resolvedSetupDate = _setupPickedDate != null
        ? _composedSetupDate
        : widget.event.setupDate; // keep original if untouched

    setState(() => _saving = true);

    final updatedItems = _items.map((item) {
      final ctrl = _itemControllers[item.id];
      return ctrl != null ? ctrl.applyTo(item) : item;
    }).toList();

    final cp = _contactPersonController.text.trim();
    final ph = _contactPhoneController.text.trim();

    final updatedEvent = widget.event.copyWith(
      name:          _nameController.text.trim(),
      address:       _addressController.text.trim(),
      setupDate:     resolvedSetupDate,
      startDate:     _startDate!,
      endDate:       _endDate!,
      contactPerson: cp.isNotEmpty ? cp : null,
      contactPhone:  ph.isNotEmpty ? ph : null,
      items:         updatedItems,
    );

    try {
      await ref.read(eventRepositoryProvider).updateEvent(updatedEvent);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event updated successfully!')),
        );
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = _startDate == null || _endDate == null
        ? 'Tap to select From → To dates'
        : '${DateFormat('MMM d, yyyy').format(_startDate!)}  →  '
            '${DateFormat('MMM d, yyyy').format(_endDate!)}';

    final setupLabel = _setupPickedDate == null
        ? (widget.event.setupDate.isNotEmpty
            ? widget.event.setupDate      // show legacy text
            : 'Tap to select setup date')
        : DateFormat('d MMMM yyyy').format(_setupPickedDate!);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Event')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Event Details Card ─────────────────────────────────
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
                        pickedDate:   _setupPickedDate,
                        setupLabel:   setupLabel,
                        selectedTime: _setupTimeOfDay,
                        onPickDate:   _pickSetupDate,
                        onSelectTime: (t) =>
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
              const SizedBox(height: 4),
              Text(
                'Edit qty, sizes & notes inline. Add or remove items as needed.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),

              if (_items.isEmpty)
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
                      Text('No items yet. Tap "Add Item" to begin.',
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
                  itemCount: _items.length,
                  separatorBuilder: (context, i) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final ctrl = _itemControllers[item.id]!;
                    return _EditableItemCard(
                      index:       index,
                      item:        item,
                      controllers: ctrl,
                      onRemove:    () => _removeItem(item.id),
                    );
                  },
                ),
            ],
          ),
        ),
      ),

      floatingActionButton: _saving
          ? FloatingActionButton.extended(
              heroTag: null,
              onPressed: null,
              icon: const SizedBox(
                  height: 20, width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white)),
              label: const Text('Saving...'),
            )
          : FloatingActionButton.extended(
              heroTag: null,
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save Changes'),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// ── Setup Date Field (shared UI) ──────────────────────────────────────────────
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
                borderSide: BorderSide(
                    color: theme.colorScheme.primary, width: 2),
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

        if (pickedDate != null) ...[
          const SizedBox(height: 10),
          Text('Time of Day',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _kTimeSlots.map((slot) {
              final value    = '${slot.$1} · ${slot.$2}';
              final selected = selectedTime == value;
              return ChoiceChip(
                selected:      selected,
                onSelected:    (_) => onSelectTime(selected ? '' : value),
                selectedColor: theme.colorScheme.primaryContainer,
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 6),
                label: Column(
                  mainAxisSize:       MainAxisSize.min,
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
                      'Will save as: ${DateFormat('d MMMM yyyy').format(pickedDate!)} ($selectedTime)',
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

// ── Editable item card ────────────────────────────────────────────────────────
class _EditableItemCard extends StatelessWidget {
  final int index;
  final EventCategoryItem item;
  final _ItemControllers controllers;
  final VoidCallback onRemove;

  const _EditableItemCard({
    required this.index,
    required this.item,
    required this.controllers,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                  child: Text('Item ${index + 1}',
                      style: TextStyle(
                        color:      theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize:   12,
                      )),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(item.categoryName,
                      style: const TextStyle(fontSize: 12)),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Remove item',
                  onPressed: onRemove,
                ),
              ],
            ),

            if (item.subcategoryName.isNotEmpty &&
                item.subcategoryName != '—') ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.subdirectory_arrow_right,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(item.subcategoryName,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ],

            const Divider(height: 24),

            TextFormField(
              controller: controllers.qty,
              decoration: const InputDecoration(
                labelText:  'Quantity *',
                prefixIcon: Icon(Icons.format_list_numbered),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if ((int.tryParse(v) ?? 0) < 1) return 'Must be ≥ 1';
                return null;
              },
            ),
            const SizedBox(height: 12),

            _EditDimRow(
              leftCtrl: controllers.length, leftLabel: 'Length',
              leftIcon: Icons.straighten,
              rightCtrl: controllers.width, rightLabel: 'Width',
              rightIcon: Icons.swap_horiz,
              showMultiply: true,
            ),
            const SizedBox(height: 10),

            _EditDimRow(
              leftCtrl: controllers.height, leftLabel: 'Height',
              leftIcon: Icons.height,
              rightCtrl: controllers.depth, rightLabel: 'Depth',
              rightIcon: Icons.layers_outlined,
              showMultiply: false,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: controllers.notes,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText:  'Additional Notes (Optional)',
                prefixIcon: Icon(Icons.notes),
                hintText:   'Special requirements…',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dimension row ─────────────────────────────────────────────────────────────
class _EditDimRow extends StatelessWidget {
  final TextEditingController leftCtrl;
  final String leftLabel;
  final IconData leftIcon;
  final TextEditingController rightCtrl;
  final String rightLabel;
  final IconData rightIcon;
  final bool showMultiply;

  const _EditDimRow({
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
