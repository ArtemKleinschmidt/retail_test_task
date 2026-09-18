import 'package:flutter/foundation.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/view_data/bill_breakdown_item_view_data.dart';

@immutable
final class PaymentSupplementViewData {
  const PaymentSupplementViewData({
    required this.formattedTotal,
    this.billItems = const [],
  });

  final String formattedTotal;
  final List<BillBreakdownItemViewData> billItems;
}
