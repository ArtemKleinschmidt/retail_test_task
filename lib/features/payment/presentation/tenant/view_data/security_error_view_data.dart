import 'package:flutter/foundation.dart';

/// Display-ready copy for a tenant-specific security error.
@immutable
final class SecurityErrorViewData {
  const SecurityErrorViewData({required this.title, required this.message});

  final String title;
  final String message;
}
