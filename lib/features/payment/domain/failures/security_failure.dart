import 'package:equatable/equatable.dart';

sealed class SecurityFailure extends Equatable implements Exception {
  const SecurityFailure(this.message);

  final String message;

  @override
  List<Object> get props => [message];

  @override
  String toString() => '$runtimeType: $message';
}

final class SecurityCheckFailure extends SecurityFailure {
  const SecurityCheckFailure(super.message);
}
