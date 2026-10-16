import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/router/app_router.dart';
import 'auth_bloc.dart';

/// Экран входа / регистрации (email + пароль, Google).
class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.isRegister});

  final bool isRegister;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final bloc = context.read<AuthBloc>();
    if (widget.isRegister) {
      bloc.add(AuthRegisterRequested(_email.text, _password.text, name: _name.text));
    } else {
      bloc.add(AuthEmailSignInRequested(_email.text, _password.text));
    }
  }

  void _resetPassword() {
    final s = context.s;
    final email = _email.text.trim();
    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.enterEmailFirst)));
      return;
    }
    context.read<AuthBloc>().add(AuthPasswordResetRequested(email));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    const border = OutlineInputBorder();

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listenWhen: (p, c) => p.noticeTick != c.noticeTick,
          listener: (context, state) {
            final notice = state.notice;
            if (notice == null) return;
            final base = s.authNotice(notice);
            final text = (state.customMessage != null &&
                    state.customMessage!.isNotEmpty &&
                    notice != AuthNotice.operationNotAllowed)
                ? '$base\n(${state.customMessage})'
                : base;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(text),
                duration: const Duration(seconds: 6),
                backgroundColor: notice == AuthNotice.resetEmailSent
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
              ),
            );
          },
          builder: (context, state) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(Icons.auto_stories, size: 64, color: theme.colorScheme.primary),
                        const SizedBox(height: 8),
                        Text(
                          'Reading Tracker',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.isRegister ? s.registerTitle : s.loginTitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 24),
                        if (widget.isRegister) ...[
                          TextFormField(
                            controller: _name,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(labelText: s.nameLabel, border: border),
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(labelText: 'Email', border: border),
                          validator: (v) {
                            final t = v?.trim() ?? '';
                            return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)
                                ? null
                                : s.invalidEmail;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _password,
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          autofillHints: [
                            widget.isRegister
                                ? AutofillHints.newPassword
                                : AutofillHints.password,
                          ],
                          decoration: InputDecoration(
                            labelText: s.passwordLabel,
                            border: border,
                            suffixIcon: IconButton(
                              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) =>
                              (v == null || v.length < 6) ? s.passwordTooShort : null,
                        ),
                        if (!widget.isRegister)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: state.busy ? null : _resetPassword,
                              child: Text(s.forgotPassword),
                            ),
                          )
                        else
                          const SizedBox(height: 16),
                        FilledButton(
                          onPressed: state.busy ? null : _submit,
                          child: state.busy
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(widget.isRegister ? s.registerAction : s.loginAction),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: state.busy
                              ? null
                              : () => context
                                  .read<AuthBloc>()
                                  .add(const AuthGoogleSignInRequested()),
                          icon: const Icon(Icons.login),
                          label: Text(s.continueWithGoogle),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => context.goNamed(
                            widget.isRegister ? AppRoutes.login : AppRoutes.register,
                          ),
                          child: Text(widget.isRegister ? s.haveAccount : s.noAccount),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: state.busy
                              ? null
                              : () => context.read<AuthBloc>().add(
                                    const AuthEmailSignInRequested(
                                      'student@almau.kz',
                                      'password123',
                                    ),
                                  ),
                          icon: const Icon(Icons.flash_on, size: 18),
                          label: Text(s.demoSignIn),
                        ),
                        TextButton.icon(
                          onPressed: state.busy
                              ? null
                              : () => context
                                  .read<AuthBloc>()
                                  .add(const AuthOfflineSignInRequested()),
                          icon: const Icon(Icons.cloud_off, size: 18),
                          label: Text(s.offlineSignIn),
                        ),
                      ],
                    ),
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
