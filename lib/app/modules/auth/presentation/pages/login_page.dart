import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/login_controller.dart';
import '../../../../core/mixins/messages_mixin.dart';
import '../../../../core/mixins/validator_mixin.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with MessagesMixin, ValidatorMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LoginController>();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppLogo(),
                const SizedBox(height: 16),
                Text(
                  'NexusFlow',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  label: 'E-mail',
                  controller: _emailController,
                  icon: Icons.email,
                  validator: validateEmail,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Senha',
                  controller: _passwordController,
                  icon: Icons.lock,
                  isPassword: true,
                  validator: (v) => validateMinLength(v, 6),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Entrar',
                  isLoading: controller.isLoading,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final success = await controller.login(
                        _emailController.text,
                        _passwordController.text,
                      );
                      if (success) {
                        if (mounted) {
                          showSuccess(context, 'Bem-vindo!');
                          Navigator.pushReplacementNamed(context, '/dashboard');
                        }
                      } else {
                        if (mounted) {
                          showError(context, controller.errorMessage ?? 'Falha na autenticação');
                        }
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.register);
                  },
                  child: const Text('Criar conta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
