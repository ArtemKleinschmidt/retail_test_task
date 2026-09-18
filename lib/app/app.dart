import 'package:flutter/material.dart';
import 'package:retail_test_task/core/tenant/tenant_config.dart';
import 'package:retail_test_task/core/tenant/tenant_scope.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_tenant_components.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_tenant_components_scope.dart';

class PaymentPortalApp extends StatelessWidget {
  const PaymentPortalApp({
    required this.tenant,
    required this.paymentComponents,
    super.key,
  });

  final TenantConfig tenant;
  final PaymentTenantComponents paymentComponents;

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
          home: _TenantLandingPage(appName: tenant.appName),
        ),
      ),
    );
  }
}

class _TenantLandingPage extends StatelessWidget {
  const _TenantLandingPage({required this.appName});

  final String appName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            appName,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
    );
  }
}
