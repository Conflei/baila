import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class LocalVideoView extends StatefulWidget {
  const LocalVideoView({super.key});

  @override
  State<LocalVideoView> createState() => _LocalVideoViewState();
}

class _LocalVideoViewState extends State<LocalVideoView> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    initRenderer();
  }

  Future<void> initRenderer() async {
    await _localRenderer.initialize();

    final mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
        'width': 640,
        'height': 480,
        'frameRate': 30,
      }
    };

    MediaStream stream =
        await navigator.mediaDevices.getUserMedia(mediaConstraints);
    _localRenderer.srcObject = stream;
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RTCVideoView(_localRenderer, mirror: true);
  }
}
