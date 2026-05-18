import 'package:flutter/material.dart';
import '../../../../core/mixins/messages_mixin.dart';
import '../../../../core/mixins/validator_mixin.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/liquid_background.dart';
import '../../../../shared/widgets/glass_container.dart';

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Criar Conta',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: LiquidBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AppLogo(),
                    const SizedBox(height: 16),
                    const Text(
                      'Nova Conta',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Crie sua conta técnica para sincronizar e gerenciar ordens.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 28),
                    
                    // Breathtaking Glass Container for Register Form
                    GlassContainer(
                      padding: const EdgeInsets.all(24.0),
                      borderRadius: 24,
                      borderColor: Colors.white.withOpacity(0.12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomTextField(
                            label: 'Nome Completo',
                            controller: _nameController,
                            icon: Icons.person_outline,
                            validator: (v) => validateMinLength(v, 3),
                            isGlass: true,
                          ),
                          const SizedBox(height: 14),
                          CustomTextField(
                            label: 'E-mail',
                            controller: _emailController,
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: validateEmail,
                            isGlass: true,
                          ),
                          const SizedBox(height: 14),
                          CustomTextField(
                            label: 'Senha',
                            controller: _passwordController,
                            icon: Icons.lock_outline,
                            isPassword: true,
                            validator: (v) => validateMinLength(v, 6),
                            isGlass: true,
                          ),
                          const SizedBox(height: 14),
                          CustomTextField(
                            label: 'Confirmação de Senha',
                            controller: _confirmPasswordController,
                            icon: Icons.lock_outline,
                            isPassword: true,
                            validator: (v) => validateMinLength(v, 6),
                            isGlass: true,
                          ),
                          const SizedBox(height: 24),
                          
                          // Glowing Amber Register Button
                          ElevatedButton(
                            onPressed: _isLoading ? null : _executarRegistro,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFBBF24), // Vibrant Amber Accent
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              minimumSize: const Size(double.infinity, 50),
                              elevation: 8,
                              shadowColor: const Color(0xFFFBBF24).withOpacity(0.3),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                    ),
                                  )
                                : const Text('Registrar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Return Link
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF00E5FF), // Cyan Accent
                      ),
                      child: const Text('Já tenho conta? Acessar login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
