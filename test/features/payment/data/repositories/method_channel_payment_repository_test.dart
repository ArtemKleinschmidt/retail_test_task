import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retail_test_task/features/payment/data/repositories/method_channel_payment_repository.dart';
import 'package:retail_test_task/features/payment/data/sources/predefined_payment.dart';
import 'package:retail_test_task/features/payment/domain/entities/payment_processing_update.dart';
import 'package:retail_test_task/features/payment/domain/failures/payment_failure.dart';

final class MockEventChannel extends Mock implements EventChannel {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel(
    MethodChannelPaymentRepository.channelName,
  );
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final payment = createPredefinedPayment();

  late MockEventChannel processingEvents;
  late MethodChannelPaymentRepository repository;

  setUp(() {
    processingEvents = MockEventChannel();
    when(() => processingEvents.receiveBroadcastStream())
        .thenAnswer((_) => const Stream<Object?>.empty());
    repository = MethodChannelPaymentRepository.withChannels(
      payment: payment,
      methodChannel: methodChannel,
      processingEvents: processingEvents,
    );
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(methodChannel, null);
  });

  test('loads the predefined payment without using a platform channel', () {
    expect(repository.loadPayment(), completion(payment));
  });

  group('startProcessing', () {
    test('sends the payment reference to the native service', () async {
      MethodCall? receivedCall;
      messenger.setMockMethodCallHandler(methodChannel, (call) async {
        receivedCall = call;
        return null;
      });

      await repository.startProcessing(payment.reference);

      expect(receivedCall?.method, 'startProcessing');
      expect(receivedCall?.arguments, {'reference': payment.reference.value});
    });

    test('maps a platform error to a typed start failure', () async {
      messenger.setMockMethodCallHandler(
        methodChannel,
        (_) async => throw PlatformException(code: 'payment_start_failed'),
      );

      await expectLater(
        repository.startProcessing(payment.reference),
        throwsA(isA<PaymentStartFailure>()),
      );
    });

    test('maps a missing plugin to a typed start failure', () async {
      await expectLater(
        repository.startProcessing(payment.reference),
        throwsA(isA<PaymentStartFailure>()),
      );
    });
  });

  group('observeProcessing', () {
    test('maps progress and successful completion', () async {
      when(() => processingEvents.receiveBroadcastStream()).thenAnswer(
        (_) => Stream<Object?>.fromIterable([
          {
            'reference': payment.reference.value,
            'type': 'progress',
            'percentage': 45,
          },
          {
            'reference': payment.reference.value,
            'type': 'result',
            'outcome': 'success',
          },
        ]),
      );

      await expectLater(
        repository.observeProcessing(payment.reference),
        emitsInOrder([
          PaymentProgress(reference: payment.reference, percentage: 45),
          PaymentResult(
            reference: payment.reference,
            outcome: PaymentOutcome.success,
          ),
          emitsDone,
        ]),
      );
    });

    final malformedEvents = <String, Object?>{
      'non-map': 'progress',
      'missing type': {'reference': payment.reference.value},
      'unknown type': {'reference': payment.reference.value, 'type': 'waiting'},
      'non-integer progress': {
        'reference': payment.reference.value,
        'type': 'progress',
        'percentage': '45',
      },
      'out-of-range progress': {
        'reference': payment.reference.value,
        'type': 'progress',
        'percentage': 101,
      },
      'unknown outcome': {
        'reference': payment.reference.value,
        'type': 'result',
        'outcome': 'pending',
      },
    };

    for (final entry in malformedEvents.entries) {
      test('maps ${entry.key} to a typed processing failure', () async {
        when(() => processingEvents.receiveBroadcastStream())
            .thenAnswer((_) => Stream<Object?>.value(entry.value));

        await expectLater(
          repository.observeProcessing(payment.reference),
          emitsError(isA<PaymentProcessingFailure>()),
        );
      });
    }

    test('maps an event-channel error to a typed processing failure', () async {
      when(() => processingEvents.receiveBroadcastStream()).thenAnswer(
        (_) => Stream<Object?>.error(
          PlatformException(code: 'payment_processing_failed'),
        ),
      );

      await expectLater(
        repository.observeProcessing(payment.reference),
        emitsError(isA<PaymentProcessingFailure>()),
      );
    });
  });
}
