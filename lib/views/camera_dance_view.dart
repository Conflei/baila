import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../controllers/signaling_service.dart';

class CameraDanceView extends StatefulWidget {
  final String song;
  const CameraDanceView({super.key, required this.song});

  @override
  State<CameraDanceView> createState() => _CameraDanceViewState();
}

class _CameraDanceViewState extends State<CameraDanceView> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  late SignalingService signalingService;
  String roomId = 'room';
  final String userId = 'user_${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    roomId = widget.song;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      asyncInit();
    });
  }

  Future<void> asyncInit() async {
    await Future.delayed(Duration(milliseconds: 500));
    await initCameraAndSignaling();
    setState(() {});
  }

  Future<void> initCameraAndSignaling() async {
    await _localRenderer.initialize();

    final stream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {'facingMode': 'user'}
    });

    _localRenderer.srcObject = stream;

    signalingService = SignalingService(
      roomId: roomId,
      senderId: userId,
      onRemoteStream: (remoteStream) {
        setState(() {
          _remoteRenderer.srcObject = remoteStream;
        });
      },
    );

    await signalingService.initConnection(stream);

    // If you want this user to be the caller:
    await signalingService.createOffer();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: RTCVideoView(
              _localRenderer,
              mirror: true,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Currently Dancing to: ${widget.song}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
