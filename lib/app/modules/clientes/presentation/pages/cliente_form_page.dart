import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../../core/mixins/messages_mixin.dart';
import '../../../../core/mixins/loader_mixin.dart';
import '../../../../core/mixins/validator_mixin.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../core/services/in_memory_store.dart';
import '../../cliente.model.dart';

class ClienteFormPage extends StatefulWidget {
  const ClienteFormPage({Key? key}) : super(key: key);

  @override
  State<ClienteFormPage> createState() => _ClienteFormPageState();
}

class _ClienteFormPageState extends State<ClienteFormPage> with MessagesMixin, ValidatorMixin, LoaderMixin {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfCnpjController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();

  final _cpfCnpjMask = MaskTextInputFormatter(
      mask: '###.###.###-##', 
      filter: { "#": RegExp(r'[0-9]') },
      type: MaskAutoCompletionType.lazy,
  );

  final _telefoneMask = MaskTextInputFormatter(
      mask: '(##) #####-####', 
      filter: { "#": RegExp(r'[0-9]') },
      type: MaskAutoCompletionType.lazy,
  );

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfCnpjController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  Future<void> _salvarCliente() async {
    if (_formKey.currentState?.validate() ?? false) {
      showLoader();
      
      final cliente = Cliente(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nome: _nomeController.text,
        email: _emailController.text,
        telefone: _telefoneController.text,
        cpfCnpj: _cpfCnpjController.text,
      );

      // Save to store
      InMemoryStore().addCliente(cliente);

      await Future.delayed(const Duration(seconds: 1));
      hideLoader();
      if (mounted) {
        showSuccess(context, 'Cliente cadastrado com sucesso!');
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Cliente'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  label: 'Nome / Razão Social',
                  controller: _nomeController,
                  icon: Icons.person,
                  validator: (v) => validateMinLength(v, 3),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'CPF/CNPJ',
                  controller: _cpfCnpjController,
                  icon: Icons.badge,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_cpfCnpjMask],
                  validator: (v) => validateMinLength(v, 14),
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
                  label: 'Telefone',
                  controller: _telefoneController,
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_telefoneMask],
                  validator: (v) => validateMinLength(v, 14),
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Salvar',
                  onPressed: _salvarCliente,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
