import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:nextcloud_chat_app/service/call_service.dart';
import 'package:nextcloud_chat_app/service/request.dart';
import 'package:http/http.dart' as http;
import 'package:nextcloud_chat_app/service/signaling_service.dart';

final Map<String, dynamic> constraints = {
  'audio': false,
  'video': true,
};

const _offerAnswerConstraints = {
  'mandatory': {
    'OfferToReceiveAudio': true,
    'OfferToReceiveVideo': true,
  },
  'optional': [],
};

class CallPage extends StatefulWidget {
  const CallPage({super.key, required this.token, required this.user});
  final String token;
  final String user;

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  late final String token;
  late final String user;
  bool inCall = false;

  MediaStream? _localStream;
  RTCPeerConnection? _peerConnection;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  late String localSessionId;
  late String remoteSessionId;
  late String sid;
  final List<dynamic> data = [];

  @override
  void initState() {
    super.initState();
    token = widget.token;
    user = widget.user;

    _initializeRenderers();
    _initiateCall();
  }

  @override
  void dispose() {
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> _initiateCall() async {
    CallService().joinCall({"flags": '7', "silent": false}, token);
    _getSignal();
    final pc = await _createPeerConnection();
    setState(() {
      _peerConnection = pc;
    });
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    final configuration = {
      "iceServers": [
        {"url": "stun:stun.nextcloud.com:443"},
      ]
    };
    _localStream = await _getUserMedia();

    final pc =
        await createPeerConnection(configuration, _offerAnswerConstraints);
    _localStream?.getTracks().forEach((track) {
      pc.addTrack(track, _localStream!);
    });

    pc.onIceCandidate = (e) {
      if (e.candidate != null) {
        _sendCandidate(e);
      }
    };

    pc.onAddStream = (stream) {
      setState(() {
        _remoteRenderer.srcObject = stream;
      });
    };

    return pc;
  }

  Future<MediaStream> _getUserMedia() async {
    final stream = await navigator.mediaDevices.getUserMedia(constraints);
    setState(() {
      _localRenderer.srcObject = stream;
    });
    return stream;
  }

  void _sendCandidate(RTCIceCandidate candidate) {
    data.add({
      "ev": "message",
      "fn": jsonEncode({
        "payload": {
          "candidate": {
            "candidate": candidate.candidate,
            "sdpMid": candidate.sdpMid,
            "sdpMLineIndex": candidate.sdpMLineIndex.toString(),
          },
        },
        "roomType": "video",
        "to": remoteSessionId,
        "type": "candidate",
      }),
      "sessionId": localSessionId,
    });
  }

  Future<void> joinCall() async {
    sid = DateTime.now().millisecondsSinceEpoch.toString();
    final description = await _peerConnection!.createOffer(constraints);

    data.add({
      "ev": "message",
      "fn": jsonEncode({
        "payload": {
          "nick": user,
          "sdp": description.sdp,
          "type": description.type,
        },
        "roomType": "video",
        "to": remoteSessionId,
        "type": description.type,
      }),
      "sessionId": localSessionId,
    });

    await _peerConnection!.setLocalDescription(description);
    _sendJoinCallData();
  }

  void _sendJoinCallData() {
    Future.delayed(const Duration(seconds: 5), () {
      Clipboard.setData(ClipboardData(
        text: jsonEncode({
          "messages": jsonEncode(data),
        }),
      ));
      SignalingService().postSignal(token, {
        "messages": jsonEncode(data),
      });

      Future.delayed(const Duration(seconds: 5), () {
        _unmuteMedia();
      });
    });
  }

  void _unmuteMedia() {
    SignalingService().postSignal(token, {
      "messages": jsonEncode([
        {
          "ev": "message",
          "fn": jsonEncode({
            "to": remoteSessionId,
            "roomType": "video",
            "type": "unmute",
            "payload": {"name": "video"}
          }),
          "sessionId": localSessionId,
        },
        {
          "ev": "message",
          "fn": jsonEncode({
            "to": remoteSessionId,
            "roomType": "video",
            "type": "unmute",
            "payload": {"name": "audio"}
          }),
          "sessionId": localSessionId,
        }
      ]),
    });
  }

  Future<void> _getSignal() async {
    final requestHeaders = await HTTPService().authHeader();

    try {
      final response = await http.get(
        Uri(
          scheme: 'http',
          host: host,
          port: 8080,
          path: '/ocs/v2.php/apps/spreed/api/v3/signaling/$token',
        ),
        headers: requestHeaders,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body)["ocs"];
        final dataList = responseData["data"];
        final dataType = dataList[0]["type"].toString();

        if (dataType == "usersInRoom") {
          _handleUsersInRoom(dataList[0]["data"]);
        } else if (dataType == "message") {
          _handleMessage(dataList);
        }

        _getSignal();
      } else if (response.statusCode != 404) {
        _getSignal();
      }
    } catch (e) {
      _getSignal();
    }
  }

