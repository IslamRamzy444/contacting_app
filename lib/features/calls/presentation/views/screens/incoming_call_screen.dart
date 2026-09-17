// ignore_for_file: deprecated_member_use

import 'package:contacting_app/config/di/di.dart';
import 'package:contacting_app/config/entities/call_entity.dart';
import 'package:contacting_app/config/entities/contact_entity.dart';
import 'package:contacting_app/core/resources/app_colors.dart';
import 'package:contacting_app/core/routes/app_routes.dart';
import 'package:contacting_app/features/calls/presentation/view_model/call_events.dart';
import 'package:contacting_app/features/calls/presentation/view_model/call_states.dart';
import 'package:contacting_app/features/calls/presentation/view_model/call_view_model.dart';
import 'package:contacting_app/features/calls/presentation/views/widgets/call_control_button.dart';
import 'package:contacting_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IncomingCallScreen extends StatefulWidget {
  const IncomingCallScreen({super.key});

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  CallViewModel viewModel = getIt<CallViewModel>();
  bool _hasNavigated = false;
  bool _isAccepting = false;
  bool _hasDismissed = false;
  bool _isWatching = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isWatching) return;
    _isWatching = true;

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final call = args['call'] as CallEntity;
    // Watch this exact call so the screen closes itself if the caller hangs up
    // before we answer.
    viewModel.doIntent(WatchRingingCallEvent(call.id!));
  }

  @override
  void dispose() {
    viewModel.doIntent(StopWatchingRingingCallEvent());
    super.dispose();
  }

  void _dismiss(BuildContext context) {
    if (_hasDismissed || _hasNavigated) return;
    _hasDismissed = true;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final call = args['call'] as CallEntity;

    return BlocListener<CallViewModel, CallStates>(
      listenWhen: (previous, current) {
        final ringingChanged =
            previous.ringingCallState?.data?.status !=
            current.ringingCallState?.data?.status;
        final connectedNow =
            previous.currentCallState?.data?.status !=
                current.currentCallState?.data?.status &&
            current.currentCallState?.data?.status == CallStatus.connected;
        return ringingChanged || connectedNow;
      },
      listener: (context, state) {
        // The caller cancelled (missed), or the call ended some other way
        // while it was still ringing - close this screen.
        final ringing = state.ringingCallState?.data;
        if (ringing != null &&
            ringing.id == call.id &&
            ringing.status != CallStatus.calling &&
            ringing.status != CallStatus.connected) {
          _isAccepting = false;
          _dismiss(context);
          return;
        }

        // Scope this to OUR call - a stale `connected` entity left over from a
        // previous call would otherwise navigate us straight into a dead one.
        final current = state.currentCallState?.data;
        if (current == null ||
            current.id != call.id ||
            current.status != CallStatus.connected) {
          return;
        }
        if (_hasNavigated || _hasDismissed) return;
        _hasNavigated = true;

        Navigator.pushReplacementNamed(
          context,
          call.callType == CallType.video
              ? AppRoutes.videoCall
              : AppRoutes.audioCall,
          arguments: {
            'contact': ContactEntity(
              id: call.callerId,
              name: call.callerName,
              email: '',
            ),
            'currentUserId': call.calleeId,
            'currentUserName': call.calleeName,
            'isIncoming': true,
          },
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.blackColor,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: height * 0.08),
              Text(
                call.callType == CallType.video
                    ? AppLocalizations.of(context)!.incoming_video_call
                    : AppLocalizations.of(context)!.incoming_audio_call,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.whiteColor.withOpacity(0.8),
                ),
              ),
              SizedBox(height: height * 0.05),
              CircleAvatar(
                radius: width * 0.18,
                backgroundColor: AppColors.primaryColor.withOpacity(0.15),
                child: Icon(
                  Icons.person,
                  size: width * 0.2,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(height: height * 0.02),
              Text(
                call.callerName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.whiteColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: height * 0.01),
              Text(
                AppLocalizations.of(context)!.incoming_call,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.whiteColor.withOpacity(0.7),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CallControlButton(
                    icon: Icons.call_end,
                    label: AppLocalizations.of(context)!.decline,
                    backgroundColor: AppColors.redColor,
                    onPressed: () {
                      viewModel.doIntent(RejectCallEvent(call.id!));
                      _dismiss(context);
                    },
                  ),
                  CallControlButton(
                    icon: Icons.call,
                    label: AppLocalizations.of(context)!.accept,
                    backgroundColor: AppColors.greenColor,
                    onPressed: () {
                      if (_isAccepting) return;
                      _isAccepting = true;

                      viewModel.doIntent(
                        AcceptCallEvent(
                          callId: call.id!,
                          channelName: call.channelName!,
                          callType: call.callType,
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: height * 0.08),
            ],
          ),
        ),
      ),
    );
  }
}
