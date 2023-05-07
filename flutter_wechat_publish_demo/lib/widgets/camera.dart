import 'package:flutter/material.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/generated/i18n.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:flutter_wechat_publish_demo/widgets/take_photo.dart';
import 'package:flutter_wechat_publish_demo/widgets/take_video.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class CameraPage extends StatelessWidget {
  // 拍照拍视频
  final CaptureMode captureMode;
  final Duration? maxVideoDuration;
  CameraPage(this.captureMode, this.maxVideoDuration, {super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CameraAwesomeBuilder.custom(
            builder: (cameraState, previewSize, previewRect) {
              return cameraState.when(
                // 拍照
                onPhotoMode: (state) {
                  return TakePhotoPage(state);
                },
                // 拍视频
                onVideoMode: (state) {
                  return TakeVideoPage(state, maxVideoDuration!);
                },
                // 拍摄中
                onVideoRecordingMode: (state) {
                  return TakeVideoPage(state, maxVideoDuration!);
                },
              );
            },
            saveConfig: captureMode == CaptureMode.photo
                ? SaveConfig.photo(pathBuilder: _buildFilePath)
                : SaveConfig.video(pathBuilder: _buildFilePath)));
  }

  // 创建文件的路径
  Future<String> _buildFilePath() async {
    // 文件夹路径
    final exDir = await getTemporaryDirectory();
    // 扩展名
    final extenName = captureMode == CaptureMode.photo ? "jpg" : "mp4";
    return '${exDir.path}/${const Uuid().v4()}.$extenName';
  }
}
