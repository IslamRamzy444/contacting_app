import 'package:permission_handler/permission_handler.dart';

class AppPermissionHandler {
  static Future<bool> requestMicrophone() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) await openAppSettings();
    return false;
  }

  static Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) await openAppSettings();
    return false;
  }

  static Future<bool> requestAudioCallPermissions() async {
    return await requestMicrophone();
  }

  static Future<bool> requestVideoCallPermissions() async {
    final mic = await requestMicrophone();
    final cam = await requestCamera();
    return mic && cam;
  }
}