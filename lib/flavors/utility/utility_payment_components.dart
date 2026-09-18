import 'package:flutter/material.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_tenant_components.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/view_data/payment_supplement_view_data.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/view_data/security_error_view_data.dart';
import 'package:retail_test_task/flavors/utility/utility_bill_breakdown.dart';
import 'package:retail_test_task/flavors/utility/utility_security_error.dart';

final class UtilityBillBreakdownStrategy implements PaymentSupplementStrategy {
  const UtilityBillBreakdownStrategy();

  @override
  Widget build(BuildContext context, PaymentSupplementViewData data) {
    return UtilityBillBreakdown(data: data);
  }
}

final class UtilitySecurityErrorStrategy implements SecurityErrorStrategy {
  const UtilitySecurityErrorStrategy();

  @override
  Widget build(BuildContext context, SecurityErrorViewData data) {
    return UtilitySecurityError(data: data);
  }
}
