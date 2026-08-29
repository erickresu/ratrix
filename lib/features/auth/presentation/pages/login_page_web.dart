import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../rates/presentation/rates_colors.dart';

/// Wide-viewport (>=900px) login layout: a full-height brand panel with the
/// mascot animation on the left, the sign-in [form] centered on the right.
class LoginPageWeb extends StatelessWidget {
  const LoginPageWeb({super.key, required this.form});

  final Widget form;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: _BrandPanel()),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: form,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.sidebarBg,
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: _Glow(color: context.colors.primary.withValues(alpha: 0.16)),
          ),
          Positioned(
            bottom: -100,
            left: -60,
            child: _Glow(color: context.colors.custom.withValues(alpha: 0.10)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.3,
                    child: Lottie.asset(
                      'assets/lottie/login_animation.json',
                      repeat: true,
                    ),
                  ),
                ),
              ),
              SizedBox(
                child: Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cerro Ratrix',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.25,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Publish rates, manage client-specific pricing, and configure surcharges from one place.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withValues(alpha: 0.6),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
