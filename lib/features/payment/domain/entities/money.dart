import 'package:equatable/equatable.dart';

/// A monetary value stored in the currency's smallest denomination.
///
/// For example, `1250 USD` represents `$12.50`, while `500 JPY` represents
/// `¥500` because Japanese yen has no fractional minor unit.
final class Money extends Equatable {
  factory Money({
    required int amountInMinorUnits,
    required String currencyCode,
  }) {
    if (amountInMinorUnits < 0) {
      throw ArgumentError.value(
        amountInMinorUnits,
        'amountInMinorUnits',
        'Must not be negative.',
      );
    }
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(currencyCode)) {
      throw ArgumentError.value(
        currencyCode,
        'currencyCode',
        'Must be a three-letter uppercase currency code.',
      );
    }

    return Money._(
      amountInMinorUnits: amountInMinorUnits,
      currencyCode: currencyCode,
    );
  }

  const Money._({required this.amountInMinorUnits, required this.currencyCode});

  final int amountInMinorUnits;
  final String currencyCode;

  @override
  List<Object> get props => [amountInMinorUnits, currencyCode];
}
