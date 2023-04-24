import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class PublishPage extends StatefulWidget {
  const PublishPage({super.key});

  @override
  State<PublishPage> createState() => _PublishPageState();
}

class _PublishPageState extends State<PublishPage> {
  // 是否开始拖拽
  bool _isDragNow = false;
  bool _isWillDelete = false;

  // 已选中的图片列表
  List<AssetEntity> _selectedAssets = [];
  int _maxAssets = 9;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("发布"),
      ),
      body: Column(
        children: [
          _buildPhotoList2(),
        ],
      ),
      bottomSheet: _isDragNow ? _buildDeleteArea() : null,
    );
  }

  // 创建图片列表
  _buildPhotoList() {
    // 计算高度 向上取整
    double itemWith = (MediaQuery.of(context).size.width - 40 - 24) / 3;
    int rows = ((_selectedAssets.length + 1) / 3).ceil();
    print(itemWith);
    double totalHeight = rows * itemWith + 12 * (rows + 1);
    print(totalHeight);
    return Container(
      width: MediaQuery.of(context).size.width,
      height: totalHeight.floorToDouble(),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: GridView.builder(
        physics: new NeverScrollableScrollPhysics(),
        itemCount: _maxAssets > _selectedAssets.length
            ? 1
            : 0 + _selectedAssets.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10),
        itemBuilder: (context, index) {
          if (index < _selectedAssets.length) {
            return Container(
              color: Colors.red,
            );
          } else {
            return _bulidAddButton(100);
          }
        },
      ),
    );
  }

  // 创建图片列表（响应式布局）
  _buildPhotoList2() {
    //
    return Padding(
      padding: EdgeInsets.all(8),
      child: LayoutBuilder(
        builder: (BuildContext ctx, BoxConstraints constraints) {
          final double width = (constraints.maxWidth - 8 * 2) / 3;
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // 图片
              for (final asset in _selectedAssets)
                _buildPhotoItem(asset, width),
              // 按钮
              if (_maxAssets > _selectedAssets.length) _bulidAddButton(width)
            ],
          );
        },
      ),
    );
  }

  // 相片item
  _buildPhotoItem(AssetEntity asset, double width) {
    return Draggable(
        // 可拖动的对象将拖放的数据
        data: asset,
        child: Container(
          child: AssetEntityImage(
            asset,
            width: width,
            height: width,
            fit: BoxFit.cover,
            isOriginal: false,
          ),
        ),
        // 开始拖动的时候调用
        onDragStarted: () {
          setState(() {
            _isDragNow = true;
          });
        },
        // 当Draggable 被放置时候调用
        onDragEnd: (details) {
          _isDragNow = false;
        },
        // 当Draggable 被放置但未被DragTarget 接收时候调用
        onDraggableCanceled: (velocity, offset) {
          // print("object");
          setState(() {
            _isDragNow = false;
          });
        },

        // 正在进行一个或者多个显示的小部件而不是child,替代原来的小部件显示
        childWhenDragging: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(3)),
          child: AssetEntityImage(
            asset,
            width: width,
            height: width,
            fit: BoxFit.cover,
            isOriginal: false,
            opacity: const AlwaysStoppedAnimation(0.3),
          ),
        ),

        // 拖动的时候显示的指针下方的小部件
        feedback: Container(
          color: Colors.redAccent,
          height: width,
          width: width,
          child: AssetEntityImage(
            asset,
            width: width,
            height: width,
            isOriginal: false,
            fit: BoxFit.cover,
          ),
        ));
  }

  // 删除栏
  // 拖动的目标区域
  Widget _buildDeleteArea() {
    return DragTarget<AssetEntity>(
      onWillAccept: (data) {
        setState(() {
          _isWillDelete = true;
        });
        return true;
      },
      // 当被拖动的到该目标上的给定数据放置时候调用
      onAccept: (data) {
        // 删除数据
        _selectedAssets.remove(data);
        setState(() {
          _isWillDelete = false;
        });
      },
      // 被推动到该目标的上的数据离开时候调用
      onLeave: (data) {
        setState(() {
          _isWillDelete = false;
        });
      },
      builder: (context, candidateData, rejectedData) {
        return SizedBox(
          width: double.infinity,
          child: Container(
            color: _isWillDelete ? Colors.red[300] : Colors.red[200],
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 图标
                Icon(
                  Icons.delete,
                  color: _isWillDelete ? Colors.white : Colors.white70,
                  size: 32,
                ),
                // 文字
                Text(
                  "拖到这里删除",
                  style: TextStyle(
                      color: _isWillDelete ? Colors.white : Colors.white70),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // 添加相册按钮
  _bulidAddButton(double width) {
    return GestureDetector(
      onTap: () async {
        final List<AssetEntity>? result = await AssetPicker.pickAssets(context,
            pickerConfig: AssetPickerConfig(
                selectedAssets: _selectedAssets, maxAssets: _maxAssets));
        //
        setState(() {
          _selectedAssets = result ?? [];
        });
      },
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.black45)),
        width: width,
        height: width,
        child: Icon(
          Icons.add,
          size: 70,
        ),
      ),
    );
  }
}

//Draggable 可拖拽组件

// data	属性	拖放的数据
// feedback	属性	拖动进行时显示在指针下方的小部件
// childWhenDragging	属性	当正在拖动时占位组件
// child	属性	子组件
// onDragStarted	事件	开始被拖动时
// onDragEnd	事件	拖动对象被放下时
// onDragCompleted	事件	被放置并被 [DragTarget] 接受时调用
// onDraggableCanceled	事件	被放置但未被 [DragTarget] 接受时调用


// DragTarget 接收拖拽事件组件
// builder	属性	构建组件内容
// onWillAccept	事件	是否接收拖拽对象
// onAccept	事件	拖拽对象被接收
// onLeave	事件	拖拽对象离开时