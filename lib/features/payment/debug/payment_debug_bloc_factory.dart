import 'package:retail_test_task/features/payment/data/repositories/simulated_payment_repository.dart';
import 'package:retail_test_task/features/payment/data/repositories/simulated_security_repository.dart';
import 'package:retail_test_task/features/payment/data/sources/predefined_payment.dart';
import 'package:retail_test_task/features/payment/debug/payment_debug_scenario.dart';
import 'package:retail_test_task/features/payment/domain/use_cases/check_security_status.dart';
import 'package:retail_test_task/features/payment/domain/use_cases/evaluate_confirmation.dart';
import 'package:retail_test_task/features/payment/domain/use_cases/load_payment.dart';
import 'package:retail_test_task/features/payment/domain/use_cases/observe_payment_processing.dart';
import 'package:retail_test_task/features/payment/domain/use_cases/start_payment_processing.dart';
import 'package:retail_test_task/features/payment/presentation/bloc/payment_bloc.dart';

PaymentBloc createDebugPaymentBloc(PaymentDebugScenario scenario) {
  final paymentRepository = SimulatedPaymentRepository(
    payment: createPredefinedPayment(),
    loadBehavior: scenario.loadBehavior,
    processingBehavior: scenario.processingBehavior,
  );
  final securityRepository = SimulatedSecurityRepository(
    behavior: scenario.securityBehavior,
  );

  return PaymentBloc(
    loadPayment: LoadPayment(paymentRepository),
    checkSecurityStatus: CheckSecurityStatus(securityRepository),
    evaluateConfirmation: const EvaluateConfirmation(),
    startPaymentProcessing: StartPaymentProcessing(paymentRepository),
    observePaymentProcessing: ObservePaymentProcessing(paymentRepository),
  );
}
