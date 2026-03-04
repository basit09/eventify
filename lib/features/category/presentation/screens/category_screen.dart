import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/firebase_category_repository.dart';
import '../controllers/category_controller.dart';
import '../widgets/add_category_dialogs.dart';

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final theme = Theme.of(context);

    // Listen to category controller for errors
    ref.listen<AsyncValue<void>>(
      categoryControllerProvider,
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories & Items'),
        elevation: 0,
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 80,
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No categories added yet.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                clipBehavior: Clip.antiAlias,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
                ),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.folder_outlined,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(
                    category.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${category.subcategories.length} items'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        tooltip: 'Add Subcategory',
                        color: theme.colorScheme.primary,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AddSubcategoryDialog(category: category),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: theme.colorScheme.error,
                        onPressed: () {
                          _confirmDelete(
                            context,
                            title: 'Delete Category',
                            content: 'Are you sure you want to delete "${category.name}" and all its subcategories?',
                            onConfirm: () {
                              ref.read(categoryControllerProvider.notifier).deleteCategory(category.id);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  children: category.subcategories.isEmpty
                      ? [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'No subcategories added.',
                              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                            ),
                          )
                        ]
                      : category.subcategories.map((sub) {
                          return ListTile(
                            contentPadding: const EdgeInsets.only(left: 72, right: 16),
                            title: Text(sub.name),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              color: theme.colorScheme.error,
                              onPressed: () {
                                _confirmDelete(
                                  context,
                                  title: 'Delete Subcategory',
                                  content: 'Remove "${sub.name}" from ${category.name}?',
                                  onConfirm: () {
                                    ref.read(categoryControllerProvider.notifier).deleteSubcategory(category.id, sub.id);
                                  },
                                );
                              },
                            ),
                          );
                        }).toList(),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            builder: (context) => const AddCategorySheet(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
    );
  }

  void _confirmDelete(BuildContext context, {required String title, required String content, required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
