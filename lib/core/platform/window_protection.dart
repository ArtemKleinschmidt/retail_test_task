import 'package:flutter/services.dart';

final class WindowProtection {
  WindowProtection({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName);

  static const channelName =
      'com.example.retail_test_task/payment_window_protection';
  static const setSecureMethod = 'setSecure';

  final MethodChannel _channel;

  Future<void> setSecure(bool enabled) {
    return _channel.invokeMethod<void>(setSecureMethod, enabled);
  }
}
