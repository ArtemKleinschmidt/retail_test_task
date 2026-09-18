import 'package:equatable/equatable.dart';
import 'package:retail_test_task/features/payment/domain/entities/security_status.dart';

final class ConfirmationDecision extends Equatable {
  const ConfirmationDecision.allowed() : blockingThreats = const [];

  factory ConfirmationDecision.blocked(Iterable<SecurityThreat> threats) {
    final blockingThreats = List<SecurityThreat>.unmodifiable(threats);
    if (blockingThreats.isEmpty) {
      throw ArgumentError.value(
        threats,
        'threats',
        'A blocked decision requires at least one threat.',
      );
    }

    return ConfirmationDecision._(blockingThreats);
  }

  const ConfirmationDecision._(this.blockingThreats);

  final List<SecurityThreat> blockingThreats;

  bool get isAllowed => blockingThreats.isEmpty;

  @override
  List<Object> get props => [blockingThreats];
}
