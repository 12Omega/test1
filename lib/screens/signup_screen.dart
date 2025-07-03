import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_parking_app/screens/login_screen.dart';
import 'package:smart_parking_app/services/auth_service.dart';
import 'package:smart_parking_app/utils/constants.dart';
import 'package:smart_parking_app/widgets/custom_button.dart';
import 'package:smart_parking_app/widgets/custom_text_field.dart';
// import 'package:smart_parking_app/domain/entities/user_entity.dart'; // Unused

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      // Call signUp. If it doesn't throw, registration is successful.
      // The returned UserEntity is not explicitly used here, so we can omit assigning it.
      await authService.signUp(
          _emailController.text.trim(), // email
          _passwordController.text,     // password
          _fullNameController.text.trim() // name
      );

      // If signUp is successful (doesn't throw)
      if (mounted) { // Check mounted before UI operations
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please log in.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
      // No 'else' here. If not mounted, we just don't do UI things.
      // Error messages should be handled by the catch block.
    } catch (e) {
      // It's good practice to give a more specific error message if possible.
      // For now, using a generic one, but you might inspect 'e' for details.
      // For example, if AuthService throws a specific AuthException with a message.
      if (mounted) { // Check mounted before calling setState
        setState(() {
          // Example: If e has a message property: _errorMessage = e.message;
          // Or based on type of e.
          _errorMessage = 'Registration failed. Email might be in use or another error occurred.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Sign up to get started with SmartPark',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  CustomTextField(
                    controller: _fullNameController,
                    labelText: 'Full Name', // label -> labelText
                    hintText: 'Enter your full name', // hint -> hintText
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                    icon: Icons.person_outline, // prefixIcon -> icon
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Email', // label -> labelText
                    hintText: 'Enter your email', // hint -> hintText
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    icon: Icons.email_outlined, // prefixIcon -> icon
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    labelText: 'Password', // label -> labelText
                    hintText: 'Enter your password', // hint -> hintText
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    icon: Icons.lock_outline, // prefixIcon -> icon
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirm Password', // label -> labelText
                    hintText: 'Confirm your password', // hint -> hintText
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords don\'t match';
                      }
                      return null;
                    },
                    icon: Icons.lock_outline, // prefixIcon -> icon
                  ),
                  const SizedBox(height: 24),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  CustomButton(
                    label: 'Sign Up',
                    isLoading: _isLoading,
                    onPressed: _signup,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account?',
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Sign In'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
