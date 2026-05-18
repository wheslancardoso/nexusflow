import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../../core/base/base.controller.dart';
import '../../../../core/mixins/validator_mixin.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../cliente.model.dart';
import '../../data/cliente.repository.dart';
import '../../domain/cliente.validation.dart';
import '../../domain/cliente.service.dart';

// ignore: must_be_immutable
class ClienteFormPage extends BaseController<Cliente, ClienteRepository, ClienteValidation, ClienteService> {
  ClienteFormPage({Key? key, required ClienteService service, Cliente? model})
      : super(service, model: model, key: key);

  @override
  Widget buildPage(BuildContext context, ClienteService service) {
    return _ClienteFormView(controller: this);
  }
}

class _ClienteFormView extends StatefulWidget {
  final ClienteFormPage controller;

  const _ClienteFormView({required this.controller});

  @override
  State<_ClienteFormView> createState() => _ClienteFormViewState();
}

class _ClienteFormViewState extends State<_ClienteFormView> with ValidatorMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _emailController;
  late final TextEditingController _telefoneController;
  late final TextEditingController _documentoController;
  late final TextEditingController _enderecoController;
  late final TextEditingController _cidadeController;
  late final TextEditingController _estadoController;
  late final TextEditingController _cepController;

  final _documentoMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  final _telefoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void initState() {
    super.initState();
    final model = widget.controller.model;
    _nomeController = TextEditingController(text: model?.nome);
    _emailController = TextEditingController(text: model?.email);
    _telefoneController = TextEditingController(text: model?.telefone);
    _documentoController = TextEditingController(text: model?.documento);
    _enderecoController = TextEditingController(text: model?.endereco);
    _cidadeController = TextEditingController(text: model?.cidade);
    _estadoController = TextEditingController(text: model?.estado);
    _cepController = TextEditingController(text: model?.cep);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _documentoController.dispose();
    _enderecoController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _cepController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_formKey.currentState?.validate() ?? false) {
      final cliente = Cliente(
        id: widget.controller.model?.id,
        nome: _nomeController.text,
        email: _emailController.text,
        telefone: _telefoneController.text,
        documento: _documentoController.text,
        endereco: _enderecoController.text,
        cidade: _cidadeController.text,
        estado: _estadoController.text,
        cep: _cepController.text,
        isSync: 0,
        createdAt: widget.controller.model?.createdAt,
      );

      final isEditing = widget.controller.model != null;

      final success = await widget.controller.executeCrudOperation(
        context,
        isEditing
            ? widget.controller.service.update(cliente)
            : widget.controller.service.create(cliente),
        loadingMessage: 'Salvando cliente...',
        successMessage: isEditing ? 'Cliente atualizado com sucesso!' : 'Cliente cadastrado com sucesso!',
        errorMessage: 'Falha ao salvar cliente.',
      );

      if (success && mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.controller.model != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Cliente' : 'Novo Cliente'),
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
                  controller: _documentoController,
                  icon: Icons.badge,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_documentoMask],
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
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Endereço',
                  controller: _enderecoController,
                  icon: Icons.home,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        label: 'Cidade',
                        controller: _cidadeController,
                        icon: Icons.location_city,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: CustomTextField(
                        label: 'UF',
                        controller: _estadoController,
                        icon: Icons.map,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'CEP',
                  controller: _cepController,
                  icon: Icons.pin_drop,
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Salvar',
                  onPressed: _salvar,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
