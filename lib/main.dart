import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'providers/providers.dart';
import 'screens/auth/login_screen.dart';
import 'screens/directory/home_shell.dart';
import 'theme/app_theme.dart';

// app entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: KigaliCityApp(),
    ),
  );
}

// root widget
class KigaliCityApp extends ConsumerWidget {
  const KigaliCityApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Kigali City Services',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: authState.when(
        loading: () => const SplashScreen(),
        error: (_, __) => const LoginScreen(),
        data: (user) {
          if (user == null) return const LoginScreen();
          if (!user.emailVerified) return const EmailVerificationScreen();
          return const HomeShell();
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🏙', style: TextStyle(fontSize: 64)),
            SizedBox(height: 20),
            CircularProgressIndicator(color: AppTheme.gold, strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}

class EmailVerificationScreen extends ConsumerWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('✉️', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 24),
              Text(
                'Verify Your Email',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.white,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'A verification link was sent to your email address. Please click it to continue.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppTheme.muted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // resends the verification email if the user didn't receive it
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await ref
                        .read(authServiceProvider)
                        .resendVerificationEmail();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Verification email resent!'),
                          backgroundColor: AppTheme.green,
                        ),
                      );
                    }
                  },
                  child: const Text('📨  Resend Verification Email'),
                ),
              ),
              const SizedBox(height: 12),
              // allows user to go back to login screen
              TextButton(
                onPressed: () => ref.read(authServiceProvider).signOut(),
                child: Text(
                  'Sign Out',
                  style: TextStyle(color: AppTheme.muted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
