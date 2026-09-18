import 'package:retail_test_task/features/payment/domain/entities/security_status.dart';

abstract interface class SecurityRepository {
  Future<SecurityStatus> checkStatus();
}
