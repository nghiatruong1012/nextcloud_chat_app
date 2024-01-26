import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:nextcloud_chat_app/service/call_service.dart';
import 'package:nextcloud_chat_app/service/request.dart';
import 'package:http/http.dart' as http;

class CallPage extends StatefulWidget {
  const CallPage({super.key, required this.token});
  final String token;

  @override
  State<CallPage> createState() => _CallPageState(token: token);
}

class _CallPageState extends State<CallPage> {
  final String token;
  MediaStream? _localStream;
  RTCPeerConnection? _peerConnection;
  RTCVideoRenderer _localRenderer = new RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();

  _CallPageState({required this.token});

  @override
  dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    CallService().joinCall({"flags": '3', "silent": false}, token);
    getSignal();
    initRenderer();
    // _createPeerConnecion().then((pc) {
    //   _peerConnection = pc;
    // });
    // _getUserMedia();
    super.initState();
  }

  initRenderer() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> getSignal() async {
    Map<String, String> requestHeaders = await HTTPService().authHeader();
    print(requestHeaders['Cookie']);
    try {
      final response = await http.get(
        Uri(
          scheme: 'http',
          host: host,
          port: 8080,
          path: '/ocs/v2.php/apps/spreed/api/v3/signaling/${token}',
        ),
        headers: requestHeaders,
        // body: jsonEncode(params ?? {}),
      );
      if (response.statusCode == 200) {
        if (jsonDecode(response.body)["ocs"]["data"][0]["type"] == "message") {
          final sdp = jsonDecode(response.body)["ocs"]["data"][0]["data"];
          print('sdp' + sdp);
          // _peerConnection!.setRemoteDescription(sdp);
        }
        getSignal();
      } else {
        print(response.statusCode);
        getSignal();
      }
    } catch (e) {
      print(e);
      getSignal();
    }
  }

  _getUserMedia() async {
    final Map<String, dynamic> constraints = {
      'audio': false,
      'video': {
        'facingMode': 'user',
      },
    };

    MediaStream stream = await navigator.mediaDevices.getUserMedia(constraints);

    setState(() {
      _localRenderer.srcObject = stream;
    });
    // _localRenderer.mirror = true;
  }

  _createPeerConnecion() async {
    Map<String, dynamic> configuration = {
      "iceServers": [
        {"url": "stun:stun.nextcloud.com:443"},
      ]
    };
    _localStream = await _getUserMedia();

    RTCPeerConnection pc = await createPeerConnection(configuration);
    pc.addStream(_localStream!);
    pc.onAddStream = (stream) {
      print('addStream: ' + stream.id);
      _remoteRenderer.srcObject = stream;
    };
    return pc;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          CallService().leaveCall({"all": true}, token);
          dispose();
          Navigator.pop(context);
        },
        child: Icon(Icons.call_end),
        backgroundColor: Colors.red,
      ),
      body: SafeArea(
        child: Container(
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                color: Colors.amber,
                child: Expanded(
                  child: RTCVideoView(_remoteRenderer),
                ),
              ),
              Container(
                height: 128 * 2,
                width: 72 * 2,
                child: Expanded(
                  child: RTCVideoView(_localRenderer),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
