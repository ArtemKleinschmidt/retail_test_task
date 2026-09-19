import 'package:flutter/foundation.dart';

enum PaymentDebugLoadBehavior { success, failure }

enum PaymentDebugSecurityBehavior {
  clear,
  unsupported,
  rooted,
  screenRecording,
  rootedAndRecording,
  failure,
}

enum PaymentDebugProcessingBehavior {
  success,
  declined,
  startFailure,
  streamFailure,
}

@immutable
final class PaymentDebugScenario {
  const PaymentDebugScenario({
    this.loadBehavior = PaymentDebugLoadBehavior.success,
    this.securityBehavior = PaymentDebugSecurityBehavior.clear,
    this.processingBehavior = PaymentDebugProcessingBehavior.success,
  });

  final PaymentDebugLoadBehavior loadBehavior;
  final PaymentDebugSecurityBehavior securityBehavior;
  final PaymentDebugProcessingBehavior processingBehavior;
}
