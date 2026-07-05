import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grad_project/core/routing/app_routes.dart';
import 'package:grad_project/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:grad_project/features/auth/presentation/bloc/auth_event.dart';
import 'package:grad_project/features/auth/presentation/bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              if (state.role == 'Student') {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.studentscreen,
                  (route) => false,
                );
              } else if (state.role == 'Instructor') {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.instructorScreen,
                  (route) => false,
                );
              }
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 28),
                  _buildLoginImage(),
                  const SizedBox(height: 24),
                  _buildEmailField(),
                  const SizedBox(height: 18),
                  _buildPasswordField(),
                  const SizedBox(height: 12),
                  _buildRememberAndForgot(),
                  const SizedBox(height: 22),
                  _buildBlocLoginButton(),
                  const SizedBox(height: 20),
                  _buildSocialLoginDivider(),
                  const SizedBox(height: 20),
                  _buildSocialLoginButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back to',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: 'EduNexus ',
                    style: TextStyle(color: Color(0xFF0D253F)),
                  ),
                  TextSpan(
                    text: 'Platform',
                    style: TextStyle(color: Colors.orange),
                  ),
                ],
              ),
            ),
          ],
        ),
        const ImageIcon(AssetImage('assets/images/platform.png'), size: 90),
      ],
    );
  }

  Widget _buildLoginImage() {
    return Center(
      child: Container(
        height: 140,
        width: 140,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: Image.asset('assets/images/login.png'),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Email / SSN', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'enter your email or ssn',
            suffixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email or SSN';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Password',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRememberAndForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (val) => setState(() => _rememberMe = val ?? false),
            ),
            const Text('Remember me'),
          ],
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.forgetPassword);
          },
          child: const Text(
            'Forget password?',
            style: TextStyle(color: Color(0xFF0D253F)),
          ),
        ),
      ],
    );
  }

  Widget _buildBlocLoginButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D253F), Color(0xFFE67E22)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      if (_formKey.currentState?.validate() ?? false) {
                        context.read<AuthBloc>().add(
                              LoginSubmitted(
                                ssnOrEmail: _emailController.text.trim(),
                                password: _passwordController.text,
                                rememberMe: _rememberMe,
                              ),
                            );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'LOGIN NOW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSocialLoginDivider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Expanded(child: Divider(color: Colors.grey, thickness: 1)),
        const SizedBox(width: 10),
        const Center(
          child: Text('or log in with', style: TextStyle(color: Colors.grey)),
        ),
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: Colors.grey, thickness: 1)),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Google login coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Image(
              image: AssetImage('assets/images/google.png'),
              height: 24,
              width: 24,
            ),
            label: Text(
              'Google',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontStyle: GoogleFonts.inter().fontStyle,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Microsoft login coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(
              FontAwesomeIcons.microsoft,
              color: Color.fromARGB(255, 13, 76, 128),
              size: 24,
            ),
            label: Text(
              'Microsoft',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontStyle: GoogleFonts.inter().fontStyle,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
