import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retail_test_task/features/payment/data/repositories/method_channel_security_repository.dart';
import 'package:retail_test_task/features/payment/domain/entities/security_status.dart';
import 'package:retail_test_task/features/payment/domain/failures/security_failure.dart';

final class MockEventChannel extends Mock implements EventChannel {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(MethodChannelSecurityRepository.channelName);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late MockEventChannel recordingEvents;
  late MethodChannelSecurityRepository repository;

  setUp(() {
    recordingEvents = MockEventChannel();
    when(() => recordingEvents.receiveBroadcastStream())
        .thenAnswer((_) => const Stream<Object?>.empty());
    repository = MethodChannelSecurityRepository(
      channel: channel,
      recordingEvents: recordingEvents,
    );
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  group('MethodChannelSecurityRepository mapping', () {
    const cases = {
      'clear signals': (
        payload: {'root': 'clear', 'screenRecording': 'clear'},
        expected: SecurityStatus(
          root: SecuritySignalState.clear,
          screenRecording: SecuritySignalState.clear,
        ),
      ),
      'root detection': (
        payload: {'root': 'detected', 'screenRecording': 'clear'},
        expected: SecurityStatus(
          root: SecuritySignalState.detected,
          screenRecording: SecuritySignalState.clear,
        ),
      ),
      'screen-recording detection': (
        payload: {'root': 'clear', 'screenRecording': 'detected'},
        expected: SecurityStatus(
          root: SecuritySignalState.clear,
          screenRecording: SecuritySignalState.detected,
        ),
      ),
      'unsupported screen-recording detection': (
        payload: {'root': 'clear', 'screenRecording': 'unsupported'},
        expected: SecurityStatus(
          root: SecuritySignalState.clear,
          screenRecording: SecuritySignalState.unsupported,
        ),
      ),
    };

    for (final entry in cases.entries) {
      test('maps ${entry.key}', () async {
        messenger.setMockMethodCallHandler(
          channel,
          (_) async => entry.value.payload,
        );

        await expectLater(
          repository.checkStatus(),
          completion(entry.value.expected),
        );
      });
    }
  });

  group('MethodChannelSecurityRepository failures', () {
    final malformedResponses = <String, Object?>{
      'null': null,
      'a non-map value': 'clear',
      'a missing value': {'root': 'clear'},
      'an unknown value': {'root': 'trusted', 'screenRecording': 'clear'},
    };

    for (final entry in malformedResponses.entries) {
      test('maps ${entry.key} response to a typed failure', () async {
        messenger.setMockMethodCallHandler(channel, (_) async => entry.value);

        await expectLater(
          repository.checkStatus(),
          throwsA(isA<SecurityCheckFailure>()),
        );
      });
    }

    test('maps a platform error to a typed failure', () async {
      messenger.setMockMethodCallHandler(
        channel,
        (_) async => throw PlatformException(code: 'security_check_failed'),
      );

      await expectLater(
        repository.checkStatus(),
        throwsA(isA<SecurityCheckFailure>()),
      );
    });

    test('maps a missing plugin to a typed failure', () async {
      await expectLater(
        repository.checkStatus(),
        throwsA(isA<SecurityCheckFailure>()),
      );
    });
  });

  group('MethodChannelSecurityRepository recording events', () {
    test('maps dynamic recording states', () async {
      when(() => recordingEvents.receiveBroadcastStream()).thenAnswer(
        (_) => Stream<Object?>.fromIterable(const [
          'clear',
          'detected',
          'unsupported',
        ]),
      );

      await expectLater(
        repository.observeScreenRecording(),
        emitsInOrder([
          SecuritySignalState.clear,
          SecuritySignalState.detected,
          SecuritySignalState.unsupported,
          emitsDone,
        ]),
      );
    });

    test('maps malformed recording events to a typed failure', () async {
      when(() => recordingEvents.receiveBroadcastStream())
          .thenAnswer((_) => Stream<Object?>.value('unknown'));

      await expectLater(
        repository.observeScreenRecording(),
        emitsError(isA<SecurityCheckFailure>()),
      );
    });

    test('maps recording channel errors to a typed failure', () async {
      when(() => recordingEvents.receiveBroadcastStream()).thenAnswer(
        (_) => Stream<Object?>.error(
          PlatformException(code: 'recording_events_failed'),
        ),
      );

      await expectLater(
        repository.observeScreenRecording(),
        emitsError(isA<SecurityCheckFailure>()),
      );
    });
  });
}
