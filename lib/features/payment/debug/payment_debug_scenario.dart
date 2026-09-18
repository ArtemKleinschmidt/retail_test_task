import 'package:flutter/foundation.dart';
import 'package:retail_test_task/features/payment/data/repositories/simulated_payment_repository.dart';
import 'package:retail_test_task/features/payment/data/repositories/simulated_security_repository.dart';

@immutable
final class PaymentDebugScenario {
  const PaymentDebugScenario({
    this.loadBehavior = SimulatedPaymentLoadBehavior.success,
    this.securityBehavior = SimulatedSecurityBehavior.clear,
    this.processingBehavior = SimulatedPaymentProcessingBehavior.success,
  });

  final SimulatedPaymentLoadBehavior loadBehavior;
  final SimulatedSecurityBehavior securityBehavior;
  final SimulatedPaymentProcessingBehavior processingBehavior;
}
