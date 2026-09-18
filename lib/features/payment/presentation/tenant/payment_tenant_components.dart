import 'package:flutter/material.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/view_data/payment_supplement_view_data.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/view_data/security_error_view_data.dart';

abstract interface class PaymentSupplementStrategy {
  Widget build(BuildContext context, PaymentSupplementViewData data);
}

abstract interface class SecurityErrorStrategy {
  Widget build(BuildContext context, SecurityErrorViewData data);
}

@immutable
final class PaymentTenantComponents {
  const PaymentTenantComponents({
    required this.paymentSupplement,
    required this.securityError,
  });

  final PaymentSupplementStrategy paymentSupplement;
  final SecurityErrorStrategy securityError;
}
