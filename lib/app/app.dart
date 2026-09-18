import 'package:flutter/material.dart';
import 'package:retail_test_task/core/tenant/tenant_config.dart';
import 'package:retail_test_task/core/tenant/tenant_scope.dart';
import 'package:retail_test_task/features/payment/debug/payment_debug_bloc_factory.dart';
import 'package:retail_test_task/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:retail_test_task/features/payment/presentation/pages/payment_page.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_tenant_components.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_tenant_components_scope.dart';

class PaymentPortalApp extends StatelessWidget {
  const PaymentPortalApp({
    required this.tenant,
    required this.paymentComponents,
    required this.createPaymentBloc,
    super.key,
  });

  final TenantConfig tenant;
  final PaymentTenantComponents paymentComponents;
  final PaymentBloc Function() createPaymentBloc;

  @override
  Widget build(BuildContext context) {
    return TenantScope(
      config: tenant,
      child: PaymentTenantComponentsScope(
        components: paymentComponents,
        child: MaterialApp(
          title: tenant.appName,
          debugShowCheckedModeBanner: false,
          theme: tenant.theme,
          home: PaymentFlow(
            createBloc: createPaymentBloc,
            createDebugBloc: createDebugPaymentBloc,
          ),
        ),
      ),
    );
  }
}
