import 'package:contacting_app/config/base_state/base_state.dart';
import 'package:contacting_app/config/entities/call_entity.dart';

class CallStates {
  final BaseState<CallEntity>? currentCallState;
  final BaseState<List<CallEntity>>? callHistoryState;
  final BaseState<CallEntity?>? incomingCallState;

  /// The single call the IncomingCallScreen is currently ringing for, watched
  /// document-by-document so the callee sees the caller cancelling. This is
  /// deliberately separate from [currentCallState]: the callee has not joined
  /// anything yet, so it must carry no engine side effects.
  final BaseState<CallEntity>? ringingCallState;

  /// UID of the remote party, set once they actually publish into the channel.
  final int? remoteUid;
  final bool isMuted;
  final bool isSpeakerOn;
  final bool isCameraOn;
  final bool isFrontCamera;
  final Duration callDuration;

  /// True once WE have successfully joined the Agora channel.
  final bool isCallConnected;

  CallStates({
    this.currentCallState,
    this.callHistoryState,
    this.incomingCallState,
    this.ringingCallState,
    this.remoteUid,
    this.isMuted = false,
    this.isSpeakerOn = false,
    this.isCameraOn = true,
    this.isFrontCamera = true,
    this.callDuration = Duration.zero,
    this.isCallConnected = false,
  });

  /// True when both sides are in the channel and media is actually flowing.
  bool get isMediaFlowing => isCallConnected && remoteUid != null;

  CallStates copyWith({
    BaseState<CallEntity>? currentCallState,
    BaseState<List<CallEntity>>? callHistoryState,
    BaseState<CallEntity?>? incomingCallState,
    BaseState<CallEntity>? ringingCallState,
    int? remoteUid,
    bool? isMuted,
    bool? isSpeakerOn,
    bool? isCameraOn,
    bool? isFrontCamera,
    Duration? callDuration,
    bool? isCallConnected,
    // `x ?? this.x` can never write null back, so clearing needs explicit flags.
    bool clearRemoteUid = false,
    bool clearCurrentCall = false,
    bool clearRingingCall = false,
  }) {
    return CallStates(
      currentCallState: clearCurrentCall
          ? null
          : (currentCallState ?? this.currentCallState),
      callHistoryState: callHistoryState ?? this.callHistoryState,
      incomingCallState: incomingCallState ?? this.incomingCallState,
      ringingCallState: clearRingingCall
          ? null
          : (ringingCallState ?? this.ringingCallState),
      remoteUid: clearRemoteUid ? null : (remoteUid ?? this.remoteUid),
      isMuted: isMuted ?? this.isMuted,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      isCameraOn: isCameraOn ?? this.isCameraOn,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      callDuration: callDuration ?? this.callDuration,
      isCallConnected: isCallConnected ?? this.isCallConnected,
    );
  }
}
