import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:grad_project/features/auth/presentation/bloc/change_password_bloc.dart';
import 'package:grad_project/features/auth/presentation/bloc/change_password_event.dart';
import 'package:grad_project/features/auth/presentation/bloc/change_password_state.dart';
import 'package:grad_project/features/widgets/button.dart';

class ChangePassword extends StatelessWidget {
  const ChangePassword({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<ChangePasswordBloc>(),
      child: const _ChangePasswordView(),
    );
  }
}

class _ChangePasswordView extends StatefulWidget {
  const _ChangePasswordView();

  @override
  State<_ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<_ChangePasswordView> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validate() {
    final current = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      return 'All fields are required.';
    }
    if (newPass.length < 8) {
      return 'New password must be at least 8 characters long.';
    }
    if (newPass != confirm) {
      return 'New password and confirm password do not match.';
    }
    return null;
  }

  void _clearFields() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  void _onSubmit() {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    context.read<ChangePasswordBloc>().add(
          ChangePasswordSubmitted(
            currentPassword: _currentPasswordController.text.trim(),
            newPassword: _newPasswordController.text.trim(),
            confirmPassword: _confirmPasswordController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChangePasswordBloc, ChangePasswordState>(
      listener: (context, state) {
        if (state is ChangePasswordSuccess) {
          _clearFields();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green[700],
                behavior: SnackBarBehavior.floating,
              ),
            );
        } else if (state is ChangePasswordFailure) {
          String errorMessage = state.message;
          if (state.errors != null && state.errors!.isNotEmpty) {
            errorMessage = state.errors!.join('\n');
          }
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red[700],
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
              ),
            );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 1,
          title: const Text(
            'Change Password',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF163D69),
              fontFamily: "poppins",
            ),
          ),
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
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lock_outlined, color: Colors.black, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Change Password",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: "poppins",
                    ),
                  ),
                ],
              ),
              Text(
                "Update your password to keep your account secure.",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                  fontFamily: "poppins",
                ),
              ),
              const SizedBox(height: 25),
              Container(
                width: 340,
                height: 433,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFECECEC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildField(
                      "Current Password",
                      "enter current password",
                      _currentPasswordController,
                      _obscureCurrent,
                      () => setState(() => _obscureCurrent = !_obscureCurrent),
                    ),
                    const SizedBox(height: 24),
                    _buildField(
                      "New Password",
                      "enter new password",
                      _newPasswordController,
                      _obscureNew,
                      () => setState(() => _obscureNew = !_obscureNew),
                    ),
                    const SizedBox(height: 24),
                    _buildField(
                      "Confirm Password",
                      "confirm new password",
                      _confirmPasswordController,
                      _obscureConfirm,
                      () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      height: 80,
                      width: 317,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFFE3EEFF),
                        border: Border.all(color: const Color(0xFF89B6FC)),
                      ),
                      child: Text(
                        textAlign: TextAlign.justify,
                        "Password must be at least 8 characters long and include a mix of letters, numbers, and special characters.",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF438DFF),
                          fontFamily: "inter",
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
                builder: (context, state) {
                  final isLoading = state is ChangePasswordLoading;
                  return GradientButton(
                    width: 338,
                    height: 48,
                    borderRadius: 10,
                    onPressed: isLoading ? () {} : _onSubmit,
                    text: isLoading ? "Updating..." : "Update Password",
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    String hint,
    TextEditingController controller,
    bool obscure,
    VoidCallback onToggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.black87,
            fontFamily: "poppins",
          ),
        ),
        const SizedBox(height: 8),
        Container(
          color: Color(0xFFF2F6FC),
          height: 41,
          width: 317,
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.6)),
            maxLines: 1,
            decoration: InputDecoration(
              suffixIcon: GestureDetector(
                onTap: onToggle,
                child: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                ),
              ),
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 14,
                fontFamily: "poppins",
                fontWeight: FontWeight.w400,
                color: Color(0xFFB3B3B3),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xFFB3B3B3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xFFB3B3B3)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
