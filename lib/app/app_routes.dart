import 'package:flutter/material.dart';

import 'modules/splash/presentation/pages/splash_page.dart';
import 'modules/auth/presentation/pages/login_page.dart';
import 'modules/auth/presentation/pages/register_page.dart';
import 'modules/dashboard/presentation/pages/dashboard_page.dart';
import 'modules/service_order/presentation/pages/service_order_list_page.dart';
import 'modules/service_order/presentation/pages/service_order_form_page.dart';
import 'modules/clientes/presentation/pages/cliente_form_page.dart';

class AppRoutes {
  static const splash = '/splash';
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const dashboard = '/dashboard';
  static const serviceOrder = '/service_order';
  static const serviceOrderForm = '/service_order/form';
  static const clienteForm = '/clientes/form';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashPage(maxSeconds: 7),
        login: (_) => const LoginPage(),
        register: (_) => const RegisterPage(),
        dashboard: (_) => const DashboardPage(),
        serviceOrder: (_) => const ServiceOrderListPage(),
        serviceOrderForm: (_) => const ServiceOrderFormPage(),
        clienteForm: (_) => const ClienteFormPage(),
      };
}
