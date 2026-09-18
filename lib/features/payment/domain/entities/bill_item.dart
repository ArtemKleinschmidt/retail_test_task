import 'package:equatable/equatable.dart';
import 'package:retail_test_task/features/payment/domain/entities/money.dart';

final class BillItem extends Equatable {
  factory BillItem({required String label, required Money amount}) {
    final normalizedLabel = label.trim();
    if (normalizedLabel.isEmpty) {
      throw ArgumentError.value(label, 'label', 'Must not be blank.');
    }

    return BillItem._(label: normalizedLabel, amount: amount);
  }

  const BillItem._({required this.label, required this.amount});

  final String label;
  final Money amount;

  @override
  List<Object> get props => [label, amount];
}
