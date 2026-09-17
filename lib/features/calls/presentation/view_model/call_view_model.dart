import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/base_state/base_state.dart';
import 'package:contacting_app/config/entities/call_entity.dart';
import 'package:contacting_app/core/permissions/app_permission_handler.dart';
import 'package:contacting_app/core/token_generation/agora_token_helper.dart';
import 'package:contacting_app/features/calls/domain/use_cases/accept_call_use_case.dart';
import 'package:contacting_app/features/calls/domain/use_cases/end_call_use_case.dart';
import 'package:contacting_app/features/calls/domain/use_cases/get_call_history_use_case.dart';
import 'package:contacting_app/features/calls/domain/use_cases/listen_to_call_status_use_case.dart';
import 'package:contacting_app/features/calls/domain/use_cases/listen_to_incoming_calls_use_case.dart';
import 'package:contacting_app/features/calls/domain/use_cases/reject_call_use_case.dart';
import 'package:contacting_app/features/calls/domain/use_cases/start_call_use_case.dart';
import 'package:contacting_app/features/calls/presentation/view_model/call_events.dart';
import 'package:contacting_app/features/calls/presentation/view_model/call_states.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@singleton
class CallViewModel extends Cubit<CallStates> {
  final StartCallUseCase _startCallUseCase;
  final AcceptCallUseCase _acceptCallUseCase;
  final RejectCallUseCase _rejectCallUseCase;
  final EndCallUseCase _endCallUseCase;
  final GetCallHistoryUseCase _getCallHistoryUseCase;
  final ListenToIncomingCallsUseCase _listenToIncomingCallsUseCase;
  final ListenToCallStatusUseCase _listenToCallStatusUseCase;

  static const _agoraAppId = '7c718c0ea11a40c2961f45445837abab';

  RtcEngine? _engine;
  StreamSubscription? _incomingCallsSubscription;
  StreamSubscription? _callHistorySubscription;
  StreamSubscription? _callStatusSubscription;
  StreamSubscription? _ringingWatchSubscription;
  Timer? _durationTimer;
  Timer? _joinWatchdog;
  bool _isAccepting = false;
  bool _isEnding = false;

  CallViewModel(
    this._startCallUseCase,
    this._acceptCallUseCase,
    this._rejectCallUseCase,
    this._endCallUseCase,
    this._getCallHistoryUseCase,
    this._listenToIncomingCallsUseCase,
    this._listenToCallStatusUseCase,
  ) : super(CallStates());

  RtcEngine? get engine => _engine;

  /// Controls are usable as soon as WE are in the channel. Gating on the
  /// Firestore status instead would leave the caller's buttons dead, because
  /// the caller's local CallEntity stays at `calling` forever.
  bool get _isCallActive => _engine != null && state.isCallConnected;

  void doIntent(CallEvents event) {
    if (isClosed) return;

    switch (event) {
      case InitializeAgoraEvent():
        _initAgora();
      case StartCallEvent():
        _startCall(event);
      case AcceptCallEvent():
        _acceptCall(event);
      case RejectCallEvent():
        _rejectCall(event);
      case EndCallEvent():
        _endCall();
      case ToggleMuteEvent():
        _toggleMute();
      case ToggleSpeakerEvent():
        _toggleSpeaker();
      case ToggleCameraEvent():
        _toggleCamera();
      case SwitchCameraEvent():
        _switchCamera();
      case GetCallHistoryEvent():
        _getCallHistory(event);
      case ListenToIncomingCallsEvent():
        _listenToIncomingCalls(event);
      case WatchRingingCallEvent():
        _watchRingingCall(event.callId);
      case StopWatchingRingingCallEvent():
        _stopWatchingRingingCall();
      case DismissIncomingCallEvent():
        emit(
          state.copyWith(
            incomingCallState: BaseState<CallEntity?>(isLoading: false),
          ),
        );
    }
  }

