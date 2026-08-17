import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../rates/presentation/rates_colors.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    context.read<AuthBloc>().add(
          AuthSignInRequested(email: _email.text.trim(), password: _password.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RatesColors.pageBg,
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) => prev.error != curr.error && curr.error != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                backgroundColor: RatesColors.destructive,
                content: Text(state.error!),
              ),
            );
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final showBrandPanel = constraints.maxWidth >= 900;
            return Row(
              children: [
                if (showBrandPanel) const Expanded(child: _BrandPanel()),
                Expanded(
                  flex: showBrandPanel ? 1 : 1,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 380),
                        child: _LoginForm(
                          email: _email,
                          password: _password,
                          obscurePassword: _obscurePassword,
                          onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                          onSubmit: () => _submit(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: RatesColors.sidebarBg,
      padding: const EdgeInsets.all(56),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: _Glow(color: RatesColors.primary.withValues(alpha: 0.16)),
          ),
          Positioned(
            bottom: -100,
            left: -60,
            child: _Glow(color: RatesColors.custom.withValues(alpha: 0.10)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 18,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: RatesColors.primary, width: 2.5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CERRO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.45), letterSpacing: 1)),
                      const Text('RATRIX', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                'Rate management,\nbuilt for freight teams.',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white, height: 1.25, letterSpacing: -0.4),
              ),
              const SizedBox(height: 14),
              Text(
                'Publish rates, manage client-specific pricing, and configure surcharges from one place.',
                style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.6), height: 1.5),
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

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.email,
    required this.password,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  final TextEditingController email;
  final TextEditingController password;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.select((AuthBloc b) => b.state.isSubmitting);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Welcome back', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: RatesColors.textBody, letterSpacing: -0.3)),
        const SizedBox(height: 6),
        const Text('Sign in to manage your rates.', style: TextStyle(fontSize: 14, color: RatesColors.textMuted)),
        const SizedBox(height: 32),
        const Text('Email', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: RatesColors.textMutedStrong)),
        const SizedBox(height: 8),
        ShadInput(
          controller: email,
          placeholder: const Text('you@company.com'),
          keyboardType: TextInputType.emailAddress,
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: 20),
        const Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: RatesColors.textMutedStrong)),
        const SizedBox(height: 8),
        ShadInput(
          controller: password,
          placeholder: const Text('••••••••'),
          obscureText: obscurePassword,
          onSubmitted: (_) => onSubmit(),
          trailing: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: onToggleObscure,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  obscurePassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                  size: 16,
                  color: RatesColors.textMuted,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ShadButton(
            gradient: RatesColors.primaryButtonGradient,
            onPressed: isSubmitting ? null : onSubmit,
            child: isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Sign in'),
          ),
        ),
      ],
    );
  }
}
