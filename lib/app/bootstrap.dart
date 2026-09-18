import 'package:flutter/widgets.dart';
import 'package:retail_test_task/app/app.dart';
import 'package:retail_test_task/app/dependency_injection.dart';

void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();
  registerDependencies(serviceLocator);
  runApp(const PaymentPortalApp());
}
