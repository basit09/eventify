import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/theme_provider.dart';
import '../../../authentication/data/repositories/firebase_auth_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the reactive auth stream so the screen rebuilds on any auth change.
    final user = ref.watch(authStateProvider).when(
      data:    (u) => u,
      loading: ()  => null,
      error:   (e, st) => null,
    );
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              user != null && user.email.isNotEmpty
                  ? user.email[0].toUpperCase()
                  : 'U',
              style: TextStyle(
                fontSize: 40,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user != null ? user.email : 'Unknown User',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: themeMode == ThemeMode.dark || 
                    (themeMode == ThemeMode.system && 
                     MediaQuery.platformBrightnessOf(context) == Brightness.dark),
              onChanged: (value) {
                ref.read(themeModeControllerProvider.notifier).toggleTheme();
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              ref.read(authRepositoryProvider).signOut();
            },
          ),
        ],
      ),
    );
  }
}
