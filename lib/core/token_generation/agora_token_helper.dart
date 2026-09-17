import 'package:agora_token_generator/agora_token_generator.dart';

class AgoraTokenHelper {
  static const String appId = '7c718c0ea11a40c2961f45445837abab';
  static const String appCertificate = '7644991e9bd64a5ba7e08d162b046aba';

  static String generate({
    required String channelName,
    required int uid,
    int expirationInSeconds = 3600,
  }) {
    return RtcTokenBuilder.buildTokenWithUid(
      appId: appId,
      appCertificate: appCertificate,
      channelName: channelName,
      uid: uid,
      tokenExpireSeconds: expirationInSeconds,
    );
  }
}