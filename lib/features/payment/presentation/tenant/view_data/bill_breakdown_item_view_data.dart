import 'package:flutter/foundation.dart';

/// A display-ready line in a utility bill breakdown.
@immutable
final class BillBreakdownItemViewData {
  const BillBreakdownItemViewData({
    required this.label,
    required this.formattedAmount,
  });

  final String label;
  final String formattedAmount;
}
