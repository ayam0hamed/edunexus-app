import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:grad_project/core/routing/app_routes.dart';
import 'package:grad_project/features/auth/presentation/bloc/forgot_password_bloc.dart';
import 'package:grad_project/features/auth/presentation/bloc/forgot_password_event.dart';
import 'package:grad_project/features/auth/presentation/bloc/forgot_password_state.dart';
import 'package:grad_project/features/widgets/button.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ForgotPasswordBloc>(
      create: (_) => GetIt.I<ForgotPasswordBloc>(),
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
                'Forget Password',
                style: TextStyle(
                  color: Color(0xFF003366),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: "poppins",
                ),
              ),
              const Spacer(),
              Image.asset(
                'assets/images/platform.png', // Placeholder for EduNexus logo
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
        body: BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
          listener: (context, state) {
            if (state is ForgotPasswordSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pushNamed(context, AppRoutes.checkEmail);
            } else if (state is ForgotPasswordFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(22.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/forget.png',
                            height: 140,
                            width: 140,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.lock_outline,
                              color: Color(0xFF003366),
                              size: 100,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Forgot Password',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              fontFamily: "poppins",
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Please write your email to receive a confirmation link to set a new password.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontFamily: "poppins",
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                    const Text(
                      " Your Email",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontFamily: "poppins",
                      ),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: state is! ForgotPasswordLoading,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!_isValidEmail(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'enter your email',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[500],
                          fontFamily: "inter",
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Center(
                      child: state is ForgotPasswordLoading
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF003366)),
                            )
                          : GradientButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<ForgotPasswordBloc>().add(
                                        ForgotPasswordSubmitted(
                                          email: _emailController.text.trim(),
                                        ),
                                      );
                                }
                              },
                              text: 'Confirm Email',
                              width: 347,
                              height: 48,
                              borderRadius: 10,
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontFamily: "inter",
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
