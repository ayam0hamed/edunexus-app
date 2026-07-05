import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:grad_project/core/routing/app_routes.dart';
import 'package:grad_project/features/auth/presentation/bloc/reset_password_bloc.dart';
import 'package:grad_project/features/auth/presentation/bloc/reset_password_event.dart';
import 'package:grad_project/features/auth/presentation/bloc/reset_password_state.dart';
import 'package:grad_project/features/widgets/button.dart';

class NewPassword extends StatefulWidget {
  final String? userId;
  final String? token;

  const NewPassword({
    super.key,
    this.userId,
    this.token,
  });

  @override
  State<NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isPasswordStrong(String password) {
    if (password.length < 8) return false;
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasDigit = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecial = RegExp(r'[!@#\$&*~-]').hasMatch(password);
    return hasLetter && hasDigit && hasSpecial;
  }

  @override
  Widget build(BuildContext context) {
    // Extract parameters from route arguments if available
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String userId = args?['userId'] as String? ?? widget.userId ?? '';
    final String token = args?['token'] as String? ?? widget.token ?? '';

    final bool isLinkInvalid = userId.isEmpty || token.isEmpty;

    return BlocProvider<ResetPasswordBloc>(
      create: (_) => GetIt.I<ResetPasswordBloc>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          shadowColor: const Color.fromARGB(255, 94, 92, 95),
          elevation: 1,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF003366),
              size: 20,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          titleSpacing: 0,
          title: Row(
            children: [
              const Text(
                'New Password',
                style: TextStyle(
                  color: Color(0xFF003366),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: "poppins",
                ),
              ),
              const Spacer(),
              Image.asset(
                'assets/images/platform.png',
                height: 46,
                width: 60,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.school, color: Color(0xFF003366)),
              ),
              const SizedBox(width: 8),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: "poppins",
                  ),
                  children: [
                    TextSpan(
                      text: 'Edu',
                      style: TextStyle(color: Color(0xFF163D69)),
                    ),
                    TextSpan(
                      text: 'Nexus',
                      style: TextStyle(color: Color(0xFFE56C00)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
        body: BlocConsumer<ResetPasswordBloc, ResetPasswordState>(
          listener: (context, state) {
            if (state is ResetPasswordSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            } else if (state is ResetPasswordFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (isLinkInvalid) {
              return Padding(
                padding: const EdgeInsets.all(22.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 80),
                    const SizedBox(height: 24),
                    const Text(
                      'Invalid Reset Password Link',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: "poppins",
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This reset link is invalid, expired, or missing parameters. Please request a new link.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: "poppins",
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    GradientButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.forgetPassword,
                        );
                      },
                      text: 'Request New Link',
                      width: 347,
                      height: 48,
                      borderRadius: 10,
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_outline_rounded, color: Color(0xFF163D69)),
                          SizedBox(width: 8),
                          Text(
                            "New Password",
                            style: TextStyle(
                              fontFamily: "poppins",
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          "Please enter your new password.",
                          style: TextStyle(
                            fontFamily: "poppins",
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Your New Password',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        enabled: state is! ResetPasswordLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your new password';
                          }
                          if (!_isPasswordStrong(value)) {
                            return 'Password must be at least 8 characters long and include a mix of letters, numbers, and symbols.';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'enter your password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Confirm Password',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        enabled: state is! ResetPasswordLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your new password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'confirm your password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Center(
                        child: state is ResetPasswordLoading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF003366)),
                              )
                            : GradientButton(
                                width: 365,
                                height: 48,
                                borderRadius: 10,
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<ResetPasswordBloc>().add(
                                          ResetPasswordSubmitted(
                                            userId: userId,
                                            token: token,
                                            newPassword: _passwordController.text,
                                            confirmPassword: _confirmPasswordController.text,
                                          ),
                                        );
                                  }
                                },
                                text: "Confirm Password",
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
