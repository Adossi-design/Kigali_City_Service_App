import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'signup_screen.dart';

// Login screen — first screen the user sees when not signed in
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // handles sign in and shows error if email is not verified
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authServiceProvider).signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('email-not-verified')
            ? 'Please verify your email first. Check your inbox.'
            : 'Invalid email or password. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // app logo and title
                Column(
                  children: [
                    const Text('🏙', style: TextStyle(fontSize: 56)),
                    const SizedBox(height: 12),
                    Text(
                      'Kigali City',
                      style: GoogleFonts.syne(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Services & Places Directory',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppTheme.muted,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                // email and password fields
                AppTextField(
                  label: 'Email Address',
                  hint: 'you@example.rw',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || !v.contains('@')
                      ? 'Enter a valid email'
                      : null,
                ),

                AppTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passwordController,
                  obscureText: true,
                  validator: (v) => v == null || v.length < 6
                      ? 'Password must be at least 6 characters'
                      : null,
                ),

                // shows error message if login fails
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.red.withOpacity(0.3)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style:
                          GoogleFonts.dmSans(color: AppTheme.red, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // sign in button with loading indicator
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: AppTheme.navy, strokeWidth: 2))
                        : const Text('🔐  Sign In'),
                  ),
                ),

                const SizedBox(height: 20),

                // link to sign up screen
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ",
                        style: GoogleFonts.dmSans(
                            color: AppTheme.muted, fontSize: 13)),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SignupScreen())),
                      child: Text('Sign Up',
                          style: GoogleFonts.dmSans(
                            color: AppTheme.gold,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
