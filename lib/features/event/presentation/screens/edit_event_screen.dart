import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/entities/event_category_item.dart';
import '../../data/repositories/firebase_event_repository.dart';

// ── Per-item controller bundle ────────────────────────────────────────────────
/// Holds all [TextEditingController]s for one editable category item.
/// [applyTo] returns a new [EventCategoryItem] with the edited values merged in.
class _ItemControllers {
  final TextEditingController qty;
  final TextEditingController height;
  final TextEditingController length;
  final TextEditingController lengthB;
  final TextEditingController width;
  final TextEditingController itemHeight;
  final TextEditingController depth;
  final TextEditingController notes;

  _ItemControllers({required EventCategoryItem item})
      : qty        = TextEditingController(text: item.quantity.toString()),
        height     = TextEditingController(text: item.height ?? ''),
        length     = TextEditingController(text: item.length ?? ''),
        lengthB    = TextEditingController(text: item.lengthB ?? ''),
        width      = TextEditingController(text: item.width ?? ''),
        itemHeight = TextEditingController(text: item.itemHeight ?? ''),
        depth      = TextEditingController(text: item.depth ?? ''),
        notes      = TextEditingController(text: item.additionalNotes ?? '');

  void dispose() {
    qty.dispose();
    height.dispose();
    length.dispose();
    lengthB.dispose();
    width.dispose();
    itemHeight.dispose();
    depth.dispose();
    notes.dispose();
  }

