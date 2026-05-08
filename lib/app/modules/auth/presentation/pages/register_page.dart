import 'package:flutter/material.dart';
import '../../../../core/mixins/messages_mixin.dart';
import '../../../../core/mixins/validator_mixin.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/app_logo.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with MessagesMixin, ValidatorMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  void _executarRegistro() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        showError(context, 'As senhas não coincidem.');
        return;
      }
      
      setState(() {
        _isLoading = true;
      });
      
      // Simula uma chamada de API
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        showSuccess(context, 'Conta criada com sucesso!');
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppLogo(),
                const SizedBox(height: 32),
                Text(
                  'Crie sua identidade',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Nome Completo',
                  controller: _nameController,
                  icon: Icons.person,
                  validator: (v) => validateMinLength(v, 3),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'E-mail',
                  controller: _emailController,
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
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
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Confirmação de Senha',
                  controller: _confirmPasswordController,
                  icon: Icons.lock,
                  isPassword: true,
                  validator: (v) => validateMinLength(v, 6),
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Registrar',
                  isLoading: _isLoading,
                  onPressed: _executarRegistro,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Já tenho conta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
