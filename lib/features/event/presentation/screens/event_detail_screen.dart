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
  final EventEntity event;
  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    final isUpcoming = !event.isCompleted && event.startDate.isAfter(DateTime.now());

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
                event.name,
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
                      event.isCompleted ? Colors.green : theme.colorScheme.primary,
                      event.isCompleted 
                        ? Colors.green.withValues(alpha: 0.6)
                        : theme.colorScheme.primary.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    event.isCompleted ? Icons.check_circle : Icons.event,
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
                onPressed: () => _showPdfPreview(context),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Event',
                onPressed: () => context.push('/home/event-detail/edit', extra: event),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete Event',
                color: theme.colorScheme.error,
                onPressed: () => _confirmDelete(context, ref),
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Status Badges ─────────────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: event.isCompleted
                            ? Colors.green.withValues(alpha: 0.1)
                            : isUpcoming
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                        border: event.isCompleted 
                            ? Border.all(color: Colors.green.withValues(alpha: 0.5))
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            event.isCompleted 
                              ? Icons.check_circle 
                              : isUpcoming ? Icons.upcoming : Icons.history,
                            size: 16,
                            color: event.isCompleted
                              ? Colors.green
                              : isUpcoming
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            event.isCompleted 
                              ? 'Completed'
                              : isUpcoming ? 'Upcoming' : 'Past',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: event.isCompleted
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
                      onPressed: () => _toggleCompletion(ref),
                      icon: Icon(event.isCompleted ? Icons.undo : Icons.check_circle),
                      label: Text(event.isCompleted ? 'Mark Active' : 'Mark Completed'),
                      style: TextButton.styleFrom(
                        foregroundColor: event.isCompleted ? theme.colorScheme.outline : Colors.green,
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
                      value: dateFormat.format(event.startDate),
                    ),
                    const Divider(height: 20),
                    _InfoRow(
                      icon: Icons.event_available,
                      label: 'To',
                      value: dateFormat.format(event.endDate),
                    ),
                    const Divider(height: 20),
                    _InfoRow(
                      icon: Icons.build_circle_outlined,
                      label: 'Setup Date',
                      value: dateFormat.format(event.setupDate),
                    ),
                    const Divider(height: 20),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      label: 'Address',
                      value: event.address,
                    ),
                    if (event.contactPerson?.isNotEmpty == true) ...[
                      const Divider(height: 20),
                      _InfoRow(
                        icon: Icons.person_outline,
                        label: 'Contact Person',
                        value: event.contactPerson!,
                      ),
                    ],
                    if (event.contactPhone?.isNotEmpty == true) ...[
                      const Divider(height: 20),
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Contact Phone',
                        value: event.contactPhone!,
                      ),
                    ],
                    const Divider(height: 20),
                    _InfoRow(
                      icon: Icons.inventory_2_outlined,
                      label: 'Items',
                      value: '${event.items.length} category item(s)',
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Category Items ────────────────────────────────────
                if (event.items.isNotEmpty) ...[
                  Text(
                    'Category Requirements',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...event.items.asMap().entries.map(
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
        onPressed: () => _showPdfPreview(context),
        icon: const Icon(Icons.print),
        label: const Text('Export PDF'),
      ),
    );
  }

  void _toggleCompletion(WidgetRef ref) async {
    await ref.read(eventRepositoryProvider).toggleEventCompletion(event.id, !event.isCompleted);
  }

  void _showPdfPreview(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Event Receipt Preview')),
          body: PdfPreview(
            build: (format) => EventPdfGenerator.generateReceipt(event),
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

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.name}"? This cannot be undone.'),
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
              await ref.read(eventRepositoryProvider).deleteEvent(event.id);
              if (context.mounted) context.pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Dimension helpers ─────────────────────────────────────────────────────────
bool _detailHasDimensions(EventCategoryItem item) =>
    item.height?.isNotEmpty == true ||
    item.length?.isNotEmpty == true ||
    item.lengthB?.isNotEmpty == true ||
    item.width?.isNotEmpty == true ||
    item.itemHeight?.isNotEmpty == true ||
    item.depth?.isNotEmpty == true ||
    item.size?.isNotEmpty == true;

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
                  // Row 1 — H × L
                  if (item.height?.isNotEmpty == true || item.length?.isNotEmpty == true)
                    _DetailChip(
                      icon: Icons.height,
                      text: [
                        if (item.height?.isNotEmpty == true) item.height!,
                        if (item.length?.isNotEmpty == true) item.length!,
                      ].join(' × '),
                      color: theme.colorScheme.secondary,
                    ),
                  // Row 2 — L × W
                  if (item.lengthB?.isNotEmpty == true || item.width?.isNotEmpty == true)
                    _DetailChip(
                      icon: Icons.straighten,
                      text: [
                        if (item.lengthB?.isNotEmpty == true) item.lengthB!,
                        if (item.width?.isNotEmpty == true) item.width!,
                      ].join(' × '),
                      color: theme.colorScheme.secondary,
                    ),
                  // Row 3 — H
                  if (item.itemHeight?.isNotEmpty == true)
                    _DetailChip(
                      icon: Icons.height_outlined,
                      text: 'H: ${item.itemHeight}',
                      color: theme.colorScheme.secondary,
                    ),
                  // Row 3 — D
                  if (item.depth?.isNotEmpty == true)
                    _DetailChip(
                      icon: Icons.layers_outlined,
                      text: 'D: ${item.depth}',
                      color: theme.colorScheme.secondary,
                    ),
                  // Legacy fallback
                  if (item.height == null && item.length == null &&
                      item.lengthB == null && item.width == null &&
                      item.itemHeight == null && item.depth == null &&
                      item.size?.isNotEmpty == true)
                    _DetailChip(
                      icon: Icons.straighten,
                      text: 'Size: ${item.size}',
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
