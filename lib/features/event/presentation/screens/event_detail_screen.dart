import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../../../category/data/repositories/firebase_category_repository.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/entities/event_category_item.dart';
import '../../data/repositories/firebase_event_repository.dart';
import '../utils/pdf_generator.dart';

class EventDetailScreen extends ConsumerWidget {
  /// The event passed at navigation time — used ONLY to obtain [event.id].
  /// All rendered data comes from the live Firestore stream so the screen
  /// reflects completion toggles and edits without needing to navigate away.
  final EventEntity event;
  const EventDetailScreen({super.key, required this.event});

  // ── Helpers that require the live event ────────────────────────────────────

  void _toggleCompletion(WidgetRef ref, EventEntity live) {
    ref.read(eventRepositoryProvider)
        .toggleEventCompletion(live.id, !live.isCompleted);
  }

  void _showPdfPreview(BuildContext context, EventEntity live) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Event Receipt Preview')),
          body: PdfPreview(
            build: (format) => EventPdfGenerator.generateReceipt(live),
            allowPrinting: true,
            allowSharing: true,
            actionBarTheme: const PdfActionBarTheme(
              iconColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, EventEntity live) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text(
            'Are you sure you want to delete "${live.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(eventRepositoryProvider).deleteEvent(live.id);
              if (context.mounted) context.pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ── Subscribe to the live events stream and find this event by ID ────────
    // This ensures the screen rebuilds automatically whenever:
    //   • isCompleted is toggled
    //   • the event is edited (quantity, notes, sizes, dates, etc.)
    final live = ref.watch(eventsStreamProvider).maybeWhen(
      data: (events) {
        try {
          return events.firstWhere((e) => e.id == event.id);
        } catch (_) {
          return event; // fallback if deleted mid-session
        }
      },
      orElse: () => event,
    );

    final theme      = Theme.of(context);
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    final isUpcoming = !live.isCompleted && live.startDate.isAfter(DateTime.now());

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ──────────────────────────────────────────────
          SliverAppBar.medium(
            expandedHeight: 130,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              title: Text(
                live.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      live.isCompleted ? Colors.green : theme.colorScheme.primary,
                      live.isCompleted
                          ? Colors.green.withValues(alpha: 0.6)
                          : theme.colorScheme.primary.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    live.isCompleted ? Icons.check_circle : Icons.event,
                    size: 80,
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                tooltip: 'Download Receipt',
                onPressed: () => _showPdfPreview(context, live),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Event',
                onPressed: () =>
                    context.push('/home/event-detail/edit', extra: live),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete Event',
                color: theme.colorScheme.error,
                onPressed: () => _confirmDelete(context, ref, live),
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Status Badge + Toggle ─────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: live.isCompleted
                            ? Colors.green.withValues(alpha: 0.1)
                            : isUpcoming
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                        border: live.isCompleted
                            ? Border.all(
                                color: Colors.green.withValues(alpha: 0.5))
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            live.isCompleted
                                ? Icons.check_circle
                                : isUpcoming
                                    ? Icons.upcoming
                                    : Icons.history,
                            size: 16,
                            color: live.isCompleted
                                ? Colors.green
                                : isUpcoming
                                    ? theme.colorScheme.onPrimaryContainer
                                    : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            live.isCompleted
                                ? 'Completed'
                                : isUpcoming
                                    ? 'Upcoming'
                                    : 'Past',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: live.isCompleted
                                  ? Colors.green
                                  : isUpcoming
                                      ? theme.colorScheme.onPrimaryContainer
                                      : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _toggleCompletion(ref, live),
                      icon: Icon(live.isCompleted
                          ? Icons.undo
                          : Icons.check_circle),
                      label: Text(live.isCompleted
                          ? 'Mark Active'
                          : 'Mark Completed'),
                      style: TextButton.styleFrom(
                        foregroundColor: live.isCompleted
                            ? theme.colorScheme.outline
                            : Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Info Card ─────────────────────────────────────────
                _InfoCard(
                  children: [
                    _InfoRow(
                      icon: Icons.date_range,
                      label: 'From',
                      value: dateFormat.format(live.startDate),
                    ),
                    const Divider(height: 20),
                    _InfoRow(
                      icon: Icons.event_available,
                      label: 'To',
                      value: dateFormat.format(live.endDate),
                    ),
                    const Divider(height: 20),
                    _InfoRow(
                      icon: Icons.build_circle_outlined,
                      label: 'Setup Date',
                      value: live.setupDate.isNotEmpty ? live.setupDate : '—',
                    ),
                    const Divider(height: 20),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      label: 'Address',
                      value: live.address,
                    ),
                    if (live.contactPerson?.isNotEmpty == true) ...[
                      const Divider(height: 20),
                      _InfoRow(
                        icon: Icons.person_outline,
                        label: 'Contact Person',
                        value: live.contactPerson!,
                      ),
                    ],
                    if (live.contactPhone?.isNotEmpty == true) ...[
                      const Divider(height: 20),
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Contact Phone',
                        value: live.contactPhone!,
                      ),
                    ],
                    const Divider(height: 20),
                    _InfoRow(
                      icon: Icons.inventory_2_outlined,
                      label: 'Items',
                      value: '${live.items.length} category item(s)',
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Category Items ────────────────────────────────────
                if (live.items.isNotEmpty) ...[
                  Text(
                    'Category Requirements',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...live.items.asMap().entries.map(
                        (entry) => _CategoryItemCard(
                          index: entry.key,
                          item: entry.value,
                        ),
                      ),
                ] else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 48, color: theme.colorScheme.outline),
                          const SizedBox(height: 8),
                          Text('No category items added.',
                              style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _showPdfPreview(context, live),
        icon: const Icon(Icons.print),
        label: const Text('Export PDF'),
      ),
    );
  }
}

// ── Dimension helpers ─────────────────────────────────────────────────────────
bool _detailHasDimensions(EventCategoryItem item) =>
    item.length?.isNotEmpty == true ||
    item.width?.isNotEmpty  == true ||
    item.height?.isNotEmpty == true ||
    item.depth?.isNotEmpty  == true;

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 2),
              Text(value,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryItemCard extends ConsumerWidget {
  final int index;
  final EventCategoryItem item;

  const _CategoryItemCard({required this.index, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    String? imageUrl;
    
    categoriesAsync.whenData((categories) {
      try {
        final category = categories.firstWhere((c) => c.id == item.categoryId);
        if (item.subcategoryId.isNotEmpty) {
          final subcategory = category.subcategories.firstWhere((s) => s.id == item.subcategoryId);
          imageUrl = subcategory.imageUrl;
        }
      } catch (_) {}
    });

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            const SizedBox(height: 10),

            // Subcategory
            if (item.subcategoryName.isNotEmpty &&
                item.subcategoryName != '—') ...[
              _DetailChip(
                icon: Icons.subdirectory_arrow_right,
                text: item.subcategoryName,
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(height: 8),
            ],

            // Stats row
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _DetailChip(
                  icon: Icons.format_list_numbered,
                  text: 'Qty: ${item.quantity}',
                  color: theme.colorScheme.primary,
                ),
                if (_detailHasDimensions(item)) ...[
                  // Length × Width
                  if (item.length?.isNotEmpty == true ||
                      item.width?.isNotEmpty  == true)
                    _DetailChip(
                      icon:  Icons.straighten,
                      text:  [
                        if (item.length?.isNotEmpty == true) item.length!,
                        if (item.width?.isNotEmpty  == true) item.width!,
                      ].join(' × '),
                      color: theme.colorScheme.secondary,
                    ),
                  // Height
                  if (item.height?.isNotEmpty == true)
                    _DetailChip(
                      icon:  Icons.height,
                      text:  'H: ${item.height}',
                      color: theme.colorScheme.secondary,
                    ),
                  // Depth
                  if (item.depth?.isNotEmpty == true)
                    _DetailChip(
                      icon:  Icons.layers_outlined,
                      text:  'D: ${item.depth}',
                      color: theme.colorScheme.secondary,
                    ),
                ],
              ],
            ),

            // Image
            if (imageUrl != null && imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => const SizedBox.shrink(),
                  loadingBuilder: (ctx, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      height: 150,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
            ],

            // Notes
            if (item.additionalNotes != null &&
                item.additionalNotes!.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes,
                      size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.additionalNotes!,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _DetailChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 4),
        Text(text,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
