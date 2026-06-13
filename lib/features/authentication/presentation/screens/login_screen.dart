import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/config/env_service.dart';
import '../../../../../core/widgets/app_root.dart';
import '../controllers/login_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey            = GlobalKey<FormState>();

  // ── Secret env-switch trigger ────────────────────────────────────────────
  // Tap the app icon exactly 7 times to reveal the env switcher.
  int _tapCount = 0;
  static const _tapsRequired = 7;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onIconTap() {
    _tapCount++;
    if (_tapCount >= _tapsRequired) {
      _tapCount = 0;
      _showEnvSwitcher();
    }
  }

  void _showEnvSwitcher() {
    final current = EnvService.current;
    final next    = current == AppEnvironment.dev
        ? AppEnvironment.prod
        : AppEnvironment.dev;

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _EnvSwitcherDialog(current: current, next: next),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref.read(loginControllerProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);
    final theme      = Theme.of(context);
    final textTheme  = theme.textTheme;

    ref.listen<AsyncValue<void>>(
      loginControllerProvider,
      (_, state) {
        state.whenOrNull(
          error: (error, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:          Text(error.toString()),
                backgroundColor:  theme.colorScheme.error,
                behavior:         SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Curved header ────────────────────────────────────────────
            ClipPath(
              clipper: _HeaderClipper(),
              child: Container(
                height: 350,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── Secret tap target ─────────────────────────────
                      GestureDetector(
                        onTap: _onIconTap,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          // Generous tap area — but visually unchanged.
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.event_available_rounded,
                            size: 80,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'MA Productions',
                        style: textTheme.displayMedium?.copyWith(
                          color:      theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Manage your events seamlessly',
                        style: textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimary
                              .withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // ── Subtle env indicator (visible in header) ──────
                      _ActiveEnvChip(),
                    ],
                  ),
                ),
              ),
            ),

            // ── Login form ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Welcome Back',
                      style: textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue',
                      style: textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText:   'Email',
                        prefixIcon:  const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!v.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText:  'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: loginState.isLoading ? null : _submit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: loginState.isLoading
                          ? const SizedBox(
                              height: 24,
                              width:  24,
                              child:  CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Login',
                              style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small env chip shown in the login header ──────────────────────────────────
/// Shows the active environment so a developer can confirm which Firebase
/// project they're about to authenticate against.
/// Deliberately small and unobtrusive — users don't know what it means.
class _ActiveEnvChip extends StatelessWidget {
  const _ActiveEnvChip();

  @override
  Widget build(BuildContext context) {
    final env = EnvService.current;
    if (env == AppEnvironment.prod) {
      // Prod is normal — no chip at all.
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color:        Colors.deepOrange.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.science_outlined, size: 11, color: Colors.white),
          SizedBox(width: 5),
          Text(
            'DEV',
            style: TextStyle(
              color:         Colors.white,
              fontSize:      11,
              fontWeight:    FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Environment switcher dialog ───────────────────────────────────────────────
class _EnvSwitcherDialog extends StatelessWidget {
  final AppEnvironment current;
  final AppEnvironment next;
  const _EnvSwitcherDialog({required this.current, required this.next});

  @override
  Widget build(BuildContext context) {
    final theme       = Theme.of(context);
    final nextIsDev   = next == AppEnvironment.dev;
    final accentColor = nextIsDev ? Colors.deepOrange : Colors.green;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Coloured header ──────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor, accentColor.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Icon(Icons.developer_mode_rounded,
                    size: 36, color: Colors.white),
                const SizedBox(height: 6),
                const Text(
                  'Switch Environment',
                  style: TextStyle(
                    color:      Colors.white,
                    fontSize:   18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              children: [
                // FROM → TO cards
                Row(
                  children: [
                    Expanded(child: _EnvCard(env: current, label: 'FROM')),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(Icons.arrow_forward_rounded,
                          color: theme.colorScheme.onSurfaceVariant, size: 22),
                    ),
                    Expanded(child: _EnvCard(env: next, label: 'TO')),
                  ],
                ),

                const SizedBox(height: 16),
                Divider(color: theme.colorScheme.outlineVariant),
                const SizedBox(height: 10),

                // Warning
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:        accentColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: accentColor.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 16, color: accentColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'App will reload. Sign in again with '
                          '${next.name.toUpperCase()} credentials to '
                          'see ${next.name.toUpperCase()} data.',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: accentColor,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          AppRoot.switchEnv(next);
                        },
                        child: Text(
                          'Switch to ${next.name.toUpperCase()}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single env card (FROM / TO) ───────────────────────────────────────────────
class _EnvCard extends StatelessWidget {
  final AppEnvironment env;
  final String label;
  const _EnvCard({required this.env, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDev       = env == AppEnvironment.dev;
    final color       = isDev ? Colors.deepOrange : Colors.green;
    final icon        = isDev ? Icons.science_outlined : Icons.verified_outlined;
    final envName     = isDev ? 'DEV' : 'PROD';
    final projectHint = isDev ? 'event-management-dev' : 'event-management';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                fontSize:   10,
                fontWeight: FontWeight.w600,
                color:      Theme.of(context).colorScheme.onSurfaceVariant,
                letterSpacing: 1.0,
              )),
          const SizedBox(height: 8),
          Icon(icon, size: 26, color: color),
          const SizedBox(height: 6),
          Text(envName,
              style: TextStyle(
                fontSize:   16,
                fontWeight: FontWeight.bold,
                color:      color,
              )),
          const SizedBox(height: 4),
          Text(
            projectHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              color:    Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Curved header clipper ─────────────────────────────────────────────────────
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 80)
      ..quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 80,
      )
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
