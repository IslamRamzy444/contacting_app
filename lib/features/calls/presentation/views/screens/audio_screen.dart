// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:contacting_app/config/di/di.dart';
import 'package:contacting_app/config/entities/call_entity.dart';
import 'package:contacting_app/config/entities/contact_entity.dart';
import 'package:contacting_app/core/resources/app_colors.dart';
import 'package:contacting_app/features/calls/presentation/view_model/call_events.dart';
import 'package:contacting_app/features/calls/presentation/view_model/call_states.dart';
import 'package:contacting_app/features/calls/presentation/view_model/call_view_model.dart';
import 'package:contacting_app/features/calls/presentation/views/widgets/call_control_button.dart';
import 'package:contacting_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
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
          callType: CallType.audio,
        ),
      );
    }
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    final args =ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final contact = args['contact'] as ContactEntity;
    return BlocConsumer<CallViewModel, CallStates>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.blackColor,
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(height: height * 0.08),
                CircleAvatar(
                  radius: width * 0.18,
                  backgroundColor: AppColors.primaryColor.withOpacity(0.15),
                  backgroundImage: contact.photoUrl != null
                      ? CachedNetworkImageProvider(contact.photoUrl!)
                      : null,
                  child: contact.photoUrl == null
                      ? Icon(
                          Icons.person,
                          size: width * 0.2,
                          color: AppColors.blackColor,
                        )
                      : null,
                ),
                Text(
                  contact.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.whiteColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: height * 0.01),
                Text(
                  _getStatusText(context, state),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.whiteColor.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: height * 0.02),
                if (state.isMediaFlowing)
                  Text(
                    _formatDuration(state.callDuration),
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(color: AppColors.whiteColor),
                  ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CallControlButton(
                      icon: state.isMuted ? Icons.mic_off : Icons.mic,
                      label: AppLocalizations.of(context)!.mute,
                      onPressed: () => viewModel.doIntent(ToggleMuteEvent()),
                    ),
                    CallControlButton(
                      icon: state.isSpeakerOn
                          ? Icons.volume_up
                          : Icons.volume_off,
                      label: AppLocalizations.of(context)!.speaker,
                      onPressed: () =>
                          viewModel.doIntent(ToggleSpeakerEvent()),
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
                SizedBox(height: height * 0.08),
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

  String _getStatusText(BuildContext context, CallStates state) {
    final call = state.currentCallState?.data;
    if (call == null) return AppLocalizations.of(context)!.connecting;

    // The Firestore status flips to `connected` the moment the callee taps
    // accept, but media only flows once they're actually in the channel.
    if (state.isMediaFlowing) return AppLocalizations.of(context)!.connected;

    switch (call.status) {
      case CallStatus.calling:
        return AppLocalizations.of(context)!.calling;
      case CallStatus.connected:
        return AppLocalizations.of(context)!.connected;
      case CallStatus.ended:
        return AppLocalizations.of(context)!.call_ended;
      default:
        return AppLocalizations.of(context)!.connecting;
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
