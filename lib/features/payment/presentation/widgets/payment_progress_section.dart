import 'package:flutter/material.dart';
import 'package:retail_test_task/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_page_section.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_page_section_key.dart';

class PaymentProgressSection extends PaymentPageSection {
  const PaymentProgressSection({super.key});

  static const sectionKey = PaymentPageSectionKey.processingProgress;

  @override
  bool isVisible(PaymentContentState state) => false;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
