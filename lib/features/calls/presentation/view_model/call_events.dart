import 'package:contacting_app/config/entities/call_entity.dart';

sealed class CallEvents {}

class InitializeAgoraEvent extends CallEvents {}

class StartCallEvent extends CallEvents {
  final String callerId;
  final String callerName;
  final String calleeId;
  final String calleeName;
  final CallType callType;
  StartCallEvent({
    required this.callerId,
    required this.callerName,
    required this.calleeId,
    required this.calleeName,
    required this.callType,
  });
}

class AcceptCallEvent extends CallEvents {
  final String callId;
  final String channelName;
  final CallType callType;
  AcceptCallEvent({
    required this.callId,
    required this.channelName,
    required this.callType,
  });
}

class RejectCallEvent extends CallEvents {
  final String callId;
  RejectCallEvent(this.callId);
}

class EndCallEvent extends CallEvents {}

class ToggleMuteEvent extends CallEvents {}

class ToggleSpeakerEvent extends CallEvents {}

class ToggleCameraEvent extends CallEvents {}

class SwitchCameraEvent extends CallEvents {}

class GetCallHistoryEvent extends CallEvents {
  final String userId;
  GetCallHistoryEvent(this.userId);
}

class ListenToIncomingCallsEvent extends CallEvents {
  final String userId;
  ListenToIncomingCallsEvent(this.userId);
}
class DismissIncomingCallEvent extends CallEvents {}

/// Watch one specific call document while it is ringing on the callee's
/// IncomingCallScreen, so the screen can dismiss itself if the caller hangs up.
class WatchRingingCallEvent extends CallEvents {
  final String callId;
  WatchRingingCallEvent(this.callId);
}

class StopWatchingRingingCallEvent extends CallEvents {}
