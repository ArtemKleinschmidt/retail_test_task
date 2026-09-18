import 'package:flutter/foundation.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_page_section_key.dart';

@immutable
final class PaymentTenantComponents {
  PaymentTenantComponents({
    required Iterable<PaymentPageSectionKey> sectionKeys,
  }) : sectionKeys = List.unmodifiable(sectionKeys);

  final List<PaymentPageSectionKey> sectionKeys;
}
