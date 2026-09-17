// ignore_for_file: deprecated_member_use

import 'package:contacting_app/config/entities/call_entity.dart';
import 'package:contacting_app/core/resources/app_colors.dart';
import 'package:contacting_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CallHistoryTile extends StatelessWidget {
  final CallEntity call;
  final String currentUserId;
  const CallHistoryTile({
    super.key,
    required this.call,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;

    final isOutgoing = call.callerId == currentUserId;
    final otherPartyName = isOutgoing ? call.calleeName : call.callerName;
    final isMissed =
        call.status == CallStatus.missed || call.status == CallStatus.rejected;

    return Container(
      padding: EdgeInsets.all(width * 0.03),
      decoration: BoxDecoration(
        color: AppColors.lightGreyColor,
        borderRadius: BorderRadius.circular(width * 0.03),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: width * 0.06,
            backgroundColor: isMissed
                ? AppColors.redColor.withOpacity(0.1)
                : AppColors.primaryColor.withOpacity(0.1),
            child: Icon(
              call.callType == CallType.video ? Icons.videocam : Icons.call,
              color: isMissed ? AppColors.redColor : AppColors.primaryColor,
              size: width * 0.06,
            ),
          ),
          SizedBox(width: width * 0.03),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  otherPartyName,
                  style: Theme.of(context).textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: height * 0.005),
                Row(
                  children: [
                    Icon(
                      isOutgoing ? Icons.call_made : Icons.call_received,
                      size: width * 0.035,
                      color: isMissed
                          ? AppColors.redColor
                          : AppColors.greyColor,
                    ),
                    SizedBox(width: width * 0.01),
                    Flexible(
                      child: Text(
                        '${call.callType == CallType.video ? AppLocalizations.of(context)!.video_call : AppLocalizations.of(context)!.audio_call} • ${_formatDateTime(call.startedAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isMissed)
            Text(
              call.status == CallStatus.missed
                  ? AppLocalizations.of(context)!.missed
                  : AppLocalizations.of(context)!.rejected,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.redColor),
            )
          else
            Text(
              _formatDuration(call.duration),
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final callDate = DateTime(date.year, date.month, date.day);

    final timeFormat = DateFormat('hh:mm a').format(date);

    if (callDate == today) {
      return timeFormat;
    } else if (callDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, $timeFormat';
    } else {
      return DateFormat('dd/MM/yyyy, $timeFormat').format(date);
    }
  }

  String _formatDuration(int? seconds) {
    if (seconds == null) return '00:00';
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final secs = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }
}
