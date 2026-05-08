mixin ValidatorMixin {
  String? validateRequired(String? value, [String? message]) {
    if (value == null || value.trim().isEmpty) {
      return message ?? 'Este campo é obrigatório';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Este campo é obrigatório';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'E-mail inválido';
    }
    return null;
  }

  String? validateMinLength(String? value, int min, [String? message]) {
    if (value == null || value.length < min) {
      return message ?? 'Mínimo de $min caracteres';
    }
    return null;
  }
}