  Future<void> _initAgora() async {
    if (_engine != null) return;

    _engine = createAgoraRtcEngine();

    // The native SDK defaults to LIVE_BROADCASTING, where the default client
    // role is AUDIENCE. An audience member neither publishes media nor fires
    // onUserJoined on the far side, so the channel connects but stays silent.
    // A 1:1 call must run in the COMMUNICATION profile.
    await _engine!.initialize(
      RtcEngineContext(
        appId: _agoraAppId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine!.enableAudio();

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint(
            '[AGORA] joined channel=${connection.channelId} '
            'uid=${connection.localUid} elapsed=${elapsed}ms',
          );
          _joinWatchdog?.cancel();
          if (isClosed) return;
          emit(state.copyWith(isCallConnected: true));
        },
        onConnectionStateChanged:
            (
              RtcConnection connection,
              ConnectionStateType st,
              ConnectionChangedReasonType reason,
            ) {
              // This is the callback that names WHY a join never completes:
              // invalidToken / invalidAppId / invalidChannelName etc.
              debugPrint('[AGORA] connectionState=$st reason=$reason');
            },
        onRequestToken: (RtcConnection connection) {
          // Only fires when the project has an App Certificate enabled and the
          // token we passed is empty/invalid.
          debugPrint(
            '[AGORA] onRequestToken - the project REQUIRES a token, '
            'joining with an empty token will never succeed',
          );
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint('[AGORA] token privilege will expire');
        },
        onLocalAudioStateChanged:
            (
              RtcConnection connection,
              LocalAudioStreamState st,
              LocalAudioStreamReason reason,
            ) {
              debugPrint('[AGORA] localAudioState=$st reason=$reason');
            },
        onRemoteAudioStateChanged:
            (
              RtcConnection connection,
              int remoteUid,
              RemoteAudioState st,
              RemoteAudioStateReason reason,
              int elapsed,
            ) {
              debugPrint(
                '[AGORA] remoteAudioState uid=$remoteUid state=$st '
                'reason=$reason',
              );
            },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint('[AGORA] remote user joined uid=$remoteUid');
          if (isClosed) return;
          // Only now is the call genuinely two-way, so this is where the
          // duration clock should start.
          emit(state.copyWith(remoteUid: remoteUid));
          _startDurationTimer();
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              debugPrint('[AGORA] remote user offline uid=$remoteUid $reason');
              if (isClosed) return;
              _endCall();
            },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          if (isClosed) return;
          _durationTimer?.cancel();
          emit(state.copyWith(isCallConnected: false, clearRemoteUid: true));
        },
        onError: (ErrorCodeType err, String msg) {
          debugPrint('[AGORA] ERROR $err ($msg)');
          if (isClosed) return;
          emit(
            state.copyWith(
              currentCallState: BaseState<CallEntity>(
                isLoading: false,
                data: state.currentCallState?.data,
                errorMessage: 'Agora error: $msg',
              ),
            ),
          );
        },
      ),
    );
  }

  /// Options must be explicit. `const ChannelMediaOptions()` sends `{}` to the
  /// native layer, which falls back to the audience defaults described above.
  ChannelMediaOptions _mediaOptions(CallType callType) {
    final isVideo = callType == CallType.video;
    return ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
      publishMicrophoneTrack: true,
      autoSubscribeAudio: true,
      publishCameraTrack: isVideo,
      autoSubscribeVideo: isVideo,
    );
  }

  Future<void> _configureMedia(CallType callType) async {
    if (callType == CallType.video) {
      await _engine?.enableVideo();
      await _engine?.startPreview();
      await _engine?.setDefaultAudioRouteToSpeakerphone(true);
    } else {
      await _engine?.disableVideo();
      await _engine?.setDefaultAudioRouteToSpeakerphone(false);
    }
  }

  /// joinChannel returning 0 only means the request was accepted locally.
  /// If onJoinChannelSuccess never arrives, the SDK never reached Agora's
  /// servers - surface that instead of sitting on "Connecting" forever.
  void _armJoinWatchdog() {
    _joinWatchdog?.cancel();
    _joinWatchdog = Timer(const Duration(seconds: 12), () {
      if (isClosed || state.isCallConnected) return;
      debugPrint(
        '[AGORA] join did NOT complete within 12s - check the '
        'connectionState/onError lines above',
      );
      emit(
        state.copyWith(
          currentCallState: BaseState<CallEntity>(
            isLoading: false,
            data: state.currentCallState?.data,
            errorMessage:
                'Could not connect to the call server. '
                'Check your Agora App ID / token settings.',
          ),
        ),
      );
    });
  }

  Future<void> _startCall(StartCallEvent event) async {
    final hasPermissions = event.callType == CallType.video
        ? await AppPermissionHandler.requestVideoCallPermissions()
        : await AppPermissionHandler.requestAudioCallPermissions();

    if (!hasPermissions) {
      emit(
        state.copyWith(
          currentCallState: BaseState<CallEntity>(
            isLoading: false,
            errorMessage: 'Permissions denied',
          ),
        ),
      );
      return;
    }

    await _initAgora();

    try {
      await _engine?.leaveChannel();
    } catch (_) {}

    _isEnding = false;

    emit(
      state.copyWith(
        currentCallState: BaseState<CallEntity>(isLoading: true),
        callDuration: Duration.zero,
        clearRemoteUid: true,
        isSpeakerOn: event.callType == CallType.video,
        isMuted: false,
      ),
    );

    final response = await _startCallUseCase.call(
      callerId: event.callerId,
      callerName: event.callerName,
      calleeId: event.calleeId,
      calleeName: event.calleeName,
      callType: event.callType,
    );

    if (isClosed) return;

    switch (response) {
      case SuccessResponse<CallEntity>():
        final call = response.data;
        debugPrint('[AGORA] caller joining channel=${call.channelName}');

        await _configureMedia(event.callType);

        try {
          final token = AgoraTokenHelper.generate(
            channelName: call.channelName!,
            uid: 0,
          );
          debugPrint('[AGORA] caller token generated (length=${token.length})');

          await _engine?.joinChannel(
            token: token,
            channelId: call.channelName!,
            uid: 0,
            options: _mediaOptions(event.callType),
          );
          _armJoinWatchdog();
        } on AgoraRtcException catch (e) {
          debugPrint('[AGORA] joinChannel threw code=${e.code} ${e.message}');
          if (e.code != -17) rethrow;
        }

        if (isClosed) return;

        emit(
          state.copyWith(
            currentCallState: BaseState<CallEntity>(
              isLoading: false,
              data: call,
            ),
          ),
        );

        // Without this the caller never learns the callee accepted, rejected,
        // or hung up — its CallEntity would sit at `calling` forever.
        _listenToCallStatus(call.id!);

      case ErrorResponse<CallEntity>():
        emit(
          state.copyWith(
            currentCallState: BaseState<CallEntity>(
              isLoading: false,
              errorMessage: response.error.toString(),
            ),
          ),
        );
    }
  }

  Future<void> _acceptCall(AcceptCallEvent event) async {
    if (_isAccepting) return;
    _isAccepting = true;

    try {
      final hasPermissions = event.callType == CallType.video
          ? await AppPermissionHandler.requestVideoCallPermissions()
          : await AppPermissionHandler.requestAudioCallPermissions();

      if (!hasPermissions) return;

      await _initAgora();

      try {
        await _engine?.leaveChannel();
      } catch (_) {}

      _isEnding = false;

      emit(
        state.copyWith(
          currentCallState: BaseState<CallEntity>(isLoading: true),
          incomingCallState: BaseState<CallEntity?>(isLoading: false),
          callDuration: Duration.zero,
          clearRemoteUid: true,
          isSpeakerOn: event.callType == CallType.video,
          isMuted: false,
        ),
      );

      final response = await _acceptCallUseCase.call(event.callId);

      if (isClosed) return;

      switch (response) {
        case SuccessResponse<CallEntity>():
          final call = response.data;
          debugPrint(
            '[AGORA] callee joining channel=${event.channelName} '
            '(doc says ${call.channelName})',
          );

          await _configureMedia(event.callType);

          try {
            final token = AgoraTokenHelper.generate(
              channelName: event.channelName,
              uid: 0,
            );
            debugPrint(
              '[AGORA] callee token generated (length=${token.length})',
            );

            await _engine?.joinChannel(
              token: token,
              channelId: event.channelName,
              uid: 0,
              options: _mediaOptions(event.callType),
            );
            _armJoinWatchdog();
          } on AgoraRtcException catch (e) {
            debugPrint('[AGORA] joinChannel threw code=${e.code} ${e.message}');
            if (e.code != -17) rethrow;
          }

          if (isClosed) return;

          emit(
            state.copyWith(
              currentCallState: BaseState<CallEntity>(
                isLoading: false,
                data: call,
              ),
            ),
          );

          _listenToCallStatus(event.callId);

        case ErrorResponse<CallEntity>():
          emit(
            state.copyWith(
              currentCallState: BaseState<CallEntity>(
                isLoading: false,
                errorMessage: response.error.toString(),
              ),
            ),
          );
      }
    } finally {
      _isAccepting = false;
    }
  }

  /// Keeps the local CallEntity in sync with the Firestore document, so both
  /// devices observe accept / reject / end transitions.
  /// Mirrors one ringing call document into [CallStates.ringingCallState].
  ///
  /// The incoming-calls query only matches `status == calling`, so when the
  /// caller cancels it simply stops matching and emits null - which tells the
  /// callee nothing about WHICH call disappeared, and left the ringing screen
  /// on screen forever. Watching the document directly gives the screen the
  /// terminal status it needs to dismiss itself.
  void _watchRingingCall(String callId) {
    if (state.ringingCallState?.data?.id == callId) return;

    _ringingWatchSubscription?.cancel();

    final response = _listenToCallStatusUseCase.call(callId);

    switch (response) {
      case SuccessResponse<Stream<CallEntity?>>():
        _ringingWatchSubscription = response.data.listen((call) {
          if (isClosed || call == null) return;
          debugPrint('[CALL] ringing call ${call.id} status=${call.status}');
          emit(
            state.copyWith(
              ringingCallState: BaseState<CallEntity>(
                isLoading: false,
                data: call,
              ),
            ),
          );
        });
      case ErrorResponse<Stream<CallEntity?>>():
        break;
    }
  }

  void _stopWatchingRingingCall() {
    _ringingWatchSubscription?.cancel();
    _ringingWatchSubscription = null;
    if (isClosed) return;
    emit(state.copyWith(clearRingingCall: true));
  }

  void _listenToCallStatus(String callId) {
    _callStatusSubscription?.cancel();

    final response = _listenToCallStatusUseCase.call(callId);

    switch (response) {
      case SuccessResponse<Stream<CallEntity?>>():
        _callStatusSubscription = response.data.listen((call) {
          if (isClosed || call == null) return;

          emit(
            state.copyWith(
              currentCallState: BaseState<CallEntity>(
                isLoading: false,
                data: call,
              ),
            ),
          );

          final isOver =
              call.status == CallStatus.ended ||
              call.status == CallStatus.rejected ||
              call.status == CallStatus.missed ||
              call.status == CallStatus.failed;

          if (isOver) _endCall();
        });

      case ErrorResponse<Stream<CallEntity?>>():
        break;
    }
  }

  Future<void> _rejectCall(RejectCallEvent event) async {
    await _rejectCallUseCase.call(event.callId);
    if (isClosed) return;
    emit(
      state.copyWith(
        incomingCallState: BaseState<CallEntity?>(isLoading: false),
      ),
    );
  }

  Future<void> _endCall() async {
    // Our own Firestore write re-enters through _listenToCallStatus, and
    // onUserOffline can fire alongside it, so this must be idempotent.
    if (_isEnding) return;
    _isEnding = true;

    _durationTimer?.cancel();
    _joinWatchdog?.cancel();
    await _callStatusSubscription?.cancel();
    _callStatusSubscription = null;

    final currentCall = state.currentCallState?.data;
    if (currentCall?.id != null && currentCall!.status != CallStatus.ended) {
      await _endCallUseCase.call(
        callId: currentCall.id!,
        duration: state.callDuration.inSeconds,
      );
    }

    try {
      await _engine?.leaveChannel();
      await _engine?.stopPreview();
    } catch (_) {}

    if (isClosed) return;

    emit(
      state.copyWith(
        isCallConnected: false,
        clearRemoteUid: true,
        callDuration: Duration.zero,
        currentCallState: BaseState<CallEntity>(
          isLoading: false,
          data: currentCall?.copyWith(status: CallStatus.ended),
        ),
      ),
    );
  }

  void _toggleMute() {
    if (!_isCallActive) return;
    final newValue = !state.isMuted;
    _engine?.muteLocalAudioStream(newValue);
    emit(state.copyWith(isMuted: newValue));
  }

  void _toggleSpeaker() {
    if (!_isCallActive) return;
    final newValue = !state.isSpeakerOn;
    try {
      _engine?.setEnableSpeakerphone(newValue);
      emit(state.copyWith(isSpeakerOn: newValue));
    } catch (_) {}
  }

  void _toggleCamera() {
    if (!_isCallActive) return;
    final newValue = !state.isCameraOn;
    _engine?.enableLocalVideo(newValue);
    emit(state.copyWith(isCameraOn: newValue));
  }

  void _switchCamera() {
    if (!_isCallActive) return;
    _engine?.switchCamera();
    emit(state.copyWith(isFrontCamera: !state.isFrontCamera));
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          callDuration: state.callDuration + const Duration(seconds: 1),
        ),
      );
    });
  }

  void _getCallHistory(GetCallHistoryEvent event) {
    _callHistorySubscription?.cancel();

    emit(
      state.copyWith(
        callHistoryState: BaseState<List<CallEntity>>(isLoading: true),
      ),
    );

    final response = _getCallHistoryUseCase.call(event.userId);

    switch (response) {
      case SuccessResponse<Stream<List<CallEntity>>>():
        _callHistorySubscription = response.data.listen(
          (calls) {
            if (isClosed) return;
            emit(
              state.copyWith(
                callHistoryState: BaseState<List<CallEntity>>(
                  isLoading: false,
                  data: calls,
                ),
              ),
            );
          },
          onError: (error) {
            if (isClosed) return;
            emit(
              state.copyWith(
                callHistoryState: BaseState<List<CallEntity>>(
                  isLoading: false,
                  errorMessage: error.toString(),
                ),
              ),
            );
          },
        );

      case ErrorResponse<Stream<List<CallEntity>>>():
        emit(
          state.copyWith(
            callHistoryState: BaseState<List<CallEntity>>(
              isLoading: false,
              errorMessage: response.error.toString(),
            ),
          ),
        );
    }
  }

  void _listenToIncomingCalls(ListenToIncomingCallsEvent event) {
    _incomingCallsSubscription?.cancel();

    final response = _listenToIncomingCallsUseCase.call(event.userId);

    switch (response) {
      case SuccessResponse<Stream<CallEntity?>>():
        _incomingCallsSubscription = response.data.listen(
          (call) {
            if (isClosed) return;
            emit(
              state.copyWith(
                incomingCallState: BaseState<CallEntity?>(
                  isLoading: false,
                  data: call,
                ),
              ),
            );
          },
          onError: (error) {
            if (isClosed) return;
            emit(
              state.copyWith(
                incomingCallState: BaseState<CallEntity?>(
                  isLoading: false,
                  errorMessage: error.toString(),
                ),
              ),
            );
          },
        );
      case ErrorResponse<Stream<CallEntity?>>():
        emit(
          state.copyWith(
            incomingCallState: BaseState<CallEntity?>(
              isLoading: false,
              errorMessage: response.error.toString(),
            ),
          ),
        );
    }
  }

  @override
  Future<void> close() async {
    _durationTimer?.cancel();
    _joinWatchdog?.cancel();
    _incomingCallsSubscription?.cancel();
    _callHistorySubscription?.cancel();
    _callStatusSubscription?.cancel();
    _ringingWatchSubscription?.cancel();
    try {
      await _engine?.leaveChannel();
      await _engine?.release();
    } catch (_) {}
    return super.close();
  }
}
