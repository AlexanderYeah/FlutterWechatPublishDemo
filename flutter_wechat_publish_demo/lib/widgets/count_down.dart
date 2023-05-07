import 'dart:async';

import 'package:flutter/material.dart';

class CountDown extends StatefulWidget {
  final Duration time;
  final Function callback;

  const CountDown(this.time, this.callback, {super.key});

  @override
  State<CountDown> createState() => _CountDownState();
}

class _CountDownState extends State<CountDown> {
  Duration _currentTime = Duration.zero;
  Timer? _timer;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentTime = widget.time;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newTime = _currentTime - const Duration(seconds: 1);
      // 如果为0的话 证明视频录制结束了
      if (newTime == Duration.zero) {
        // 回调通知 并且取消定时器
        widget.callback();
        _timer!.cancel();
      } else {
        setState(() {
          _currentTime = newTime;
        });
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      "${_currentTime.inSeconds}s",
      style: const TextStyle(color: Colors.white, fontSize: 30),
    );
  }
}
