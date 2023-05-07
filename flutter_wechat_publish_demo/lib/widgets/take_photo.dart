import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

// 拍照片的页面
class TakePhotoPage extends StatefulWidget {
  final CameraState cameraState;
  const TakePhotoPage(this.cameraState, {super.key});

  @override
  State<TakePhotoPage> createState() => _TakePhotoPageState();
}

class _TakePhotoPageState extends State<TakePhotoPage> {
  // 订阅通知
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //
    widget.cameraState.captureState$.listen((event) async {
      // 拍照成功
      if (event != null && event.status == MediaCaptureStatus.success) {
        String filePath = event.filePath;
        String fileTitle = filePath.split("/").last;
        File file = File(filePath);

        // 转换成AssetEntity
        final AssetEntity? asset = await PhotoManager.editor
            .saveImage(file.readAsBytesSync(), title: fileTitle);
        // 删除临时文件
        await file.delete();
        // 返回
        Navigator.of(context).pop<AssetEntity>(asset);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.black54,
        height: 150,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 切换摄像头
            AwesomeCameraSwitchButton(state: widget.cameraState),
            // 拍摄按钮
            AwesomeCaptureButton(state: widget.cameraState),
            // 右侧空间
            const SizedBox(width: 32 + 20 * 2)
          ],
        ),
      ),
    );
  }
}
