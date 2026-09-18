part of 'payment_bloc.dart';

sealed class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object> get props => const [];
}

final class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

final class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

final class PaymentReady extends PaymentState {
  const PaymentReady({required this.payment, required this.securityStatus});

  final Payment payment;
  final SecurityStatus securityStatus;

  @override
  List<Object> get props => [payment, securityStatus];
}

final class PaymentCheckingSecurity extends PaymentState {
  const PaymentCheckingSecurity(this.payment);

  final Payment payment;

  @override
  List<Object> get props => [payment];
}

final class PaymentConfirmationBlocked extends PaymentState {
  const PaymentConfirmationBlocked({
    required this.payment,
    required this.securityStatus,
    required this.decision,
  });

  final Payment payment;
  final SecurityStatus securityStatus;
  final ConfirmationDecision decision;

  @override
  List<Object> get props => [payment, securityStatus, decision];
}

final class PaymentLoadFailed extends PaymentState {
  const PaymentLoadFailed(this.failure);

  final PaymentLoadFailure failure;

  @override
  List<Object> get props => [failure];
}

final class PaymentSecurityCheckFailed extends PaymentState {
  const PaymentSecurityCheckFailed({
    required this.payment,
    required this.failure,
  });

  final Payment payment;
  final SecurityCheckFailure failure;

  @override
  List<Object> get props => [payment, failure];
}

final class PaymentProcessing extends PaymentState {
  const PaymentProcessing({
    required this.payment,
    required this.securityStatus,
    required this.percentage,
  });

  final Payment payment;
  final SecurityStatus securityStatus;
  final int percentage;

  @override
  List<Object> get props => [payment, securityStatus, percentage];
}

final class PaymentCompleted extends PaymentState {
  const PaymentCompleted({required this.payment, required this.outcome});

  final Payment payment;
  final PaymentOutcome outcome;

  @override
  List<Object> get props => [payment, outcome];
}

final class PaymentProcessingFailed extends PaymentState {
  const PaymentProcessingFailed({required this.payment, required this.failure});

  final Payment payment;
  final PaymentFailure failure;

  @override
  List<Object> get props => [payment, failure];
}
