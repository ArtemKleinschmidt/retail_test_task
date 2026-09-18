import 'package:equatable/equatable.dart';

sealed class PaymentFailure extends Equatable implements Exception {
  const PaymentFailure(this.message);

  final String message;

  @override
  List<Object> get props => [message];

  @override
  String toString() => '$runtimeType: $message';
}

final class PaymentLoadFailure extends PaymentFailure {
  const PaymentLoadFailure(super.message);
}

final class PaymentStartFailure extends PaymentFailure {
  const PaymentStartFailure(super.message);
}

final class PaymentProcessingFailure extends PaymentFailure {
  const PaymentProcessingFailure(super.message);
}
