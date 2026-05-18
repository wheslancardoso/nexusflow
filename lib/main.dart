import 'package:flutter/material.dart';
import 'app/app_widget.dart';
import 'app/core/di/dependency_injection.dart';
import 'app/core/services/sync_system_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Dependency Injection
  await initDependencyInjection();
  
  // 2. Initialize Background Sync & System Logs
  await SyncSystemInitializer.initialize();
  
  runApp(const AppEntry());
}

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return AppWidget();
  }
}
