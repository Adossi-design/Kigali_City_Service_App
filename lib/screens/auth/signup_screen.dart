import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

// Sign up screen — lets new users create an account
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // handles account creation and sends verification email
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authServiceProvider).signUp(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      // shows success message and goes back to login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '✉️ Verification email sent! Please check your inbox.',
                style: GoogleFonts.dmSans()),
            backgroundColor: AppTheme.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(
          () => _errorMessage = 'Registration failed. Try a different email.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account',
            style: GoogleFonts.syne(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.navyCard,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.arrow_back, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // input fields for name, email, password and confirmation
                AppTextField(
                  label: 'Full Name',
                  hint: 'Jean Baptiste',
                  controller: _nameController,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter your name' : null,
                ),
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
                  hint: 'Min. 6 characters',
                  controller: _passwordController,
                  obscureText: true,
                  validator: (v) => v == null || v.length < 6
                      ? 'Password must be at least 6 characters'
                      : null,
                ),
                AppTextField(
                  label: 'Confirm Password',
                  hint: 'Repeat password',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  validator: (v) => v != _passwordController.text
                      ? 'Passwords do not match'
                      : null,
                ),

                // shows error message if registration fails
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.red.withOpacity(0.3)),
                    ),
                    child: Text(_errorMessage!,
                        style: GoogleFonts.dmSans(
                            color: AppTheme.red, fontSize: 13)),
                  ),
                  const SizedBox(height: 14),
                ],

                // create account button with loading indicator
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: AppTheme.navy, strokeWidth: 2))
                        : const Text('📝  Create Account'),
                  ),
                ),

                const SizedBox(height: 20),

                // link back to login screen
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ',
                        style: GoogleFonts.dmSans(
                            color: AppTheme.muted, fontSize: 13)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text('Sign In',
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
