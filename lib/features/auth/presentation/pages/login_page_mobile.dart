import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Narrow-viewport (<900px) login layout: the brand panel is hidden (no
/// room for it), replaced by a compact mascot + title above the [form],
/// which floats in its own white card on top of the Scaffold's dark
/// background instead of sitting directly on it.
class LoginPageMobile extends StatelessWidget {
  const LoginPageMobile({super.key, required this.form});

  final Widget form;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: SizedBox(
                  width: 240,
                  child: Lottie.asset(
                    'assets/lottie/login_animation.json',
                    repeat: true,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text(
                  'Cerro Ratrix',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: form,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
