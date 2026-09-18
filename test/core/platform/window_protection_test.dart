import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retail_test_task/core/platform/window_protection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(WindowProtection.channelName);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late WindowProtection windowProtection;

  setUp(() {
    windowProtection = WindowProtection(channel: channel);
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('sends an enabled secure-window state', () async {
    MethodCall? receivedCall;
    messenger.setMockMethodCallHandler(channel, (call) async {
      receivedCall = call;
      return null;
    });

    await windowProtection.setSecure(true);

    expect(receivedCall?.method, WindowProtection.setSecureMethod);
    expect(receivedCall?.arguments, isTrue);
  });

  test('sends a disabled secure-window state', () async {
    MethodCall? receivedCall;
    messenger.setMockMethodCallHandler(channel, (call) async {
      receivedCall = call;
      return null;
    });

    await windowProtection.setSecure(false);

    expect(receivedCall?.method, WindowProtection.setSecureMethod);
    expect(receivedCall?.arguments, isFalse);
  });

  test('propagates platform failures', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => throw PlatformException(code: 'window_protection_failed'),
    );

    await expectLater(
      windowProtection.setSecure(true),
      throwsA(isA<PlatformException>()),
    );
  });
}
