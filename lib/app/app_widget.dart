import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/di/dependency_injection.dart';
import 'modules/auth/controllers/login_controller.dart';
import 'modules/service_order/controllers/service_order_controller.dart';
import 'modules/dashboard/controllers/dashboard_controller.dart';

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<LoginController>()),
        ChangeNotifierProvider(create: (_) => getIt<ServiceOrderController>()),
        ChangeNotifierProvider(create: (_) => getIt<DashboardController>()),
      ],
      child: MaterialApp(
        title: 'NexusFlow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}
