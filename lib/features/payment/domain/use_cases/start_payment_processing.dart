import 'package:retail_test_task/features/payment/domain/entities/payment_reference.dart';
import 'package:retail_test_task/features/payment/domain/repositories/payment_repository.dart';

final class StartPaymentProcessing {
  const StartPaymentProcessing(this._repository);

  final PaymentRepository _repository;

  Future<void> call(PaymentReference reference) =>
      _repository.startProcessing(reference);
}
