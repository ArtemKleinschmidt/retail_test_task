import 'package:retail_test_task/features/payment/data/repositories/simulated_payment_repository.dart';
import 'package:retail_test_task/features/payment/data/repositories/simulated_security_repository.dart';
import 'package:retail_test_task/features/payment/data/sources/predefined_payment.dart';
import 'package:retail_test_task/features/payment/debug/payment_debug_scenario.dart';
import 'package:retail_test_task/features/payment/domain/use_cases/check_security_status.dart';
import 'package:retail_test_task/features/payment/domain/use_cases/evaluate_confirmation.dart';
import 'package:retail_test_task/features/payment/domain/use_cases/load_payment.dart';
import 'package:retail_test_task/features/payment/domain/use_cases/observe_payment_processing.dart';
import 'package:retail_test_task/features/payment/domain/use_cases/observe_screen_recording.dart';
import 'package:retail_test_task/features/payment/domain/use_cases/start_payment_processing.dart';
import 'package:retail_test_task/features/payment/presentation/bloc/payment_bloc.dart';

PaymentBloc createDebugPaymentBloc(PaymentDebugScenario scenario) {
  final paymentRepository = SimulatedPaymentRepository(
    payment: createPredefinedPayment(),
    loadBehavior: switch (scenario.loadBehavior) {
      PaymentDebugLoadBehavior.success => SimulatedPaymentLoadBehavior.success,
      PaymentDebugLoadBehavior.failure => SimulatedPaymentLoadBehavior.failure,
    },
    processingBehavior: switch (scenario.processingBehavior) {
      PaymentDebugProcessingBehavior.success =>
        SimulatedPaymentProcessingBehavior.success,
      PaymentDebugProcessingBehavior.declined =>
        SimulatedPaymentProcessingBehavior.declined,
      PaymentDebugProcessingBehavior.startFailure =>
        SimulatedPaymentProcessingBehavior.startFailure,
      PaymentDebugProcessingBehavior.streamFailure =>
        SimulatedPaymentProcessingBehavior.streamFailure,
    },
  );
  final securityRepository = SimulatedSecurityRepository(
    behavior: switch (scenario.securityBehavior) {
      PaymentDebugSecurityBehavior.clear => SimulatedSecurityBehavior.clear,
      PaymentDebugSecurityBehavior.unsupported =>
        SimulatedSecurityBehavior.unsupported,
      PaymentDebugSecurityBehavior.rooted => SimulatedSecurityBehavior.rooted,
      PaymentDebugSecurityBehavior.screenRecording =>
        SimulatedSecurityBehavior.screenRecording,
      PaymentDebugSecurityBehavior.rootedAndRecording =>
        SimulatedSecurityBehavior.rootedAndRecording,
      PaymentDebugSecurityBehavior.failure => SimulatedSecurityBehavior.failure,
    },
  );

  return PaymentBloc(
    loadPayment: LoadPayment(paymentRepository),
    checkSecurityStatus: CheckSecurityStatus(securityRepository),
    evaluateConfirmation: const EvaluateConfirmation(),
    startPaymentProcessing: StartPaymentProcessing(paymentRepository),
    observePaymentProcessing: ObservePaymentProcessing(paymentRepository),
    observeScreenRecording: ObserveScreenRecording(securityRepository),
    confirmationSecurityCheckDelay: const Duration(seconds: 3),
  );
}