  void _handleUsersInRoom(List<dynamic> data) {
    if (data[0]["inCall"] != 0 && data[1]["inCall"] != 0) {
      if (data[0]["userId"] == user) {
        localSessionId = data[0]["sessionId"];
        remoteSessionId = data[1]["sessionId"];
      } else {
        localSessionId = data[1]["sessionId"];
        remoteSessionId = data[0]["sessionId"];
      }

      if (!inCall) {
        joinCall();
        setState(() {
          inCall = true;
        });
      }
    }
  }

  void _handleMessage(List<dynamic> data) {
    final sdp = jsonDecode(data[0]["data"])["payload"]["sdp"];
    final candidate = jsonDecode(data[1]["data"])["payload"]["candidate"];

    if (sdp != null) {
      _peerConnection!.setRemoteDescription(
          RTCSessionDescription(sdp.toString(), "answer"));
    }

    if (candidate != null) {
      _peerConnection!.addCandidate(RTCIceCandidate(candidate["candidate"],
          candidate["sdpMid"], candidate["sdpMLineIndex"]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            heroTag: 'camera',
            onPressed: _unmuteVideo,
            child: const Icon(Icons.camera),
          ),
          FloatingActionButton(
            heroTag: 'end',
            onPressed: _endCall,
            backgroundColor: Colors.red,
            child: const Icon(Icons.call_end),
          ),
          FloatingActionButton(
            heroTag: 'mic',
            onPressed: _unmuteAudio,
            child: const Icon(Icons.mic),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Flexible(
              child: Container(
                key: const Key("remote"),
                margin: const EdgeInsets.all(5.0),
                decoration: const BoxDecoration(color: Colors.black),
                child: RTCVideoView(_remoteRenderer),
              ),
            ),
            Flexible(
              child: Container(
                key: const Key("local"),
                width: 150,
                height: 300,
                margin: const EdgeInsets.all(5.0),
                decoration: const BoxDecoration(color: Colors.black),
                child: RTCVideoView(_localRenderer),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _unmuteVideo() {
    SignalingService().postSignal(token, {
      "messages": jsonEncode([
        {
          "ev": "message",
          "fn": jsonEncode({
            "to": remoteSessionId,
            "roomType": "video",
            "type": "unmute",
            "payload": {"name": "video"}
          }),
          "sessionId": localSessionId,
        }
      ]),
    });
  }

  void _unmuteAudio() {
    SignalingService().postSignal(token, {
      "messages": jsonEncode([
        {
          "ev": "message",
          "fn": jsonEncode({
            "to": remoteSessionId,
            "roomType": "video",
            "type": "unmute",
            "payload": {"name": "audio"}
          }),
          "sessionId": localSessionId,
        }
      ]),
    });
  }

  void _endCall() {
    CallService().leaveCall({"all": true}, token);
    dispose();
    Navigator.pop(context);
  }
}
