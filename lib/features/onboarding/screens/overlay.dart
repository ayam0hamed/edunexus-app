import 'package:flutter/material.dart';
import 'package:grad_project/core/routing/app_routes.dart';
import 'package:grad_project/features/widgets/button.dart';

class RightSideBarOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const RightSideBarOverlay({super.key, required this.onClose});

  @override
  State<RightSideBarOverlay> createState() => _RightSideBarOverlayState();
}

class _RightSideBarOverlayState extends State<RightSideBarOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0), // 👈 يبدأ من اليمين
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() async {
    if (!_controller.isDismissed) {
      await _controller.reverse();
    }

    if (!mounted) return;

    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// الخلفية المعتمة
        GestureDetector(
          onTap: _close,
          child: Container(color: Colors.black.withOpacity(0.4)),
        ),

        /// السايد بار
        Align(
          alignment: Alignment.centerRight, // 👈 من اليمين
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              width: 219,
              height: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15,
                    offset: Offset(-5, 0), // ظل ناحية الشمال
                  ),
                ],
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _menuItem(Icons.card_giftcard, 'Features', () async {
                        await _controller.reverse();
                        if (!mounted) return;
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.features,
                        ).then((_) => _close());
                      }),
                      _menuItem(Icons.help_outline, 'How It Works', () async {
                        await _controller.reverse();
                        if (!mounted) return;
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.howItWorks,
                        ).then((_) => _close());
                      }),
                      _menuItem(Icons.edit, 'About Us', () async {
                        await _controller.reverse();
                        if (!mounted) return;
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.aboutUs,
                        ).then((_) => _close());
                      }),
                      _menuItem(Icons.login, 'Login', () async {
                        await _controller.reverse();
                        if (!mounted) return;
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.login,
                        ).then((_) => _close());
                      }),

                      const SizedBox(height: 40),

                      const Divider(),

                      const SizedBox(height: 15),
                      const Text(
                        'Contact Sales',
                        style: TextStyle(
                          color: Color(0xFF163D69),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 15),
                      const Text(
                        '1.8888.799.97',
                        style: TextStyle(
                          color: Color(0xFF163D69),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Divider(),

                      const SizedBox(height: 30),

                      GradientButton(
                        width: 156,
                        height: 32,
                        borderRadius: 10,

                        text: 'Sign Up Free',
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Inter',
                        ),
                        onPressed: () async {
                          await _controller.reverse();
                          if (!mounted) return;
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.login,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF163D69), size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 16, color: Color(0xFF163D69)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 12),
      ],
    );
  }
}
