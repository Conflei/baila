import 'dart:convert';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignalingService {
  final String roomId;
  final String senderId;
  late final RTCPeerConnection peerConnection;
  final Function(MediaStream remoteStream) onRemoteStream;

  SignalingService({
    required this.roomId,
    required this.senderId,
    required this.onRemoteStream,
  });

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> initConnection(MediaStream localStream) async {
    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    };

    peerConnection = await createPeerConnection(config);

    peerConnection.addStream(localStream);

    peerConnection.onIceCandidate = (candidate) async {
      await sendSignal('ice', {
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
    };

    peerConnection.onAddStream = (MediaStream stream) {
      onRemoteStream(stream);
    };

    listenForSignals();
  }

  Future<void> sendSignal(String type, Map<String, dynamic> payload) async {
    await _supabase.from('signals').insert({
      'room_id': roomId,
      'sender': senderId,
      'type': type,
      'payload': payload,
    });
  }

  void listenForSignals() {
    _supabase
        .from('signals')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .listen((data) async {
          for (var signal in data) {
            if (signal['sender'] == senderId) continue;

            final type = signal['type'];
            final payload = signal['payload'];

            if (type == 'offer') {
              await peerConnection.setRemoteDescription(
                RTCSessionDescription(payload['sdp'], payload['type']),
              );
              final answer = await peerConnection.createAnswer();
              await peerConnection.setLocalDescription(answer);
              await sendSignal('answer', answer.toMap());
            }

            if (type == 'answer') {
              await peerConnection.setRemoteDescription(
                RTCSessionDescription(payload['sdp'], payload['type']),
              );
            }

            if (type == 'ice') {
              await peerConnection.addCandidate(
                RTCIceCandidate(
                  payload['candidate'],
                  payload['sdpMid'],
                  payload['sdpMLineIndex'],
                ),
              );
            }
          }
        });
  }

  Future<void> createOffer() async {
    final offer = await peerConnection.createOffer();
    await peerConnection.setLocalDescription(offer);
    await sendSignal('offer', offer.toMap());
  }

  void dispose() {
    peerConnection.dispose();
  }
}
