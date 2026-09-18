import 'package:flutter/widgets.dart';
import 'package:retail_test_task/core/tenant/tenant_config.dart';

class TenantScope extends InheritedWidget {
  const TenantScope({required this.config, required super.child, super.key});

  final TenantConfig config;

  static TenantConfig of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TenantScope>();
    assert(scope != null, 'No TenantScope found in the widget tree.');
    return scope!.config;
  }

  @override
  bool updateShouldNotify(TenantScope oldWidget) {
    return config != oldWidget.config;
  }
}
