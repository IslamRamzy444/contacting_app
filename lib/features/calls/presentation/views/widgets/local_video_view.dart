import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

class LocalVideoView extends StatelessWidget {
  final RtcEngine engine;
  final bool isCameraOn;

  const LocalVideoView({
    super.key,
    required this.engine,
    required this.isCameraOn,
  });

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;

    return ClipRRect(
      borderRadius: BorderRadius.circular(width * 0.03),
      child: Container(
        width: width * 0.3,
        height: width * 0.4,
        color: Colors.black54,
        child: isCameraOn
            ? AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: engine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              )
            : Center(
                child: Icon(
                  Icons.videocam_off,
                  color: Colors.white,
                  size: width * 0.08,
                ),
              ),
      ),
    );
  }
}
