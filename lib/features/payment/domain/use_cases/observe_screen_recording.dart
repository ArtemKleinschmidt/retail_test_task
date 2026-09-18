import 'package:retail_test_task/features/payment/domain/entities/security_status.dart';
import 'package:retail_test_task/features/payment/domain/repositories/security_repository.dart';

final class ObserveScreenRecording {
  const ObserveScreenRecording(this._repository);

  final SecurityRepository _repository;

  Stream<SecuritySignalState> call() => _repository.observeScreenRecording();
}
