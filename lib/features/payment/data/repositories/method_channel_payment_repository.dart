import 'package:flutter/services.dart';
import 'package:retail_test_task/features/payment/domain/entities/payment.dart';
import 'package:retail_test_task/features/payment/domain/entities/payment_processing_update.dart';
import 'package:retail_test_task/features/payment/domain/entities/payment_reference.dart';
import 'package:retail_test_task/features/payment/domain/failures/payment_failure.dart';
import 'package:retail_test_task/features/payment/domain/repositories/payment_repository.dart';

enum MethodChannelDebugProcessingBehavior {
  declined,
  startFailure,
  progressFailure,
}

final class MethodChannelPaymentRepository implements PaymentRepository {
  MethodChannelPaymentRepository({
    required this.payment,
    this.debugProcessingBehavior,
  }) : _methodChannel = const MethodChannel(channelName),
       _processingEvents = const EventChannel(eventsChannelName);

  MethodChannelPaymentRepository.withChannels({
    required Payment payment,
    required MethodChannel methodChannel,
    required EventChannel processingEvents,
    MethodChannelDebugProcessingBehavior? debugProcessingBehavior,
  }) : this._(
         payment: payment,
         methodChannel: methodChannel,
         processingEvents: processingEvents,
         debugProcessingBehavior: debugProcessingBehavior,
       );

  MethodChannelPaymentRepository._({
    required this.payment,
    required this._methodChannel,
    required this._processingEvents,
    this.debugProcessingBehavior,
  });

  static const channelName = 'com.example.retail_test_task/payment_processing';
  static const eventsChannelName =
      'com.example.retail_test_task/payment_processing_events';

  static const _startProcessingMethod = 'startProcessing';
  static const _debugProcessingBehaviorKey = 'debugProcessingBehavior';
  static const _startFailureMessage = 'Payment processing could not start.';
  static const _processingFailureMessage = 'Payment progress was interrupted.';

  final Payment payment;
  final MethodChannelDebugProcessingBehavior? debugProcessingBehavior;
  final MethodChannel _methodChannel;
  final EventChannel _processingEvents;

  @override
  Future<Payment> loadPayment() async => payment;

  @override
  Future<void> startProcessing(PaymentReference reference) async {
    try {
      await _methodChannel.invokeMethod<void>(_startProcessingMethod, {
        'reference': reference.value,
        if (debugProcessingBehavior case final behavior?)
          _debugProcessingBehaviorKey: behavior.name,
      });
    } on PlatformException {
      throw const PaymentStartFailure(_startFailureMessage);
    } on MissingPluginException {
      throw const PaymentStartFailure(_startFailureMessage);
    }
  }

  @override
  Stream<PaymentProcessingUpdate> observeProcessing(
    PaymentReference reference,
  ) async* {
    try {
      await for (final event in _processingEvents.receiveBroadcastStream()) {
        final update = _mapUpdate(event);
        if (update.reference == reference) {
          yield update;
        }
      }
    } on PaymentProcessingFailure {
      rethrow;
    } on Object {
      throw const PaymentProcessingFailure(_processingFailureMessage);
    }
  }

  PaymentProcessingUpdate _mapUpdate(Object? event) {
    if (event is! Map<Object?, Object?>) {
      throw const PaymentProcessingFailure(_processingFailureMessage);
    }

    final referenceValue = event['reference'];
    final type = event['type'];
    if (referenceValue is! String || type is! String) {
      throw const PaymentProcessingFailure(_processingFailureMessage);
    }

    try {
      final reference = PaymentReference(referenceValue);
      return switch (type) {
        'progress' => _mapProgress(event, reference),
        'result' => _mapResult(event, reference),
        _ => throw const PaymentProcessingFailure(_processingFailureMessage),
      };
    } on PaymentProcessingFailure {
      rethrow;
    } on Object {
      throw const PaymentProcessingFailure(_processingFailureMessage);
    }
  }

  PaymentProgress _mapProgress(
    Map<Object?, Object?> event,
    PaymentReference reference,
  ) {
    final percentage = event['percentage'];
    if (percentage is! int) {
      throw const PaymentProcessingFailure(_processingFailureMessage);
    }

    return PaymentProgress(reference: reference, percentage: percentage);
  }

  PaymentResult _mapResult(
    Map<Object?, Object?> event,
    PaymentReference reference,
  ) {
    final outcome = switch (event['outcome']) {
      'success' => PaymentOutcome.success,
      'failure' => PaymentOutcome.failure,
      _ => throw const PaymentProcessingFailure(_processingFailureMessage),
    };

    return PaymentResult(reference: reference, outcome: outcome);
  }
}
