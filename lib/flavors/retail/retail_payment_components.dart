import 'package:flutter/material.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_tenant_components.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/view_data/payment_supplement_view_data.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/view_data/security_error_view_data.dart';
import 'package:retail_test_task/flavors/retail/retail_promo_banner.dart';
import 'package:retail_test_task/flavors/retail/retail_security_error.dart';

final class RetailPromoBannerStrategy implements PaymentSupplementStrategy {
  const RetailPromoBannerStrategy();

  @override
  Widget build(BuildContext context, PaymentSupplementViewData data) {
    return const RetailPromoBanner();
  }
}

final class RetailSecurityErrorStrategy implements SecurityErrorStrategy {
  const RetailSecurityErrorStrategy();

  @override
  Widget build(BuildContext context, SecurityErrorViewData data) {
    return RetailSecurityError(data: data);
  }
}
