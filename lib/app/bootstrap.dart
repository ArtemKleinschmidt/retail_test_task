import 'package:flutter/widgets.dart';
import 'package:retail_test_task/app/app.dart';
import 'package:retail_test_task/app/dependency_injection.dart';
import 'package:retail_test_task/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:retail_test_task/flavors/app_flavor.dart';

void bootstrap(AppFlavor flavor) {
  WidgetsFlutterBinding.ensureInitialized();
  registerDependencies(serviceLocator);
  runApp(
    PaymentPortalApp(
      tenant: flavor.tenant,
      paymentComponents: flavor.paymentComponents,
      createPaymentBloc: () => serviceLocator<PaymentBloc>(),
    ),
  );
}
