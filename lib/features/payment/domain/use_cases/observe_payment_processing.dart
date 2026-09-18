import 'package:retail_test_task/features/payment/domain/entities/payment_processing_update.dart';
import 'package:retail_test_task/features/payment/domain/entities/payment_reference.dart';
import 'package:retail_test_task/features/payment/domain/repositories/payment_repository.dart';

final class ObservePaymentProcessing {
  const ObservePaymentProcessing(this._repository);

  final PaymentRepository _repository;

  Stream<PaymentProcessingUpdate> call(PaymentReference reference) =>
      _repository.observeProcessing(reference);
}
