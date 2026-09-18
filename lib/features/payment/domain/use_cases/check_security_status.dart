import 'package:retail_test_task/features/payment/domain/entities/security_status.dart';
import 'package:retail_test_task/features/payment/domain/repositories/security_repository.dart';

final class CheckSecurityStatus {
  const CheckSecurityStatus(this._repository);

  final SecurityRepository _repository;

  Future<SecurityStatus> call() => _repository.checkStatus();
}
