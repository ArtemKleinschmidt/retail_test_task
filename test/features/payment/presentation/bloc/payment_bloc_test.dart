import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retail_test_task/features/payment/domain/entities/confirmation_decision.dart';
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
import 'package:retail_test_task/features/payment/domain/use_cases/evaluate_confirmation.dart';
import 'package:retail_test_task/features/payment/domain/use_cases/load_payment.dart';
import 'package:retail_test_task/features/payment/domain/use_cases/observe_payment_processing.dart';
import 'package:retail_test_task/features/payment/domain/use_cases/observe_screen_recording.dart';
import 'package:retail_test_task/features/payment/domain/use_cases/start_payment_processing.dart';
import 'package:retail_test_task/features/payment/presentation/bloc/payment_bloc.dart';

final class MockPaymentRepository extends Mock implements PaymentRepository {}

final class MockSecurityRepository extends Mock implements SecurityRepository {}

void main() {
  const clearStatus = SecurityStatus(
    root: SecuritySignalState.clear,
    screenRecording: SecuritySignalState.clear,
  );
  const unsupportedStatus = SecurityStatus(
    root: SecuritySignalState.unsupported,
    screenRecording: SecuritySignalState.unsupported,
  );

  late MockPaymentRepository paymentRepository;
  late MockSecurityRepository securityRepository;
  late StreamController<PaymentProcessingUpdate> processingController;
  late StreamController<SecuritySignalState> securityController;
  late Payment payment;

  PaymentBloc buildBloc() {
    return PaymentBloc(
      loadPayment: LoadPayment(paymentRepository),
      checkSecurityStatus: CheckSecurityStatus(securityRepository),
      evaluateConfirmation: const EvaluateConfirmation(),
      startPaymentProcessing: StartPaymentProcessing(paymentRepository),
      observePaymentProcessing: ObservePaymentProcessing(paymentRepository),
      observeScreenRecording: ObserveScreenRecording(securityRepository),
    );
  }

  setUp(() {
    paymentRepository = MockPaymentRepository();
    securityRepository = MockSecurityRepository();
    processingController = StreamController<PaymentProcessingUpdate>();
    securityController = StreamController<SecuritySignalState>();
    payment = Payment(
      reference: PaymentReference('INV-001'),
      payeeName: 'City Utilities',
      total: Money(amountInMinorUnits: 2500, currencyCode: 'USD'),
    );

    when(paymentRepository.loadPayment).thenAnswer((_) async => payment);
    when(securityRepository.checkStatus).thenAnswer((_) async => clearStatus);
    when(securityRepository.observeScreenRecording)
        .thenAnswer((_) => securityController.stream);
    when(() => paymentRepository.observeProcessing(payment.reference))
        .thenAnswer((_) => processingController.stream);
    when(() => paymentRepository.startProcessing(payment.reference))
        .thenAnswer((_) async {});
  });

  tearDown(() {
    if (!processingController.isClosed) {
      unawaited(processingController.close());
    }
    if (!securityController.isClosed) {
      unawaited(securityController.close());
    }
  });

  test('starts in PaymentInitial', () async {
    final bloc = buildBloc();

    expect(bloc.state, const PaymentInitial());

    await bloc.close();
  });

  group('loading', () {
    blocTest<PaymentBloc, PaymentState>(
      'loads the payment and emits ready when security is clear',
      build: buildBloc,
      act: (bloc) => bloc.add(const PaymentLoadRequested()),
      expect: () => [
        const PaymentLoading(),
        PaymentReady(payment: payment, securityStatus: clearStatus),
      ],
      verify: (_) {
        verify(paymentRepository.loadPayment).called(1);
        verify(securityRepository.checkStatus).called(1);
      },
    );

    blocTest<PaymentBloc, PaymentState>(
      'treats unsupported security signals as non-blocking',
      setUp: () {
        when(securityRepository.checkStatus)
            .thenAnswer((_) async => unsupportedStatus);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const PaymentLoadRequested()),
      expect: () => [
        const PaymentLoading(),
        PaymentReady(payment: payment, securityStatus: unsupportedStatus),
      ],
    );

    for (final testCase
        in <
          ({String name, SecurityStatus status, List<SecurityThreat> threats})
        >[
          (
            name: 'root detection',
            status: const SecurityStatus(
              root: SecuritySignalState.detected,
              screenRecording: SecuritySignalState.clear,
            ),
            threats: const [SecurityThreat.rootedDevice],
          ),
          (
            name: 'screen recording detection',
            status: const SecurityStatus(
              root: SecuritySignalState.clear,
              screenRecording: SecuritySignalState.detected,
            ),
            threats: const [SecurityThreat.screenRecording],
          ),
          (
            name: 'root and screen recording detection',
            status: const SecurityStatus(
              root: SecuritySignalState.detected,
              screenRecording: SecuritySignalState.detected,
            ),
            threats: const [
              SecurityThreat.rootedDevice,
              SecurityThreat.screenRecording,
            ],
          ),
        ]) {
      blocTest<PaymentBloc, PaymentState>(
        'blocks confirmation for ${testCase.name}',
        setUp: () {
          when(securityRepository.checkStatus)
              .thenAnswer((_) async => testCase.status);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const PaymentLoadRequested()),
        expect: () => [
          const PaymentLoading(),
          PaymentConfirmationBlocked(
            payment: payment,
            securityStatus: testCase.status,
            decision: ConfirmationDecision.blocked(testCase.threats),
          ),
        ],
      );
    }

    blocTest<PaymentBloc, PaymentState>(
      'emits a typed payment-load failure without checking security',
      setUp: () {
        when(paymentRepository.loadPayment).thenAnswer(
          (_) async => throw const PaymentLoadFailure('Unable to load.'),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const PaymentLoadRequested()),
      expect: () => const [
        PaymentLoading(),
        PaymentLoadFailed(PaymentLoadFailure('Unable to load.')),
      ],
      verify: (_) => verifyNever(securityRepository.checkStatus),
    );

    blocTest<PaymentBloc, PaymentState>(
      'emits a retryable security-check failure with the loaded payment',
      setUp: () {
        when(securityRepository.checkStatus).thenAnswer(
          (_) async => throw const SecurityCheckFailure('Check failed.'),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const PaymentLoadRequested()),
      expect: () => [
        const PaymentLoading(),
        PaymentSecurityCheckFailed(
          payment: payment,
          failure: const SecurityCheckFailure('Check failed.'),
        ),
      ],
    );
  });

  group('confirmation', () {
    blocTest<PaymentBloc, PaymentState>(
      're-checks security and blocks a previously ready payment',
      setUp: () {
        when(securityRepository.checkStatus).thenAnswer(
          (_) async => const SecurityStatus(
            root: SecuritySignalState.clear,
            screenRecording: SecuritySignalState.detected,
          ),
        );
      },
      build: buildBloc,
      seed: () => PaymentReady(payment: payment, securityStatus: clearStatus),
      act: (bloc) => bloc.add(const PaymentConfirmationRequested()),
      expect: () => [
        PaymentCheckingSecurity(payment),
        PaymentConfirmationBlocked(
          payment: payment,
          securityStatus: const SecurityStatus(
            root: SecuritySignalState.clear,
            screenRecording: SecuritySignalState.detected,
          ),
          decision: ConfirmationDecision.blocked(const [
            SecurityThreat.screenRecording,
          ]),
        ),
      ],
      verify: (_) {
        verify(securityRepository.checkStatus).called(1);
        verifyNever(() => paymentRepository.startProcessing(payment.reference));
      },
    );

    blocTest<PaymentBloc, PaymentState>(
      'allows a previously blocked payment after a clear re-check',
      build: buildBloc,
      seed: () => PaymentConfirmationBlocked(
        payment: payment,
        securityStatus: const SecurityStatus(
          root: SecuritySignalState.detected,
          screenRecording: SecuritySignalState.clear,
        ),
        decision: ConfirmationDecision.blocked(const [
          SecurityThreat.rootedDevice,
        ]),
      ),
      act: (bloc) => bloc.add(const PaymentConfirmationRequested()),
      expect: () => [
        PaymentCheckingSecurity(payment),
        PaymentProcessing(
          payment: payment,
          securityStatus: clearStatus,
          percentage: 0,
        ),
      ],
      verify: (_) {
        verify(securityRepository.checkStatus).called(1);
        verify(() => paymentRepository.startProcessing(payment.reference))
            .called(1);
      },
    );

    blocTest<PaymentBloc, PaymentState>(
      'fails closed on a confirmation-time security error and can retry',
      setUp: () {
        var checkCount = 0;
        when(securityRepository.checkStatus).thenAnswer((_) async {
          checkCount += 1;
          if (checkCount == 1) {
            throw const SecurityCheckFailure('Check failed.');
          }
          return clearStatus;
        });
      },
      build: buildBloc,
      seed: () => PaymentReady(payment: payment, securityStatus: clearStatus),
      act: (bloc) async {
        bloc.add(const PaymentConfirmationRequested());
        await bloc.stream.firstWhere(
          (state) => state is PaymentSecurityCheckFailed,
        );
        bloc.add(const PaymentConfirmationRequested());
      },
      expect: () => [
        PaymentCheckingSecurity(payment),
        PaymentSecurityCheckFailed(
          payment: payment,
          failure: const SecurityCheckFailure('Check failed.'),
        ),
        PaymentCheckingSecurity(payment),
        PaymentProcessing(
          payment: payment,
          securityStatus: clearStatus,
          percentage: 0,
        ),
      ],
      verify: (_) => verify(securityRepository.checkStatus).called(2),
    );

    blocTest<PaymentBloc, PaymentState>(
      'subscribes before starting and emits a typed startup failure',
      setUp: () {
        when(() => paymentRepository.startProcessing(payment.reference))
            .thenAnswer((_) async {
              expect(processingController.hasListener, isTrue);
              throw const PaymentStartFailure('Start failed.');
            });
      },
      build: buildBloc,
      seed: () => PaymentReady(payment: payment, securityStatus: clearStatus),
      act: (bloc) => bloc.add(const PaymentConfirmationRequested()),
      expect: () => [
        PaymentCheckingSecurity(payment),
        PaymentProcessing(
          payment: payment,
          securityStatus: clearStatus,
          percentage: 0,
        ),
        PaymentProcessingFailed(
          payment: payment,
          failure: const PaymentStartFailure('Start failed.'),
        ),
      ],
      verify: (_) => expect(processingController.hasListener, isFalse),
    );

    blocTest<PaymentBloc, PaymentState>(
      'ignores confirmation when the current state is ineligible',
      build: buildBloc,
      act: (bloc) => bloc.add(const PaymentConfirmationRequested()),
      expect: () => const <PaymentState>[],
      verify: (_) {
        verifyNever(securityRepository.checkStatus);
        verifyNever(() => paymentRepository.startProcessing(payment.reference));
      },
    );

    blocTest<PaymentBloc, PaymentState>(
      'ignores a duplicate confirmation while processing',
      build: buildBloc,
      seed: () => PaymentReady(payment: payment, securityStatus: clearStatus),
      act: (bloc) async {
        bloc.add(const PaymentConfirmationRequested());
        await bloc.stream.firstWhere((state) => state is PaymentProcessing);
        bloc.add(const PaymentConfirmationRequested());
      },
      expect: () => [
        PaymentCheckingSecurity(payment),
        PaymentProcessing(
          payment: payment,
          securityStatus: clearStatus,
          percentage: 0,
        ),
      ],
      verify: (_) {
        verify(securityRepository.checkStatus).called(1);
        verify(() => paymentRepository.startProcessing(payment.reference))
            .called(1);
      },
    );
  });

  group('dynamic screen-recording status', () {
    blocTest<PaymentBloc, PaymentState>(
      'blocks a ready payment as soon as recording starts',
      build: buildBloc,
      seed: () => PaymentReady(payment: payment, securityStatus: clearStatus),
      act: (_) => securityController.add(SecuritySignalState.detected),
      expect: () => [
        PaymentConfirmationBlocked(
          payment: payment,
          securityStatus: const SecurityStatus(
            root: SecuritySignalState.clear,
            screenRecording: SecuritySignalState.detected,
          ),
          decision: ConfirmationDecision.blocked(const [
            SecurityThreat.screenRecording,
          ]),
        ),
      ],
    );

    blocTest<PaymentBloc, PaymentState>(
      'returns to ready as soon as recording stops',
      build: buildBloc,
      seed: () => PaymentConfirmationBlocked(
        payment: payment,
        securityStatus: const SecurityStatus(
          root: SecuritySignalState.clear,
          screenRecording: SecuritySignalState.detected,
        ),
        decision: ConfirmationDecision.blocked(const [
          SecurityThreat.screenRecording,
        ]),
      ),
      act: (_) => securityController.add(SecuritySignalState.clear),
      expect: () => [
        PaymentReady(payment: payment, securityStatus: clearStatus),
      ],
    );

    blocTest<PaymentBloc, PaymentState>(
      'fails closed when dynamic observation fails',
      build: buildBloc,
      seed: () => PaymentReady(payment: payment, securityStatus: clearStatus),
      act: (_) => securityController.addError(
        const SecurityCheckFailure('Recording status unavailable.'),
      ),
      expect: () => [
        PaymentSecurityCheckFailed(
          payment: payment,
          failure: const SecurityCheckFailure('Recording status unavailable.'),
        ),
      ],
    );
  });

  group('processing', () {
    blocTest<PaymentBloc, PaymentState>(
      'emits ordered progress and a successful terminal outcome',
      build: buildBloc,
      seed: () => PaymentReady(payment: payment, securityStatus: clearStatus),
      act: (bloc) async {
        bloc.add(const PaymentConfirmationRequested());
        await bloc.stream.firstWhere((state) => state is PaymentProcessing);
        processingController
          ..add(PaymentProgress(reference: payment.reference, percentage: 20))
          ..add(PaymentProgress(reference: payment.reference, percentage: 75))
          ..add(
            PaymentResult(
              reference: payment.reference,
              outcome: PaymentOutcome.success,
            ),
          );
      },
      expect: () => [
        PaymentCheckingSecurity(payment),
        PaymentProcessing(
          payment: payment,
          securityStatus: clearStatus,
          percentage: 0,
        ),
        PaymentProcessing(
          payment: payment,
          securityStatus: clearStatus,
          percentage: 20,
        ),
        PaymentProcessing(
          payment: payment,
          securityStatus: clearStatus,
          percentage: 75,
        ),
        PaymentCompleted(payment: payment, outcome: PaymentOutcome.success),
      ],
    );

    blocTest<PaymentBloc, PaymentState>(
      'keeps an unsuccessful result distinct from infrastructure failure',
      build: buildBloc,
      seed: () => PaymentReady(payment: payment, securityStatus: clearStatus),
      act: (bloc) async {
        bloc.add(const PaymentConfirmationRequested());
        await bloc.stream.firstWhere((state) => state is PaymentProcessing);
        processingController.add(
          PaymentResult(
            reference: payment.reference,
            outcome: PaymentOutcome.failure,
          ),
        );
      },
      expect: () => [
        PaymentCheckingSecurity(payment),
        PaymentProcessing(
          payment: payment,
          securityStatus: clearStatus,
          percentage: 0,
        ),
        PaymentCompleted(payment: payment, outcome: PaymentOutcome.failure),
      ],
    );

    blocTest<PaymentBloc, PaymentState>(
      'preserves a typed processing-stream failure',
      build: buildBloc,
      seed: () => PaymentReady(payment: payment, securityStatus: clearStatus),
      act: (bloc) async {
        bloc.add(const PaymentConfirmationRequested());
        await bloc.stream.firstWhere((state) => state is PaymentProcessing);
        processingController.addError(
          const PaymentProcessingFailure('Progress unavailable.'),
        );
      },
      expect: () => [
        PaymentCheckingSecurity(payment),
        PaymentProcessing(
          payment: payment,
          securityStatus: clearStatus,
          percentage: 0,
        ),
        PaymentProcessingFailed(
          payment: payment,
          failure: const PaymentProcessingFailure('Progress unavailable.'),
        ),
      ],
    );

    blocTest<PaymentBloc, PaymentState>(
      'normalizes an unexpected processing-stream error',
      build: buildBloc,
      seed: () => PaymentReady(payment: payment, securityStatus: clearStatus),
      act: (bloc) async {
        bloc.add(const PaymentConfirmationRequested());
        await bloc.stream.firstWhere((state) => state is PaymentProcessing);
        processingController.addError(StateError('Disconnected.'));
      },
      expect: () => [
        PaymentCheckingSecurity(payment),
        PaymentProcessing(
          payment: payment,
          securityStatus: clearStatus,
          percentage: 0,
        ),
        PaymentProcessingFailed(
          payment: payment,
          failure: const PaymentProcessingFailure('Bad state: Disconnected.'),
        ),
      ],
    );

    test('cancels the processing subscription when closed', () async {
      var wasCancelled = false;
      processingController = StreamController<PaymentProcessingUpdate>(
        onCancel: () => wasCancelled = true,
      );
      when(() => paymentRepository.observeProcessing(payment.reference))
          .thenAnswer((_) => processingController.stream);
      final bloc = buildBloc();

      bloc.add(const PaymentLoadRequested());
      await bloc.stream.firstWhere((state) => state is PaymentReady);
      bloc.add(const PaymentConfirmationRequested());
      await bloc.stream.firstWhere((state) => state is PaymentProcessing);

      await bloc.close();

      expect(wasCancelled, isTrue);
    });
  });
}
