import 'package:equatable/equatable.dart';

final class PaymentReference extends Equatable {
  factory PaymentReference(String value) {
    final normalizedValue = value.trim();
    if (normalizedValue.isEmpty) {
      throw ArgumentError.value(value, 'value', 'Must not be blank.');
    }

    return PaymentReference._(normalizedValue);
  }

  const PaymentReference._(this.value);

  final String value;

  @override
  List<Object> get props => [value];
}
