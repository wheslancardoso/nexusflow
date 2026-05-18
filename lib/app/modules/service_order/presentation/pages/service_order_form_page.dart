import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/in_memory_store.dart';
import '../../controllers/service_order_controller.dart';
import '../../../dashboard/controllers/dashboard_controller.dart';
import '../../models/service_order.model.dart';
import '../../../../core/mixins/messages_mixin.dart';
import '../../../../core/mixins/loader_mixin.dart';
import '../../../../core/mixins/validator_mixin.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';

class ServiceOrderFormPage extends StatefulWidget {
  const ServiceOrderFormPage({Key? key}) : super(key: key);

  @override
  State<ServiceOrderFormPage> createState() => _ServiceOrderFormPageState();
}

class _ServiceOrderFormPageState extends State<ServiceOrderFormPage> with MessagesMixin, ValidatorMixin, LoaderMixin {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedCliente;
  List<String> _clientes = [];

  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();

  File? _fotoAntes;
  File? _fotoDepois;
  
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Load clients from store
    _clientes = InMemoryStore().clientes.map((c) => c.nome).toList();
  }

  Future<void> _pickImage(bool isAntes) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        if (isAntes) {
          _fotoAntes = File(pickedFile.path);
        } else {
          _fotoDepois = File(pickedFile.path);
        }
      });
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _salvarOrdemSerivco() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCliente == null) {
        showError(context, 'Selecione um cliente.');
        return;
      }
      if (_signatureController.isEmpty) {
        showError(context, 'A assinatura é obrigatória.');
        return;
      }

      showLoader(context);
      
      // Simulate processing time 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      
      final signatureBytes = await _signatureController.toPngBytes();
      final signatureBase64 = signatureBytes != null ? base64Encode(signatureBytes) : null;

      final order = ServiceOrder(
        id: DateTime.now().millisecondsSinceEpoch,
        cliente: _selectedCliente!,
        descricao: _descricaoController.text,
        valor: double.tryParse(_valorController.text) ?? 0.0,
        status: 'Em aberto',
        fotoPath: _fotoDepois?.path,
        fotoAntesPath: _fotoAntes?.path,
        assinatura: signatureBase64,
      );

      final controller = context.read<ServiceOrderController>();
      final success = await controller.saveOrder(order);
      
      hideLoader();
      
      if (success && mounted) {
        context.read<DashboardController>().refresh();
        showSuccess(context, 'O.S. salva com sucesso!');
        Navigator.pop(context);
      } else if (!success && mounted) {
        showError(context, 'Erro ao salvar a O.S.');
      }
    }
  }

  Widget _buildPhotoBox(String title, File? image, bool isAntes) {
    return GestureDetector(
      onTap: () => _pickImage(isAntes),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(image, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt, size: 30, color: Colors.grey),
                  const SizedBox(height: 4),
                  Text(title, style: const TextStyle(fontSize: 12)),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova O.S.')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedCliente,
                  decoration: InputDecoration(
                    labelText: 'Cliente',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _clientes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCliente = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Por favor, selecione um cliente' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Descrição',
                  controller: _descricaoController,
                  icon: Icons.description,
                  validator: validateRequired,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Valor (R\$)',
                  controller: _valorController,
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: validateRequired,
                ),
                const SizedBox(height: 24),
                const Text('Evidências Fotográficas', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildPhotoBox('Foto Antes', _fotoAntes, true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildPhotoBox('Foto Depois', _fotoDepois, false)),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Assinatura Digital', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Signature(
                    controller: _signatureController,
                    height: 150,
                    backgroundColor: Colors.white,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _signatureController.clear(),
                      child: const Text('Limpar Assinatura'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Salvar Ordem de Serviço',
                  onPressed: _salvarOrdemSerivco,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
