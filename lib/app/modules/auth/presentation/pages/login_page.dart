import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/login_controller.dart';
import '../../../../core/mixins/messages_mixin.dart';
import '../../../../core/mixins/validator_mixin.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/liquid_background.dart';
import '../../../../shared/widgets/glass_container.dart';
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
      body: LiquidBackground(
        child: Center(
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
                  const Text(
                    'NexusFlow',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Gestão de Assistência Técnica Inteligente',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 36),
                  
                  // Wrap form fields inside a breathtaking Glass Container Card
                  GlassContainer(
                    padding: const EdgeInsets.all(28.0),
                    borderRadius: 24,
                    borderColor: Colors.white.withOpacity(0.12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Acessar Sistema',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        CustomTextField(
                          key: const Key('login-email-field'),
                          label: 'E-mail',
                          controller: _emailController,
                          icon: Icons.email_outlined,
                          validator: validateEmail,
                          isGlass: true,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          key: const Key('login-password-field'),
                          label: 'Senha',
                          controller: _passwordController,
                          icon: Icons.lock_outline,
                          isPassword: true,
                          validator: (v) => validateMinLength(v, 6),
                          isGlass: true,
                        ),
                        const SizedBox(height: 28),
                        
                        // Premium Glowing Yellow/Amber Elevated button
                        ElevatedButton(
                          key: const Key('login-btn'),
                          onPressed: controller.isLoading
                              ? null
                              : () async {
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFBBF24), // Vibrant Amber Accent
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            minimumSize: const Size(double.infinity, 50),
                            elevation: 8,
                            shadowColor: const Color(0xFFFBBF24).withOpacity(0.3),
                          ),
                          child: controller.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                  ),
                                )
                              : const Text('Entrar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Secondary link
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.register);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF00E5FF), // Cyan Accent
                    ),
                    child: const Text('Ainda não tem conta? Criar conta'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
