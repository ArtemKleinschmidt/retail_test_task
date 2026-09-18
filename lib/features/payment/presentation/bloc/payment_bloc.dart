import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:retail_test_task/features/payment/domain/entities/confirmation_decision.dart';
import 'package:retail_test_task/features/payment/domain/entities/payment.dart';
import 'package:retail_test_task/features/payment/domain/entities/payment_processing_update.dart';
import 'package:retail_test_task/features/payment/domain/entities/payment_reference.dart';
import 'package:retail_test_task/features/payment/domain/entities/security_status.dart';
import 'package:retail_test_task/features/payment/domain/failures/payment_failure.dart';
import 'package:retail_test_task/features/payment/domain/failures/security_failure.dart';
import 'package:retail_test_task/features/payment/domain/use_cases/check_security_status.dart';
import 'package:retail_test_task/features/payment/domain/use_cases/evaluate_confirmation.dart';
import 'package:retail_test_task/features/payment/domain/use_cases/load_payment.dart';
import 'package:retail_test_task/features/payment/domain/use_cases/observe_payment_processing.dart';
import 'package:retail_test_task/features/payment/domain/use_cases/start_payment_processing.dart';

part 'payment_event.dart';
part 'payment_state.dart';

final class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  factory PaymentBloc({
    required LoadPayment loadPayment,
    required CheckSecurityStatus checkSecurityStatus,
    required EvaluateConfirmation evaluateConfirmation,
    required StartPaymentProcessing startPaymentProcessing,
    required ObservePaymentProcessing observePaymentProcessing,
  }) {
    return PaymentBloc._(
      loadPayment,
      checkSecurityStatus,
      evaluateConfirmation,
      startPaymentProcessing,
      observePaymentProcessing,
    );
  }

  PaymentBloc._(
    this._loadPayment,
    this._checkSecurityStatus,
    this._evaluateConfirmation,
    this._startPaymentProcessing,
    this._observePaymentProcessing,
  ) : super(const PaymentInitial()) {
    on<PaymentLoadRequested>(_onLoadRequested);
    on<PaymentConfirmationRequested>(_onConfirmationRequested);
    on<_PaymentProcessingUpdateReceived>(_onProcessingUpdateReceived);
    on<_PaymentProcessingStreamFailed>(_onProcessingStreamFailed);
  }

  final LoadPayment _loadPayment;
  final CheckSecurityStatus _checkSecurityStatus;
  final EvaluateConfirmation _evaluateConfirmation;
  final StartPaymentProcessing _startPaymentProcessing;
  final ObservePaymentProcessing _observePaymentProcessing;

  StreamSubscription<PaymentProcessingUpdate>? _processingSubscription;

  Future<void> _onLoadRequested(
    PaymentLoadRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());

    final Payment payment;
    try {
      payment = await _loadPayment();
    } on PaymentLoadFailure catch (failure) {
      emit(PaymentLoadFailed(failure));
      return;
    }

    final SecurityStatus securityStatus;
    try {
      securityStatus = await _checkSecurityStatus();
    } on SecurityCheckFailure catch (failure) {
      emit(PaymentSecurityCheckFailed(payment: payment, failure: failure));
      return;
    }

    emit(_evaluateSecurity(payment, securityStatus));
  }

  Future<void> _onConfirmationRequested(
    PaymentConfirmationRequested event,
    Emitter<PaymentState> emit,
  ) async {
    final payment = _paymentEligibleForConfirmation(state);
    if (payment == null) {
      return;
    }

    emit(PaymentCheckingSecurity(payment));

    final SecurityStatus securityStatus;
    try {
      securityStatus = await _checkSecurityStatus();
    } on SecurityCheckFailure catch (failure) {
      emit(PaymentSecurityCheckFailed(payment: payment, failure: failure));
      return;
    }

    final evaluatedState = _evaluateSecurity(payment, securityStatus);
    if (evaluatedState case PaymentConfirmationBlocked()) {
      emit(evaluatedState);
      return;
    }

    await _beginProcessing(payment, securityStatus, emit);
  }

  Future<void> _beginProcessing(
    Payment payment,
    SecurityStatus securityStatus,
    Emitter<PaymentState> emit,
  ) async {
    final reference = payment.reference;
    emit(
      PaymentProcessing(
        payment: payment,
        securityStatus: securityStatus,
        percentage: 0,
      ),
    );

    try {
      final updates = _observePaymentProcessing(reference);
      _processingSubscription = updates.listen(
        (update) => add(_PaymentProcessingUpdateReceived(update)),
        onError: (Object error, StackTrace stackTrace) {
          add(
            _PaymentProcessingStreamFailed(
              reference: reference,
              failure: _normalizeProcessingFailure(error),
            ),
          );
        },
      );
      await _startPaymentProcessing(reference);
    } on Object catch (error) {
      await _cancelProcessingSubscription();
      emit(
        PaymentProcessingFailed(
          payment: payment,
          failure: _normalizeProcessingFailure(error),
        ),
      );
    }
  }

  Future<void> _onProcessingUpdateReceived(
    _PaymentProcessingUpdateReceived event,
    Emitter<PaymentState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PaymentProcessing ||
        event.update.reference != currentState.payment.reference) {
      return;
    }

    switch (event.update) {
      case PaymentProgress(:final percentage):
        emit(
          PaymentProcessing(
            payment: currentState.payment,
            securityStatus: currentState.securityStatus,
            percentage: percentage,
          ),
        );
      case PaymentResult(:final outcome):
        await _cancelProcessingSubscription();
        emit(PaymentCompleted(payment: currentState.payment, outcome: outcome));
    }
  }

  Future<void> _onProcessingStreamFailed(
    _PaymentProcessingStreamFailed event,
    Emitter<PaymentState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PaymentProcessing ||
        event.reference != currentState.payment.reference) {
      return;
    }

    await _cancelProcessingSubscription();
    emit(
      PaymentProcessingFailed(
        payment: currentState.payment,
        failure: event.failure,
      ),
    );
  }

  PaymentState _evaluateSecurity(
    Payment payment,
    SecurityStatus securityStatus,
  ) {
    final decision = _evaluateConfirmation(securityStatus);
    if (decision.isAllowed) {
      return PaymentReady(payment: payment, securityStatus: securityStatus);
    }

    return PaymentConfirmationBlocked(
      payment: payment,
      securityStatus: securityStatus,
      decision: decision,
    );
  }

  static Payment? _paymentEligibleForConfirmation(PaymentState state) {
    return switch (state) {
      PaymentReady(:final payment) => payment,
      PaymentConfirmationBlocked(:final payment) => payment,
      PaymentSecurityCheckFailed(:final payment) => payment,
      _ => null,
    };
  }

  static PaymentFailure _normalizeProcessingFailure(Object error) {
    if (error case PaymentFailure failure) {
      return failure;
    }

    return PaymentProcessingFailure(error.toString());
  }

  Future<void> _cancelProcessingSubscription() async {
    final subscription = _processingSubscription;
    _processingSubscription = null;
    await subscription?.cancel();
  }

  @override
  Future<void> close() async {
    await _cancelProcessingSubscription();
    return super.close();
  }
}
