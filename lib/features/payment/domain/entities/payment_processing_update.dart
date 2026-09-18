import 'package:equatable/equatable.dart';
import 'package:retail_test_task/features/payment/domain/entities/payment_reference.dart';

sealed class PaymentProcessingUpdate extends Equatable {
  const PaymentProcessingUpdate({required this.reference});

  final PaymentReference reference;
}

final class PaymentProgress extends PaymentProcessingUpdate {
  factory PaymentProgress({
    required PaymentReference reference,
    required int percentage,
  }) {
    if (percentage < 0 || percentage > 100) {
      throw ArgumentError.value(
        percentage,
        'percentage',
        'Must be between 0 and 100.',
      );
    }

    return PaymentProgress._(reference: reference, percentage: percentage);
  }

  const PaymentProgress._({required super.reference, required this.percentage});

  final int percentage;

  @override
  List<Object> get props => [reference, percentage];
}

enum PaymentOutcome { success, failure }

final class PaymentResult extends PaymentProcessingUpdate {
  const PaymentResult({required super.reference, required this.outcome});

  final PaymentOutcome outcome;

  @override
  List<Object> get props => [reference, outcome];
}
