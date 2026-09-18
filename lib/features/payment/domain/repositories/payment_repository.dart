import 'package:retail_test_task/features/payment/domain/entities/payment.dart';
import 'package:retail_test_task/features/payment/domain/entities/payment_processing_update.dart';
import 'package:retail_test_task/features/payment/domain/entities/payment_reference.dart';

abstract interface class PaymentRepository {
  Future<Payment> loadPayment();

  Future<void> startProcessing(PaymentReference reference);

  Stream<PaymentProcessingUpdate> observeProcessing(PaymentReference reference);
}
