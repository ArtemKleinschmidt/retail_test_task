import 'package:equatable/equatable.dart';
import 'package:retail_test_task/features/payment/domain/entities/bill_item.dart';
import 'package:retail_test_task/features/payment/domain/entities/money.dart';
import 'package:retail_test_task/features/payment/domain/entities/payment_reference.dart';

final class Payment extends Equatable {
  factory Payment({
    required PaymentReference reference,
    required String payeeName,
    required Money total,
    List<BillItem> billItems = const [],
  }) {
    final normalizedPayeeName = payeeName.trim();
    if (normalizedPayeeName.isEmpty) {
      throw ArgumentError.value(payeeName, 'payeeName', 'Must not be blank.');
    }

    return Payment._(
      reference: reference,
      payeeName: normalizedPayeeName,
      total: total,
      billItems: List.unmodifiable(billItems),
    );
  }

  const Payment._({
    required this.reference,
    required this.payeeName,
    required this.total,
    required this.billItems,
  });

  final PaymentReference reference;
  final String payeeName;
  final Money total;
  final List<BillItem> billItems;

  @override
  List<Object> get props => [reference, payeeName, total, billItems];
}
