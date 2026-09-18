import 'dart:async';

import 'package:retail_test_task/features/payment/domain/entities/payment.dart';
import 'package:retail_test_task/features/payment/domain/entities/payment_processing_update.dart';
import 'package:retail_test_task/features/payment/domain/entities/payment_reference.dart';
import 'package:retail_test_task/features/payment/domain/failures/payment_failure.dart';
import 'package:retail_test_task/features/payment/domain/repositories/payment_repository.dart';

enum SimulatedPaymentLoadBehavior { success, failure }

enum SimulatedPaymentProcessingBehavior {
  success,
  declined,
  startFailure,
  streamFailure,
}

final class SimulatedPaymentRepository implements PaymentRepository {
  SimulatedPaymentRepository({
    required this.payment,
    this.loadBehavior = SimulatedPaymentLoadBehavior.success,
    this.processingBehavior = SimulatedPaymentProcessingBehavior.success,
    this.loadDelay = const Duration(milliseconds: 450),
    this.progressInterval = const Duration(milliseconds: 400),
  });

  final Payment payment;
  final SimulatedPaymentLoadBehavior loadBehavior;
  final SimulatedPaymentProcessingBehavior processingBehavior;
  final Duration loadDelay;
  final Duration progressInterval;

  StreamController<PaymentProcessingUpdate>? _processingController;

  @override
  Future<Payment> loadPayment() async {
    await Future<void>.delayed(loadDelay);
    if (loadBehavior == SimulatedPaymentLoadBehavior.failure) {
      throw const PaymentLoadFailure(
        'The payment details could not be loaded.',
      );
    }

    return payment;
  }

  @override
  Stream<PaymentProcessingUpdate> observeProcessing(
    PaymentReference reference,
  ) {
    final currentController = _processingController;
    if (currentController != null && !currentController.isClosed) {
      return currentController.stream;
    }

    final controller = StreamController<PaymentProcessingUpdate>.broadcast();
    _processingController = controller;
    return controller.stream;
  }

  @override
  Future<void> startProcessing(PaymentReference reference) async {
    if (processingBehavior == SimulatedPaymentProcessingBehavior.startFailure) {
      throw const PaymentStartFailure('Payment processing could not start.');
    }

    final controller = _processingController;
    if (controller == null || controller.isClosed) {
      throw const PaymentStartFailure(
        'Payment progress was not observed before processing started.',
      );
    }

    unawaited(_emitProcessingUpdates(controller, reference));
  }

  Future<void> _emitProcessingUpdates(
    StreamController<PaymentProcessingUpdate> controller,
    PaymentReference reference,
  ) async {
    for (final percentage in const [20, 45, 70, 100]) {
      await Future<void>.delayed(progressInterval);
      if (controller.isClosed) {
        return;
      }

      controller.add(
        PaymentProgress(reference: reference, percentage: percentage),
      );

      if (processingBehavior ==
              SimulatedPaymentProcessingBehavior.streamFailure &&
          percentage == 45) {
        controller.addError(
          const PaymentProcessingFailure('Payment progress was interrupted.'),
        );
        await controller.close();
        return;
      }
    }

    final outcome = switch (processingBehavior) {
      SimulatedPaymentProcessingBehavior.declined => PaymentOutcome.failure,
      _ => PaymentOutcome.success,
    };
    controller.add(PaymentResult(reference: reference, outcome: outcome));
    await controller.close();
  }
}
