import 'package:flutter/services.dart';
import 'package:retail_test_task/features/payment/domain/entities/security_status.dart';
import 'package:retail_test_task/features/payment/domain/failures/security_failure.dart';
import 'package:retail_test_task/features/payment/domain/repositories/security_repository.dart';

final class MethodChannelSecurityRepository implements SecurityRepository {
  MethodChannelSecurityRepository({
    MethodChannel? channel,
    EventChannel? recordingEvents,
  }) : _channel = channel ?? const MethodChannel(channelName),
       _recordingEvents =
           recordingEvents ?? const EventChannel(recordingEventsChannelName);

  static const channelName =
      'com.example.retail_test_task/security_environment';
  static const recordingEventsChannelName =
      'com.example.retail_test_task/screen_recording_events';

  static const _checkSecurityStatusMethod = 'checkSecurityStatus';
  static const _failureMessage =
      'The device security status could not be checked.';

  final MethodChannel _channel;
  final EventChannel _recordingEvents;

  @override
  Future<SecurityStatus> checkStatus() async {
    try {
      final response = await _channel.invokeMethod<Object?>(
        _checkSecurityStatusMethod,
      );
      return _decodeStatus(response);
    } on Object {
      throw const SecurityCheckFailure(_failureMessage);
    }
  }

  @override
  Stream<SecuritySignalState> observeScreenRecording() async* {
    try {
      await for (final event in _recordingEvents.receiveBroadcastStream()) {
        yield _decodeSignal(event);
      }
    } on Object {
      throw const SecurityCheckFailure(_failureMessage);
    }
  }

  static SecurityStatus _decodeStatus(Object? response) {
    if (response is! Map<Object?, Object?>) {
      throw const FormatException('Expected a security-status map.');
    }

    return SecurityStatus(
      root: _decodeSignal(response['root']),
      screenRecording: _decodeSignal(response['screenRecording']),
    );
  }

  static SecuritySignalState _decodeSignal(Object? value) {
    return switch (value) {
      'clear' => SecuritySignalState.clear,
      'detected' => SecuritySignalState.detected,
      'unsupported' => SecuritySignalState.unsupported,
      _ => throw const FormatException('Unknown security-signal value.'),
    };
  }
}
