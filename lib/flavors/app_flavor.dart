import 'package:flutter/foundation.dart';
import 'package:retail_test_task/core/tenant/tenant_config.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_tenant_components.dart';

@immutable
final class AppFlavor {
  const AppFlavor({required this.tenant, required this.paymentComponents});

  final TenantConfig tenant;
  final PaymentTenantComponents paymentComponents;
}
