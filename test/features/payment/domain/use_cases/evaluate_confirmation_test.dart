import 'package:flutter_test/flutter_test.dart';
import 'package:retail_test_task/features/payment/domain/entities/security_status.dart';
import 'package:retail_test_task/features/payment/domain/use_cases/evaluate_confirmation.dart';

void main() {
  const evaluateConfirmation = EvaluateConfirmation();

  test('allows confirmation when both signals are clear', () {
    const status = SecurityStatus(
      root: SecuritySignalState.clear,
      screenRecording: SecuritySignalState.clear,
    );

    final decision = evaluateConfirmation(status);

    expect(decision.isAllowed, isTrue);
    expect(decision.blockingThreats, isEmpty);
  });

  test('allows confirmation when detection is unsupported', () {
    const status = SecurityStatus(
      root: SecuritySignalState.unsupported,
      screenRecording: SecuritySignalState.unsupported,
    );

    expect(evaluateConfirmation(status).isAllowed, isTrue);
  });

  test('blocks confirmation on root detection', () {
    const status = SecurityStatus(
      root: SecuritySignalState.detected,
      screenRecording: SecuritySignalState.clear,
    );

    expect(evaluateConfirmation(status).blockingThreats, [
      SecurityThreat.rootedDevice,
    ]);
  });

  test('blocks confirmation on active screen recording', () {
    const status = SecurityStatus(
      root: SecuritySignalState.clear,
      screenRecording: SecuritySignalState.detected,
    );

    expect(evaluateConfirmation(status).blockingThreats, [
      SecurityThreat.screenRecording,
    ]);
  });

  test('reports both detected threats', () {
    const status = SecurityStatus(
      root: SecuritySignalState.detected,
      screenRecording: SecuritySignalState.detected,
    );

    expect(evaluateConfirmation(status).blockingThreats, [
      SecurityThreat.rootedDevice,
      SecurityThreat.screenRecording,
    ]);
  });
}
