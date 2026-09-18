import 'package:flutter/material.dart';

enum TenantId { retail, utility }

@immutable
final class TenantConfig {
  const TenantConfig({
    required this.id,
    required this.appName,
    required this.theme,
  });

  final TenantId id;
  final String appName;
  final ThemeData theme;
}
