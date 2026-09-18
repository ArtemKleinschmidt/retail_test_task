import 'package:flutter/material.dart';
import 'package:retail_test_task/features/payment/presentation/bloc/payment_bloc.dart';

abstract class PaymentPageSection extends StatelessWidget {
  const PaymentPageSection({super.key});

  bool isVisible(PaymentContentState state) => true;
}

class PaymentPageSectionScope extends InheritedWidget {
  const PaymentPageSectionScope({
    required this.state,
    required super.child,
    super.key,
  });

  final PaymentContentState state;

  static PaymentPageSectionScope of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<PaymentPageSectionScope>();
    assert(scope != null, 'No PaymentPageSectionScope found in the tree.');
    return scope!;
  }

  @override
  bool updateShouldNotify(PaymentPageSectionScope oldWidget) {
    return state != oldWidget.state;
  }
}
