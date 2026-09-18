import 'package:flutter_test/flutter_test.dart';
import 'package:retail_test_task/features/payment/data/repositories/simulated_payment_repository.dart';
import 'package:retail_test_task/features/payment/data/repositories/simulated_security_repository.dart';
import 'package:retail_test_task/features/payment/data/sources/predefined_payment.dart';
import 'package:retail_test_task/features/payment/domain/entities/payment_processing_update.dart';
import 'package:retail_test_task/features/payment/domain/entities/security_status.dart';
import 'package:retail_test_task/features/payment/domain/failures/payment_failure.dart';
import 'package:retail_test_task/features/payment/domain/failures/security_failure.dart';

void main() {
  group('SimulatedPaymentRepository loading', () {
    test('returns the predefined payment', () async {
      final payment = createPredefinedPayment();
      final repository = SimulatedPaymentRepository(
        payment: payment,
        loadDelay: Duration.zero,
      );

      await expectLater(repository.loadPayment(), completion(payment));
    });

    test('throws a typed load failure', () async {
      final repository = SimulatedPaymentRepository(
        payment: createPredefinedPayment(),
        loadBehavior: SimulatedPaymentLoadBehavior.failure,
        loadDelay: Duration.zero,
      );

      await expectLater(
        repository.loadPayment(),
        throwsA(isA<PaymentLoadFailure>()),
      );
    });
  });

  group('SimulatedSecurityRepository', () {
    const expectedStatuses = {
      SimulatedSecurityBehavior.clear: SecurityStatus(
        root: SecuritySignalState.clear,
        screenRecording: SecuritySignalState.clear,
      ),
      SimulatedSecurityBehavior.unsupported: SecurityStatus(
        root: SecuritySignalState.unsupported,
        screenRecording: SecuritySignalState.unsupported,
      ),
      SimulatedSecurityBehavior.rooted: SecurityStatus(
        root: SecuritySignalState.detected,
        screenRecording: SecuritySignalState.clear,
      ),
      SimulatedSecurityBehavior.screenRecording: SecurityStatus(
        root: SecuritySignalState.clear,
        screenRecording: SecuritySignalState.detected,
      ),
      SimulatedSecurityBehavior.rootedAndRecording: SecurityStatus(
        root: SecuritySignalState.detected,
        screenRecording: SecuritySignalState.detected,
      ),
    };

    for (final entry in expectedStatuses.entries) {
      test('maps ${entry.key.name} to its security status', () async {
        final repository = SimulatedSecurityRepository(
          behavior: entry.key,
          checkDelay: Duration.zero,
        );

        await expectLater(repository.checkStatus(), completion(entry.value));
      });
    }

    test('throws a typed security-check failure', () async {
      const repository = SimulatedSecurityRepository(
        behavior: SimulatedSecurityBehavior.failure,
        checkDelay: Duration.zero,
      );

      await expectLater(
        repository.checkStatus(),
        throwsA(isA<SecurityCheckFailure>()),
      );
    });
  });

  group('SimulatedPaymentRepository processing', () {
    test('emits ordered progress and a successful result', () async {
      final payment = createPredefinedPayment();
      final repository = SimulatedPaymentRepository(
        payment: payment,
        progressInterval: Duration.zero,
      );
      final stream = repository.observeProcessing(payment.reference);
      final expectation = expectLater(
        stream,
        emitsInOrder([
          PaymentProgress(reference: payment.reference, percentage: 20),
          PaymentProgress(reference: payment.reference, percentage: 45),
          PaymentProgress(reference: payment.reference, percentage: 70),
          PaymentProgress(reference: payment.reference, percentage: 100),
          PaymentResult(
            reference: payment.reference,
            outcome: PaymentOutcome.success,
          ),
          emitsDone,
        ]),
      );

      await repository.startProcessing(payment.reference);

      await expectation;
    });

    test('emits a declined business outcome', () async {
      final payment = createPredefinedPayment();
      final repository = SimulatedPaymentRepository(
        payment: payment,
        processingBehavior: SimulatedPaymentProcessingBehavior.declined,
        progressInterval: Duration.zero,
      );
      final stream = repository.observeProcessing(payment.reference);
      final expectation = expectLater(
        stream,
        emitsInOrder([
          isA<PaymentProgress>(),
          isA<PaymentProgress>(),
          isA<PaymentProgress>(),
          isA<PaymentProgress>(),
          PaymentResult(
            reference: payment.reference,
            outcome: PaymentOutcome.failure,
          ),
          emitsDone,
        ]),
      );

      await repository.startProcessing(payment.reference);

      await expectation;
    });

    test('throws a typed start failure', () async {
      final payment = createPredefinedPayment();
      final repository = SimulatedPaymentRepository(
        payment: payment,
        processingBehavior: SimulatedPaymentProcessingBehavior.startFailure,
        progressInterval: Duration.zero,
      );
      repository.observeProcessing(payment.reference);

      await expectLater(
        repository.startProcessing(payment.reference),
        throwsA(isA<PaymentStartFailure>()),
      );
    });

    test('emits a typed progress-stream failure', () async {
      final payment = createPredefinedPayment();
      final repository = SimulatedPaymentRepository(
        payment: payment,
        processingBehavior: SimulatedPaymentProcessingBehavior.streamFailure,
        progressInterval: Duration.zero,
      );
      final stream = repository.observeProcessing(payment.reference);
      final expectation = expectLater(
        stream,
        emitsInOrder([
          PaymentProgress(reference: payment.reference, percentage: 20),
          PaymentProgress(reference: payment.reference, percentage: 45),
          emitsError(isA<PaymentProcessingFailure>()),
          emitsDone,
        ]),
      );

      await repository.startProcessing(payment.reference);

      await expectation;
    });
  });
}
