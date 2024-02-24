import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:nextcloud_chat_app/service/call_service.dart';
import 'package:nextcloud_chat_app/service/request.dart';
import 'package:http/http.dart' as http;
import 'package:nextcloud_chat_app/service/signaling_service.dart';

final Map<String, dynamic> constraints = {
  'audio': true,
  'video': {
    'facingMode': 'user',
  },
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
  State<CallPage> createState() => _CallPageState(token: token, user: user);
}

class _CallPageState extends State<CallPage> {
  final String token;
  final String user;

  MediaStream? _localStream;
  RTCPeerConnection? _peerConnection;
  RTCVideoRenderer _localRenderer = new RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();
  late String localSessionId;
  late String remoteSessionId;
  late String sid;
  List<dynamic> data = [];

  _CallPageState({
    required this.token,
    required this.user,
  });

  @override
  dispose() {
    _localRenderer.srcObject = null;
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    initRenderer();
    CallService().joinCall({"flags": '7', "silent": false}, token);
    getSignal();
    _createPeerConnecion().then((pc) {
      _peerConnection = pc;
    });
    super.initState();
  }

  initRenderer() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void joinCall() async {
    sid = DateTime.now().millisecondsSinceEpoch.toString();

    RTCSessionDescription description =
        await _peerConnection!.createOffer(constraints);
    print("description: " + description.sdp.toString());
    data.add({
      "ev": "message",
      "fn": {
        "to": remoteSessionId,
        "sid": sid,
        "roomType": "video",
        "payload": {
          "type": description.type,
          "sdp": description.sdp,
          "nick": user,
        },
      },
      "sessionId": localSessionId,
    });
    _peerConnection!.setLocalDescription(description);
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
        print("signaling" + jsonDecode(response.body)["ocs"].toString());

        if (jsonDecode(response.body)["ocs"]["data"][0]["data"][0]["inCall"] !=
                0 &&
            jsonDecode(response.body)["ocs"]["data"][0]["data"][1]["inCall"] !=
                0) {
          // localSessionId = jsonDecode(response.body)["ocs"]["data"][0]["data"]
          //     [0]["sessionId"];
          // remoteSessionId = jsonDecode(response.body)["ocs"]["data"][0]["data"]
          //     [1]["sessionId"];
          if (jsonDecode(response.body)["ocs"]["data"][0]["data"][0]
                  ["userId"] ==
              user) {
            localSessionId = jsonDecode(response.body)["ocs"]["data"][0]["data"]
                [0]["sessionId"];
            remoteSessionId = jsonDecode(response.body)["ocs"]["data"][0]
                ["data"][1]["sessionId"];
          }
          print("sid" + localSessionId);
          print("sid" + remoteSessionId);
        } else {
          localSessionId = jsonDecode(response.body)["ocs"]["data"][0]["data"]
              [1]["sessionId"];
          remoteSessionId = jsonDecode(response.body)["ocs"]["data"][0]["data"]
              [0]["sessionId"];
        }

        // print("signaling" + jsonDecode(response.body)["ocs"]["data"]);
        // if (jsonDecode(response.body)["ocs"]["data"][0]["type"] == "message") {
        //   final sdp = jsonDecode(response.body)["ocs"]["data"][0]["data"];
        //   print('sdp' + sdp);
        //   final candicate = jsonDecode(response.body)["ocs"]["data"][2]["data"];
        //   print('cadicate' + candicate);
        //   _peerConnection!.setRemoteDescription(sdp);
        // }
        getSignal();
      } else {
        print(response.statusCode);
        if (response.statusCode != 404) {
          getSignal();
        }
      }
    } catch (e) {
      print(e);
      getSignal();
    }
  }

  _getUserMedia() async {
    MediaStream stream = await navigator.mediaDevices.getUserMedia(constraints);

    setState(() {
      _localRenderer.srcObject = stream;
    });
    // _localRenderer.mirror = true;
    return stream;
  }

  _createPeerConnecion() async {
    Map<String, dynamic> configuration = {
      "iceServers": [
        {"url": "stun:stun.nextcloud.com:443"},
      ]
    };
    _localStream = await _getUserMedia();

    RTCPeerConnection pc =
        await createPeerConnection(configuration, _offerAnswerConstraints);
    // pc.addStream(_localStream!);
    _localStream?.getTracks().forEach((track) {
      pc?.addTrack(track, _localStream!);
    });
    pc.onIceCandidate = (e) async {
      if (e.candidate != null) {
        // Map<String, String> requestHeaders = await HTTPService().authHeader();
        print("candidate:" + e.candidate.toString());
        data.add({
          "ev": "message",
          "fn": {
            "to": remoteSessionId,
            "sid": sid,
            "roomType": "video",
            "type": "candidate",
            "payload": {
              "candidate": {
                "candidate": e.candidate,
                "sdpMid": e.sdpMid,
                "sdpMLineIndex": e.sdpMLineIndex,
              },
            }
          },
          "sessionId": localSessionId,
        });
        // try {
        //   final response = await http.post(
        //     Uri(
        //       scheme: 'http',
        //       host: host,
        //       port: 8080,
        //       path: '/ocs/v2.php/apps/spreed/api/v3/signaling/${token}',
        //     ),
        //     headers: requestHeaders,
        //     body: jsonEncode({"messages": e.candidate}),
        //   );
        //   if (response.statusCode == 200) {
        //   } else {
        //     print(response.statusCode);
        //   }
        // } catch (e) {
        //   print(e);
        // }
      }
    };
    pc.onAddStream = (stream) {
      print('addStream: ' + stream.id);
      _remoteRenderer.srcObject = stream;
    };
    return pc;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Row(
        children: [
          FloatingActionButton(
            onPressed: () {
              joinCall();
            },
            child: Icon(Icons.call),
            backgroundColor: Colors.green,
          ),
          FloatingActionButton(
            onPressed: () {
              print("data: " + data.toString());
              Clipboard.setData(ClipboardData(
                  text: {
                "messages": data,
              }.toString()));
              SignalingService().postSignal(token, {
                "messages": data,
              });
            },
            child: Icon(Icons.call_made_outlined),
            backgroundColor: Colors.yellow,
          ),
          FloatingActionButton(
            onPressed: () {
              CallService().leaveCall({"all": true}, token);
              // dispose();
              Navigator.pop(context);
            },
            child: Icon(Icons.call_end),
            backgroundColor: Colors.red,
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
            // child: Stack(
            //   alignment: Alignment.topRight,
            //   children: [
            //     Container(
            //       child: Expanded(
            //         child: RTCVideoView(_remoteRenderer),
            //       ),
            //     ),
            //     Container(
            //       height: 128 * 2,
            //       width: 72 * 2,
            //       child: Expanded(
            //         child: RTCVideoView(_localRenderer),
            //       ),
            //     ),
            //   ],
            // ),
            ),
      ),
    );
  }
}
