import 'package:get_it/get_it.dart';
import 'package:retail_test_task/features/payment/data/repositories/simulated_payment_repository.dart';
import 'package:retail_test_task/features/payment/data/repositories/simulated_security_repository.dart';
import 'package:retail_test_task/features/payment/data/sources/predefined_payment.dart';
import 'package:retail_test_task/features/payment/domain/repositories/payment_repository.dart';
import 'package:retail_test_task/features/payment/domain/repositories/security_repository.dart';
import 'package:retail_test_task/features/payment/domain/use_cases/check_security_status.dart';
import 'package:retail_test_task/features/payment/domain/use_cases/evaluate_confirmation.dart';
import 'package:retail_test_task/features/payment/domain/use_cases/load_payment.dart';
import 'package:retail_test_task/features/payment/domain/use_cases/observe_payment_processing.dart';
import 'package:retail_test_task/features/payment/domain/use_cases/start_payment_processing.dart';
import 'package:retail_test_task/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_page_section_mapper.dart';

final GetIt serviceLocator = GetIt.instance;

void registerDependencies(GetIt locator) {
  locator
    ..registerLazySingleton(PaymentPageSectionMapper.new)
    ..registerLazySingleton<PaymentRepository>(
      () => SimulatedPaymentRepository(payment: createPredefinedPayment()),
    )
    ..registerLazySingleton<SecurityRepository>(SimulatedSecurityRepository.new)
    ..registerLazySingleton(() => LoadPayment(locator()))
    ..registerLazySingleton(() => CheckSecurityStatus(locator()))
    ..registerLazySingleton(EvaluateConfirmation.new)
    ..registerLazySingleton(() => StartPaymentProcessing(locator()))
    ..registerLazySingleton(() => ObservePaymentProcessing(locator()))
    ..registerFactory(
      () => PaymentBloc(
        loadPayment: locator(),
        checkSecurityStatus: locator(),
        evaluateConfirmation: locator(),
        startPaymentProcessing: locator(),
        observePaymentProcessing: locator(),
      ),
    );
}
