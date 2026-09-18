import 'package:retail_test_task/features/payment/domain/entities/confirmation_decision.dart';
import 'package:retail_test_task/features/payment/domain/entities/security_status.dart';

final class EvaluateConfirmation {
  const EvaluateConfirmation();

  ConfirmationDecision call(SecurityStatus status) {
    final blockingThreats = <SecurityThreat>[
      if (status.root == SecuritySignalState.detected)
        SecurityThreat.rootedDevice,
      if (status.screenRecording == SecuritySignalState.detected)
        SecurityThreat.screenRecording,
    ];

    if (blockingThreats.isEmpty) {
      return const ConfirmationDecision.allowed();
    }

    return ConfirmationDecision.blocked(blockingThreats);
  }
}
