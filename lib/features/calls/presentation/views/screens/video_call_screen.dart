import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:contacting_app/config/di/di.dart';
import 'package:contacting_app/config/entities/call_entity.dart';
import 'package:contacting_app/config/entities/contact_entity.dart';
import 'package:contacting_app/core/resources/app_colors.dart';
import 'package:contacting_app/features/calls/presentation/view_model/call_events.dart';
import 'package:contacting_app/features/calls/presentation/view_model/call_states.dart';
import 'package:contacting_app/features/calls/presentation/view_model/call_view_model.dart';
import 'package:contacting_app/features/calls/presentation/views/widgets/call_control_button.dart';
import 'package:contacting_app/features/calls/presentation/views/widgets/local_video_view.dart';
import 'package:contacting_app/features/calls/presentation/views/widgets/remote_video_placeholder.dart';
import 'package:contacting_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  CallViewModel viewModel = getIt<CallViewModel>();
  bool _isInitialized = false;
  bool _hasPopped = false;
  bool _errorShown = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) return;
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final contact = args['contact'] as ContactEntity;
    final currentUserId = args['currentUserId'] as String;
    final currentUserName = args['currentUserName'] as String;
    final isIncoming = args['isIncoming'] as bool? ?? false;

    viewModel.doIntent(InitializeAgoraEvent());

    if (isIncoming) {
      // We've already accepted this call (AcceptCallEvent was fired from
      // IncomingCallScreen and the channel was already joined there).
      // Do NOT start a brand new call here — that would flip caller/callee
      // roles and create a duplicate call doc, causing an infinite loop.
    } else {
      viewModel.doIntent(
        StartCallEvent(
          callerId: currentUserId,
          callerName: currentUserName,
          calleeId: contact.id,
          calleeName: contact.name,
          callType: CallType.video,
        ),
      );
    }
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final contact = args['contact'] as ContactEntity;
    return BlocConsumer<CallViewModel, CallStates>(
      builder: (context, state) {
        final engine = viewModel.engine;
        return Scaffold(
          backgroundColor: AppColors.blackColor,
          body: SafeArea(
            child: Stack(
              children: [
                Positioned.fill(
                  child: state.remoteUid != null && engine != null
                      ? AgoraVideoView(
                          controller: VideoViewController.remote(
                            rtcEngine: engine,
                            canvas: VideoCanvas(uid: state.remoteUid),
                            connection: RtcConnection(
                              channelId:
                                  state.currentCallState?.data?.channelName ??
                                  '',
                            ),
                          ),
                        )
                      : RemoteVideoPlaceholder(
                          contactName: contact.name,
                          statusText: state.isMediaFlowing
                              ? AppLocalizations.of(context)!.connected
                              : AppLocalizations.of(context)!.calling,
                        ),
                ),
                if (engine != null)
                  Positioned(
                    top: height * 0.03,
                    right: width * 0.04,
                    child: LocalVideoView(
                      engine: engine,
                      isCameraOn: state.isCameraOn,
                    ),
                  ),
                Positioned(
                  bottom: height * 0.05,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CallControlButton(
                        icon: state.isMuted ? Icons.mic_off : Icons.mic,
                        label: AppLocalizations.of(context)!.mute,
                        onPressed: () =>
                            viewModel.doIntent(ToggleMuteEvent()),
                      ),
                      CallControlButton(
                        icon: state.isCameraOn
                            ? Icons.videocam
                            : Icons.videocam_off,
                        label: AppLocalizations.of(context)!.camera,
                        onPressed: () =>
                            viewModel.doIntent(ToggleCameraEvent()),
                      ),
                      CallControlButton(
                        icon: Icons.switch_camera,
                        label: AppLocalizations.of(context)!.switch_camera,
                        onPressed: () =>
                            viewModel.doIntent(SwitchCameraEvent()),
                      ),
                      CallControlButton(
                        icon: Icons.call_end,
                        label: AppLocalizations.of(context)!.end_call,
                        backgroundColor: AppColors.redColor,
                        onPressed: () {
                          if (_hasPopped) return;
                          _hasPopped = true;
                          viewModel.doIntent(EndCallEvent());
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      listener: (context, state) {
        final err = state.currentCallState?.errorMessage;
        if (err != null && !_errorShown) {
          _errorShown = true;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err)),
          );
        }
        if (_hasPopped) return;
        final status = state.currentCallState?.data?.status;
        final isOver =
            status == CallStatus.ended ||
            status == CallStatus.rejected ||
            status == CallStatus.missed ||
            status == CallStatus.failed;
        if (state.currentCallState?.isLoading == false && isOver) {
          _hasPopped = true;
          Navigator.pop(context);
        }
      },
    );
  }
}
