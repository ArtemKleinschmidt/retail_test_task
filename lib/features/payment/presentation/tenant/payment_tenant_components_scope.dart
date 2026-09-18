import 'package:flutter/widgets.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_tenant_components.dart';

class PaymentTenantComponentsScope extends InheritedWidget {
  const PaymentTenantComponentsScope({
    required this.components,
    required super.child,
    super.key,
  });

  final PaymentTenantComponents components;

  static PaymentTenantComponents of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<PaymentTenantComponentsScope>();
    assert(
      scope != null,
      'No PaymentTenantComponentsScope found in the widget tree.',
    );
    return scope!.components;
  }

  @override
  bool updateShouldNotify(PaymentTenantComponentsScope oldWidget) {
    return components != oldWidget.components;
  }
}
