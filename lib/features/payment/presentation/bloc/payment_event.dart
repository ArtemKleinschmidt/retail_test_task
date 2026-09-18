part of 'payment_bloc.dart';

sealed class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => const [];
}

final class PaymentLoadRequested extends PaymentEvent {
  const PaymentLoadRequested();
}

final class PaymentConfirmationRequested extends PaymentEvent {
  const PaymentConfirmationRequested();
}

final class _PaymentProcessingUpdateReceived extends PaymentEvent {
  const _PaymentProcessingUpdateReceived(this.update);

  final PaymentProcessingUpdate update;

  @override
  List<Object> get props => [update];
}

final class _PaymentProcessingStreamFailed extends PaymentEvent {
  const _PaymentProcessingStreamFailed({
    required this.reference,
    required this.failure,
  });

  final PaymentReference reference;
  final PaymentFailure failure;

  @override
  List<Object> get props => [reference, failure];
}
