import 'package:retail_test_task/features/payment/domain/entities/security_status.dart';
import 'package:retail_test_task/features/payment/domain/failures/security_failure.dart';
import 'package:retail_test_task/features/payment/domain/repositories/security_repository.dart';

enum SimulatedSecurityBehavior {
  clear,
  unsupported,
  rooted,
  screenRecording,
  rootedAndRecording,
  failure,
}

final class SimulatedSecurityRepository implements SecurityRepository {
  const SimulatedSecurityRepository({
    this.behavior = SimulatedSecurityBehavior.clear,
    this.checkDelay = const Duration(milliseconds: 650),
  });

  final SimulatedSecurityBehavior behavior;
  final Duration checkDelay;

  @override
  Future<SecurityStatus> checkStatus() async {
    await Future<void>.delayed(checkDelay);

    return switch (behavior) {
      SimulatedSecurityBehavior.clear => const SecurityStatus(
        root: SecuritySignalState.clear,
        screenRecording: SecuritySignalState.clear,
      ),
      SimulatedSecurityBehavior.unsupported => const SecurityStatus(
        root: SecuritySignalState.unsupported,
        screenRecording: SecuritySignalState.unsupported,
      ),
      SimulatedSecurityBehavior.rooted => const SecurityStatus(
        root: SecuritySignalState.detected,
        screenRecording: SecuritySignalState.clear,
      ),
      SimulatedSecurityBehavior.screenRecording => const SecurityStatus(
        root: SecuritySignalState.clear,
        screenRecording: SecuritySignalState.detected,
      ),
      SimulatedSecurityBehavior.rootedAndRecording => const SecurityStatus(
        root: SecuritySignalState.detected,
        screenRecording: SecuritySignalState.detected,
      ),
      SimulatedSecurityBehavior.failure => throw const SecurityCheckFailure(
        'The device security status could not be checked.',
      ),
    };
  }
}
