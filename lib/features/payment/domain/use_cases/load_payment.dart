import 'package:retail_test_task/features/payment/domain/entities/payment.dart';
import 'package:retail_test_task/features/payment/domain/repositories/payment_repository.dart';

final class LoadPayment {
  const LoadPayment(this._repository);

  final PaymentRepository _repository;

  Future<Payment> call() => _repository.loadPayment();
}
