part of 'payment_bloc.dart';

sealed class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object> get props => const [];
}

sealed class PaymentContentState extends PaymentState {
  const PaymentContentState({required this.payment});

  final Payment payment;

  PaymentSummaryViewData get summary => PaymentSummaryViewData(
    payeeName: payment.payeeName,
    formattedTotal: _formatMoney(payment.total),
    reference: payment.reference.value,
  );

  PaymentSupplementViewData get supplement => PaymentSupplementViewData(
    formattedTotal: _formatMoney(payment.total),
    billItems: [
      for (final item in payment.billItems)
        BillBreakdownItemViewData(
          label: item.label,
          formattedAmount: _formatMoney(item.amount),
        ),
    ],
  );

  SecurityStatus? get visibleSecurityStatus => null;

  bool get isCheckingSecurity => false;

  SecurityErrorViewData? get securityError => null;

  int? get processingPercentage => null;

  PaymentFeedbackViewData? get feedback => null;

  PaymentActionViewData? get primaryAction => null;
}

final class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

final class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

final class PaymentReady extends PaymentContentState {
  const PaymentReady({required super.payment, required this.securityStatus});

  final SecurityStatus securityStatus;

  @override
  SecurityStatus get visibleSecurityStatus => securityStatus;

  @override
  PaymentActionViewData get primaryAction =>
      const PaymentActionViewData(label: 'Confirm payment', isEnabled: true);

  @override
  List<Object> get props => [payment, securityStatus];
}

final class PaymentCheckingSecurity extends PaymentContentState {
  const PaymentCheckingSecurity(Payment payment, {this.previousSecurityStatus})
    : super(payment: payment);

  final SecurityStatus? previousSecurityStatus;

  @override
  SecurityStatus? get visibleSecurityStatus => previousSecurityStatus;

  @override
  bool get isCheckingSecurity => true;

  @override
  PaymentActionViewData get primaryAction => const PaymentActionViewData(
    label: 'Checking security…',
    isEnabled: false,
  );

  @override
  List<Object> get props => [payment];
}

final class PaymentConfirmationBlocked extends PaymentContentState {
  const PaymentConfirmationBlocked({
    required super.payment,
    required this.securityStatus,
    required this.decision,
  });

  final SecurityStatus securityStatus;
  final ConfirmationDecision decision;

  @override
  SecurityStatus get visibleSecurityStatus => securityStatus;

  @override
  SecurityErrorViewData get securityError => _blockedSecurityError(decision);

  @override
  PaymentActionViewData get primaryAction =>
      const PaymentActionViewData(label: 'Check again', isEnabled: true);

  @override
  List<Object> get props => [payment, securityStatus, decision];
}

final class PaymentLoadFailed extends PaymentState {
  const PaymentLoadFailed(this.failure);

  final PaymentLoadFailure failure;

  @override
  List<Object> get props => [failure];
}

final class PaymentSecurityCheckFailed extends PaymentContentState {
  const PaymentSecurityCheckFailed({
    required super.payment,
    required this.failure,
  });

  final SecurityCheckFailure failure;

  @override
  SecurityErrorViewData get securityError => SecurityErrorViewData(
    title: 'Security check unavailable',
    message: failure.message,
  );

  @override
  PaymentActionViewData get primaryAction => const PaymentActionViewData(
    label: 'Retry security check',
    isEnabled: true,
  );

  @override
  List<Object> get props => [payment, failure];
}

final class PaymentProcessing extends PaymentContentState {
  const PaymentProcessing({
    required super.payment,
    required this.securityStatus,
    required this.percentage,
  });

  final SecurityStatus securityStatus;
  final int percentage;

  @override
  SecurityStatus get visibleSecurityStatus => securityStatus;

  @override
  int get processingPercentage => percentage;

  @override
  PaymentActionViewData get primaryAction =>
      PaymentActionViewData(label: 'Processing $percentage%', isEnabled: false);

  @override
  List<Object> get props => [payment, securityStatus, percentage];
}

final class PaymentCompleted extends PaymentContentState {
  const PaymentCompleted({
    required super.payment,
    required this.outcome,
    this.securityStatus,
  });

  final PaymentOutcome outcome;
  final SecurityStatus? securityStatus;

  @override
  SecurityStatus? get visibleSecurityStatus => securityStatus;

  @override
  int get processingPercentage => 100;

  @override
  PaymentFeedbackViewData get feedback => switch (outcome) {
    PaymentOutcome.success => const PaymentFeedbackViewData(
      title: 'Payment successful',
      message: 'The payment has been confirmed.',
      isPositive: true,
    ),
    PaymentOutcome.failure => const PaymentFeedbackViewData(
      title: 'Payment declined',
      message: 'The payment completed but was not approved.',
      isPositive: false,
    ),
  };

  @override
  PaymentActionViewData get primaryAction => switch (outcome) {
    PaymentOutcome.success => const PaymentActionViewData(
      label: 'Payment completed',
      isEnabled: false,
    ),
    PaymentOutcome.failure => const PaymentActionViewData(
      label: 'Try again',
      isEnabled: true,
    ),
  };

  @override
  List<Object> get props => [payment, outcome];
}

final class PaymentProcessingFailed extends PaymentContentState {
  const PaymentProcessingFailed({
    required super.payment,
    required this.failure,
  });

  final PaymentFailure failure;

  @override
  PaymentFeedbackViewData get feedback => PaymentFeedbackViewData(
    title: 'Processing interrupted',
    message: failure.message,
    isPositive: false,
  );

  @override
  PaymentActionViewData get primaryAction =>
      const PaymentActionViewData(label: 'Try again', isEnabled: true);

  @override
  List<Object> get props => [payment, failure];
}

final class PaymentSummaryViewData {
  const PaymentSummaryViewData({
    required this.payeeName,
    required this.formattedTotal,
    required this.reference,
  });

  final String payeeName;
  final String formattedTotal;
  final String reference;
}

final class PaymentFeedbackViewData {
  const PaymentFeedbackViewData({
    required this.title,
    required this.message,
    required this.isPositive,
  });

  final String title;
  final String message;
  final bool isPositive;
}

final class PaymentActionViewData {
  const PaymentActionViewData({required this.label, required this.isEnabled});

  final String label;
  final bool isEnabled;
}

String _formatMoney(Money money) {
  final majorUnits = money.amountInMinorUnits ~/ 100;
  final minorUnits = (money.amountInMinorUnits % 100).toString().padLeft(
    2,
    '0',
  );
  return '${money.currencyCode} $majorUnits.$minorUnits';
}

SecurityErrorViewData _blockedSecurityError(ConfirmationDecision decision) {
  final threats = decision.blockingThreats;
  if (threats.length > 1) {
    return const SecurityErrorViewData(
      title: 'Payment blocked',
      message:
          'Root access and active screen recording were detected. Secure the '
          'device before trying again.',
    );
  }

  return switch (threats.single) {
    SecurityThreat.rootedDevice => const SecurityErrorViewData(
      title: 'Rooted device detected',
      message: 'Payment is unavailable while elevated device access is active.',
    ),
    SecurityThreat.screenRecording => const SecurityErrorViewData(
      title: 'Screen recording detected',
      message: 'Stop screen recording or sharing before confirming payment.',
    ),
  };
}
