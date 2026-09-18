import 'package:equatable/equatable.dart';

enum SecuritySignalState { clear, detected, unsupported }

enum SecurityThreat { rootedDevice, screenRecording }

final class SecurityStatus extends Equatable {
  const SecurityStatus({required this.root, required this.screenRecording});

  final SecuritySignalState root;
  final SecuritySignalState screenRecording;

  @override
  List<Object> get props => [root, screenRecording];
}
