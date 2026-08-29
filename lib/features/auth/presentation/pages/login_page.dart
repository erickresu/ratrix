import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../rates/presentation/rates_colors.dart';
import '../bloc/auth_bloc.dart';
import 'login_page_mobile.dart';
import 'login_page_web.dart';

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
    // Below 900px the brand panel (which carries the black background on
    // desktop) is hidden entirely — carry that same black canvas onto the
    // Scaffold itself for mobile, with the form floating in its own white
    // card instead of sitting directly on light pageBg.
    final isMobile = MediaQuery.sizeOf(context).width < 900;
    return Scaffold(
      backgroundColor: isMobile ? context.colors.sidebarBg : context.colors.pageBg,
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) =>
            prev.error != curr.error && curr.error != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                backgroundColor: context.colors.destructive,
                content: Text(state.error!),
              ),
            );
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final form = LoginForm(
              email: _email,
              password: _password,
              obscurePassword: _obscurePassword,
              onToggleObscure: () => setState(
                () => _obscurePassword = !_obscurePassword,
              ),
              onSubmit: () => _submit(context),
            );
            return constraints.maxWidth >= 900
                ? LoginPageWeb(form: form)
                : LoginPageMobile(form: form);
          },
        ),
      ),
    );
  }
}

/// Email/password fields + submit button, shared by [LoginPageWeb] and
/// [LoginPageMobile] — only the surrounding layout differs between them.
class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
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
        Text(
          'Welcome back',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: context.colors.textBody,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Sign in to manage your rates.',
          style: TextStyle(fontSize: 14, color: context.colors.textMuted),
        ),
        const SizedBox(height: 32),
        Text(
          'Email',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.colors.textMutedStrong,
          ),
        ),
        const SizedBox(height: 8),
        ShadInput(
          controller: email,
          placeholder: const Text('you@company.com'),
          keyboardType: TextInputType.emailAddress,
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: 20),
        Text(
          'Password',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.colors.textMutedStrong,
          ),
        ),
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
                  obscurePassword
                      ? CupertinoIcons.eye
                      : CupertinoIcons.eye_slash,
                  size: 16,
                  color: context.colors.textMuted,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ShadButton(
            gradient: context.colors.primaryButtonGradient,
            onPressed: isSubmitting ? null : onSubmit,
            child: isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Sign in'),
          ),
        ),
      ],
    );
  }
}