  /// Merge edited values back onto [original], keeping all read-only fields
  /// (id, categoryId/Name, subcategoryId/Name) unchanged.
  EventCategoryItem applyTo(EventCategoryItem original) {
    String? n(String v) => v.trim().isEmpty ? null : v.trim();
    return original.copyWith(
      quantity:        int.tryParse(qty.text.trim()) ?? original.quantity,
      height:          n(height.text),
      length:          n(length.text),
      lengthB:         n(lengthB.text),
      width:           n(width.text),
      itemHeight:      n(itemHeight.text),
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

  // Event-level controllers
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _contactPersonController;
  late final TextEditingController _contactPhoneController;

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _setupDate;
  bool _saving = false;

  // Per-item controllers — keyed by item.id
  late final Map<String, _ItemControllers> _itemControllers;

  @override
  void initState() {
    super.initState();

    // Event-level fields
    _nameController          = TextEditingController(text: widget.event.name);
    _addressController       = TextEditingController(text: widget.event.address);
    _contactPersonController = TextEditingController(text: widget.event.contactPerson ?? '');
    _contactPhoneController  = TextEditingController(text: widget.event.contactPhone ?? '');
    _startDate = widget.event.startDate;
    _endDate   = widget.event.endDate;
    _setupDate = widget.event.setupDate;

    // Item-level controllers (one bundle per item)
    _itemControllers = {
      for (final item in widget.event.items) item.id: _ItemControllers(item: item),
    };
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

  // ── Date pickers ────────────────────────────────────────────────────────────

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
    final now = DateTime.now().subtract(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: _setupDate ?? DateTime.now(),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _setupDate = picked);
  }

  // ── Save ────────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select event dates.')),
      );
      return;
    }
    if (_setupDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a setup date.')),
      );
      return;
    }

    setState(() => _saving = true);

    // Merge edited item values from controllers back into the original items
    final updatedItems = widget.event.items.map((item) {
      final ctrl = _itemControllers[item.id];
      return ctrl != null ? ctrl.applyTo(item) : item;
    }).toList();

    final cp = _contactPersonController.text.trim();
    final ph = _contactPhoneController.text.trim();

    final updatedEvent = widget.event.copyWith(
      name:          _nameController.text.trim(),
      address:       _addressController.text.trim(),
      startDate:     _startDate!,
      endDate:       _endDate!,
      setupDate:     _setupDate!,
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

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = _startDate == null || _endDate == null
        ? 'Tap to select From → To dates'
        : '${DateFormat('MMM d, yyyy').format(_startDate!)}  →  ${DateFormat('MMM d, yyyy').format(_endDate!)}';
    final setupDateLabel = _setupDate == null
        ? 'Tap to select setup date'
        : DateFormat('MMM d, yyyy').format(_setupDate!);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Event')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Event Details Card ─────────────────────────────────────
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.event_note, size: 18, color: theme.colorScheme.primary),
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
                      // ── Event Date Range ──────────────────────────────
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
                      // ── Setup Date ────────────────────────────────────
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
                              borderSide: BorderSide(
                                  color: theme.colorScheme.primary, width: 2),
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

              // ── Requirements Section ──────────────────────────────────
              Text('Requirements',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                'Edit quantity, sizes and notes for each item.',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),

              // ── Editable item cards ───────────────────────────────────
              if (widget.event.items.isEmpty)
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
                      Text('No category items on this event.',
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
                  itemCount: widget.event.items.length,
                  separatorBuilder: (context, i) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = widget.event.items[index];
                    final ctrl = _itemControllers[item.id]!;
                    return _EditableItemCard(
                      index: index,
                      item: item,
                      controllers: ctrl,
                    );
                  },
                ),
            ],
          ),
        ),
      ),

      // ── Save FAB ──────────────────────────────────────────────────────────
      floatingActionButton: _saving
          ? FloatingActionButton.extended(
              heroTag: null,
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
              heroTag: null,
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save Changes'),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// ── Editable item card ────────────────────────────────────────────────────────
/// Displays category/subcategory as read-only labels and exposes inline
/// editable fields for quantity, all dimension rows, and notes.
class _EditableItemCard extends StatelessWidget {
  final int index;
  final EventCategoryItem item;
  final _ItemControllers controllers;

  const _EditableItemCard({
    required this.index,
    required this.item,
    required this.controllers,
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
            // ── Header: item badge + category/subcategory ───────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Item ${index + 1}',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(item.categoryName,
                      style: const TextStyle(fontSize: 12)),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),

            if (item.subcategoryName.isNotEmpty &&
                item.subcategoryName != '—') ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.subdirectory_arrow_right,
                      size: 14, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    item.subcategoryName,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],

            const Divider(height: 24),

            // ── Quantity ────────────────────────────────────────────────
            TextFormField(
              controller: controllers.qty,
              decoration: const InputDecoration(
                labelText: 'Quantity *',
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

            // ── Row 1 — H × L ───────────────────────────────────────────
            _EditDimRow(
              leftCtrl: controllers.height,   leftLabel: 'H', leftIcon: Icons.height,
              rightCtrl: controllers.length,  rightLabel: 'L', rightIcon: Icons.straighten,
              showMultiply: true,
            ),
            const SizedBox(height: 10),

            // ── Row 2 — L × W ───────────────────────────────────────────
            _EditDimRow(
              leftCtrl: controllers.lengthB, leftLabel: 'L', leftIcon: Icons.straighten,
              rightCtrl: controllers.width,  rightLabel: 'W', rightIcon: Icons.swap_horiz,
              showMultiply: true,
            ),
            const SizedBox(height: 10),

            // ── Row 3 — H   D (no ×) ────────────────────────────────────
            _EditDimRow(
              leftCtrl: controllers.itemHeight, leftLabel: 'H', leftIcon: Icons.height_outlined,
              rightCtrl: controllers.depth,     rightLabel: 'D', rightIcon: Icons.layers_outlined,
              showMultiply: false,
            ),
            const SizedBox(height: 12),

            // ── Notes ───────────────────────────────────────────────────
            TextFormField(
              controller: controllers.notes,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Additional Notes (Optional)',
                prefixIcon: Icon(Icons.notes),
                hintText: 'Special requirements…',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable dimension-row widget ─────────────────────────────────────────────
class _EditDimRow extends StatelessWidget {
  final TextEditingController leftCtrl;
  final String leftLabel;
  final IconData leftIcon;
  final TextEditingController rightCtrl;
  final String rightLabel;
  final IconData rightIcon;
  final bool showMultiply;

  const _EditDimRow({
    required this.leftCtrl,
    required this.leftLabel,
    required this.leftIcon,
    required this.rightCtrl,
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
            controller: leftCtrl,
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
            controller: rightCtrl,
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
