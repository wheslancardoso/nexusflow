import 'package:flutter/material.dart';
import '../mixins/loader_mixin.dart';
import '../mixins/messages_mixin.dart';
import 'base.model.dart';
import 'base.repository.dart';
import 'base.service.dart';
import 'base.validation.dart';

// ignore: must_be_immutable
abstract class BaseController<E extends BaseModel, R extends BaseRepository<E>,
        V extends BaseValidation<E, R>, S extends BaseService<E, R, V>>
    extends StatelessWidget with LoaderMixin, MessagesMixin {

  final S service;
  final E? model;

  BaseController(this.service, {this.model, super.key});

  Widget buildPage(BuildContext context, S service);

  @override
  Widget build(BuildContext context) {
    return buildPage(context, service);
  }

  // 📋 OPERAÇÃO GENÉRICA
  Future<T?> executeOperation<T>(
    BuildContext context,
    Future<T> operation, {
    String? loadingMessage,
    String? successMessage,
    String? errorMessage,
    bool showSuccessMessage = false,
  }) async {
    try {
      showLoading(context, message: loadingMessage);

      final result = await operation;

      hideLoading(context);

      if (showSuccessMessage && successMessage != null) {
        showSuccess(context, successMessage);
      }

      return result;

    } catch (e) {
      hideLoading(context);
      _handleException(context, e, errorMessage);
      return null;
    }
  }

  // 📋 OPERAÇÃO DE LISTA
  Future<List<T>> executeListOperation<T>(
    BuildContext context,
    Future<List<T>> operation, {
    String? loadingMessage,
    String? errorMessage,
  }) async {
    try {
      showLoading(context, message: loadingMessage);

      final result = await operation;

      hideLoading(context);

      return result;

    } catch (e) {
      hideLoading(context);
      _handleException(context, e, errorMessage);
      return [];
    }
  }

  // 📋 OPERAÇÃO CRUD COM CONFIRMAÇÃO
  Future<bool> executeCrudOperation(
    BuildContext context,
    Future operation, {
    String? confirmTitle,
    String? confirmMessage,
    String? loadingMessage,
    String? successMessage,
    String? errorMessage,
    bool requiresConfirmation = false,
  }) async {
    try {
      if (requiresConfirmation) {
        final confirmed = await showConfirmation(
          context,
          title: confirmTitle ?? 'Confirmar',
          message: confirmMessage ?? 'Tem certeza?',
        );

        if (confirmed != true) return false;
      }

      showLoading(context, message: loadingMessage);

      await operation;

      hideLoading(context);

      if (successMessage != null) {
        showSuccess(context, successMessage);
      }

      return true;

    } catch (e) {
      hideLoading(context);
      _handleException(context, e, errorMessage);
      return false;
    }
  }

  // 🛡️ TRATAMENTO CENTRALIZADO DE EXCEÇÕES
  void _handleException(BuildContext context, dynamic exception, String? errorMessage) {
    String userMessage;

    if (exception.toString().contains('FOREIGN KEY') ||
        exception.toString().contains('UNIQUE constraint')) {
      userMessage = 'Erro de integridade de dados. Verifique as informações.';
    } else if (exception.toString().contains('SocketException') ||
               exception.toString().contains('TimeoutException')) {
      userMessage = 'Erro de conexão. Verifique sua internet.';
    } else if (exception.runtimeType.toString().contains('Validation')) {
      userMessage = exception.toString();
    } else {
      userMessage = errorMessage ?? 'Erro inesperado. Tente novamente.';
    }

    showError(context, userMessage);

    // Log técnico para debug
    debugPrint('🔴 EXCEPTION: $exception');
  }
}
