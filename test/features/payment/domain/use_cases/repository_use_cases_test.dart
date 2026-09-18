import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retail_test_task/features/payment/domain/entities/money.dart';
import 'package:retail_test_task/features/payment/domain/entities/payment.dart';
import 'package:retail_test_task/features/payment/domain/entities/payment_processing_update.dart';
import 'package:retail_test_task/features/payment/domain/entities/payment_reference.dart';
import 'package:retail_test_task/features/payment/domain/entities/security_status.dart';
import 'package:retail_test_task/features/payment/domain/failures/payment_failure.dart';
import 'package:retail_test_task/features/payment/domain/failures/security_failure.dart';
import 'package:retail_test_task/features/payment/domain/repositories/payment_repository.dart';
import 'package:retail_test_task/features/payment/domain/repositories/security_repository.dart';
import 'package:retail_test_task/features/payment/domain/use_cases/check_security_status.dart';
import 'package:retail_test_task/features/payment/domain/use_cases/load_payment.dart';
import 'package:retail_test_task/features/payment/domain/use_cases/observe_payment_processing.dart';
import 'package:retail_test_task/features/payment/domain/use_cases/start_payment_processing.dart';

final class MockPaymentRepository extends Mock implements PaymentRepository {}

final class MockSecurityRepository extends Mock implements SecurityRepository {}

void main() {
  late MockPaymentRepository paymentRepository;
  late MockSecurityRepository securityRepository;
  late PaymentReference reference;
  late Payment payment;

  setUp(() {
    paymentRepository = MockPaymentRepository();
    securityRepository = MockSecurityRepository();
    reference = PaymentReference('INV-001');
    payment = Payment(
      reference: reference,
      payeeName: 'City Utilities',
      total: Money(amountInMinorUnits: 2500, currencyCode: 'USD'),
    );
  });

  group('LoadPayment', () {
    test('returns the payment supplied by the repository', () async {
      when(paymentRepository.loadPayment).thenAnswer((_) async => payment);

      final result = await LoadPayment(paymentRepository)();

      expect(result, same(payment));
      verify(paymentRepository.loadPayment).called(1);
    });

    test('propagates a typed loading failure unchanged', () async {
      const failure = PaymentLoadFailure('Unable to load payment.');
      when(paymentRepository.loadPayment)
          .thenAnswer((_) async => throw failure);

      await expectLater(
        LoadPayment(paymentRepository)(),
        throwsA(same(failure)),
      );
    });
  });

  group('CheckSecurityStatus', () {
    test('returns the status supplied by the repository', () async {
      const status = SecurityStatus(
        root: SecuritySignalState.clear,
        screenRecording: SecuritySignalState.unsupported,
      );
      when(securityRepository.checkStatus).thenAnswer((_) async => status);

      final result = await CheckSecurityStatus(securityRepository)();

      expect(result, same(status));
      verify(securityRepository.checkStatus).called(1);
    });

    test('propagates a typed check failure unchanged', () async {
      const failure = SecurityCheckFailure('Security channel unavailable.');
      when(securityRepository.checkStatus)
          .thenAnswer((_) async => throw failure);

      await expectLater(
        CheckSecurityStatus(securityRepository)(),
        throwsA(same(failure)),
      );
    });
  });

  group('StartPaymentProcessing', () {
    test('passes the payment reference to the repository', () async {
      when(() => paymentRepository.startProcessing(reference))
          .thenAnswer((_) async {});

      await StartPaymentProcessing(paymentRepository)(reference);

      verify(() => paymentRepository.startProcessing(reference)).called(1);
    });

    test('propagates a typed startup failure unchanged', () async {
      const failure = PaymentStartFailure('Unable to start processing.');
      when(() => paymentRepository.startProcessing(reference))
          .thenAnswer((_) async => throw failure);

      await expectLater(
        StartPaymentProcessing(paymentRepository)(reference),
        throwsA(same(failure)),
      );
    });
  });

  group('ObservePaymentProcessing', () {
    test('forwards ordered progress and result updates', () async {
      final progress = PaymentProgress(reference: reference, percentage: 40);
      final result = PaymentResult(
        reference: reference,
        outcome: PaymentOutcome.success,
      );
      final updates = Stream<PaymentProcessingUpdate>.fromIterable([
        progress,
        result,
      ]);
      when(() => paymentRepository.observeProcessing(reference))
          .thenAnswer((_) => updates);

      await expectLater(
        ObservePaymentProcessing(paymentRepository)(reference),
        emitsInOrder([progress, result, emitsDone]),
      );
      verify(() => paymentRepository.observeProcessing(reference)).called(1);
    });

    test('propagates a typed stream failure unchanged', () async {
      const failure = PaymentProcessingFailure('Progress stream failed.');
      when(() => paymentRepository.observeProcessing(reference))
          .thenAnswer((_) => Stream<PaymentProcessingUpdate>.error(failure));

      await expectLater(
        ObservePaymentProcessing(paymentRepository)(reference),
        emitsError(same(failure)),
      );
    });
  });
}
