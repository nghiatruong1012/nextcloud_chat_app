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
  State<CallPage> createState() => _CallPageState(token: token, user: user);
}

class _CallPageState extends State<CallPage> {
  final String token;
  final String user;
  bool inCall = false;

  MediaStream? _localStream;
  RTCPeerConnection? _peerConnection;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
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
    _remoteRenderer.srcObject = null;
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
      print("pc: $pc");
      setState(() {
        _peerConnection = pc;
      });
    });

    // Future.delayed(Duration.zero, () async {
    //   while (localSessionId == null || remoteSessionId == null) {
    //     // Đợi 1 giây trước khi kiểm tra lại
    //     await Future.delayed(Duration(seconds: 1));
    //   }

    //   // Khi cả hai biến đã có giá trị, gọi hàm joinCall()
    //   joinCall();
    // });

    super.initState();
  }

  initRenderer() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void joinCall() async {
    sid = DateTime.now().millisecondsSinceEpoch.toString();
    print(_peerConnection.toString());

    RTCSessionDescription description =
        await _peerConnection!.createOffer(constraints);

    data.add({
      "ev": "message",
      "fn": jsonEncode({
        "payload": {
          "nick": user,
          "sdp": description.sdp,
          "type": description.type,
        },
        "roomType": "video",
        // "sid": sid,
        "to": remoteSessionId,
        "type": description.type,
      }),
      "sessionId": localSessionId,
    });
    _peerConnection!.setLocalDescription(description);
    print('join call');

    // Delay before sending data
    Future.delayed(const Duration(seconds: 5), () {
      print("data: $data");
      Clipboard.setData(ClipboardData(
        text: jsonEncode({
          "messages": jsonEncode(data),
        }),
      ));
      SignalingService().postSignal(token, {
        "messages": jsonEncode(data),
      });
      print('send data');

      // Delay before turning on camera and microphone
      Future.delayed(const Duration(seconds: 5), () {
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
        print('turn on camera');
      });
    });
  }

  getSignal() async {
    Map<String, String> requestHeaders = await HTTPService().authHeader();

    try {
      final response = await http.get(
        Uri(
          scheme: 'http',
          host: host,
          port: 8080,
          path: '/ocs/v2.php/apps/spreed/api/v3/signaling/$token',
        ),
        headers: requestHeaders,
        // body: jsonEncode(params ?? {}),
      );
      if (response.statusCode == 200) {
        print("signaling${jsonDecode(response.body)["ocs"]}");

        if (jsonDecode(response.body)["ocs"]["data"][0]["type"].toString() ==
            "usersInRoom") {
          if (jsonDecode(response.body)["ocs"]["data"][0]["data"][0]
                      ["inCall"] !=
                  0 &&
              jsonDecode(response.body)["ocs"]["data"][0]["data"][1]
                      ["inCall"] !=
                  0) {
            // localSessionId = jsonDecode(response.body)["ocs"]["data"][0]["data"]
            //     [0]["sessionId"];
            // remoteSessionId = jsonDecode(response.body)["ocs"]["data"][0]["data"]
            //     [1]["sessionId"];
            if (jsonDecode(response.body)["ocs"]["data"][0]["data"][0]
                    ["userId"] ==
                user) {
              localSessionId = jsonDecode(response.body)["ocs"]["data"][0]
                  ["data"][0]["sessionId"];
              remoteSessionId = jsonDecode(response.body)["ocs"]["data"][0]
                  ["data"][1]["sessionId"];
              if (!inCall) {
                joinCall();
                inCall = true;
              }
            } else {
              localSessionId = jsonDecode(response.body)["ocs"]["data"][0]
                  ["data"][1]["sessionId"];
              remoteSessionId = jsonDecode(response.body)["ocs"]["data"][0]
                  ["data"][0]["sessionId"];
              // joinCall();
              if (!inCall) {
                joinCall();
                inCall = true;
              }
            }
            print("sid$localSessionId");
            print("sid$remoteSessionId");
          }
        } else if (jsonDecode(response.body)["ocs"]["data"][0]["type"]
                .toString() ==
            "message") {
          final sdp = jsonDecode(jsonDecode(response.body)["ocs"]["data"][0]
              ["data"])["payload"]["sdp"];
          final candicate = jsonDecode(jsonDecode(response.body)["ocs"]["data"]
              [1]["data"])["payload"]["candidate"];
          if (sdp != null) {
            _peerConnection!.setRemoteDescription(
                RTCSessionDescription(sdp.toString(), "answer"));
          }
          if (candicate != null) {
            _peerConnection!.addCandidate(RTCIceCandidate(
                candicate["candidate"],
                candicate["sdpMid"],
                candicate["sdpMLineIndex"]));
          }

          print("sdp: $sdp");

          print("candicate: $candicate");
        }

        print("signaling" + jsonDecode(response.body)["ocs"]["data"]);

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
      pc.addTrack(track, _localStream!);
    });
    pc.onIceCandidate = (e) async {
      if (e.candidate != null) {
        // Map<String, String> requestHeaders = await HTTPService().authHeader();
        print("candidate:${e.candidate}");
        data.add({
          "ev": "message",
          "fn": jsonEncode({
            "payload": {
              "candidate": {
                "candidate": e.candidate,
                "sdpMid": e.sdpMid,
                "sdpMLineIndex": e.sdpMLineIndex.toString(),
              },
            },
            "roomType": "video",
            // "sid": sid,
            "to": remoteSessionId,
            "type": "candidate",
          }),
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
      print('addStream: ${stream.id}');
      setState(() {
        _remoteRenderer.srcObject = stream;
      });
    };
    return pc;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // FloatingActionButton(
          //   onPressed: () {
          //     joinCall();
          //   },
          //   heroTag: 'join_call',
          //   child: Icon(Icons.call),
          //   backgroundColor: Colors.green,
          // ),
          // FloatingActionButton(
          //   heroTag: 'data',
          //   onPressed: () {
          //     print("data: " + data.toString());
          //     Clipboard.setData(ClipboardData(
          //         text: jsonEncode({
          //       "messages": jsonEncode(data),
          //     })));
          //     SignalingService().postSignal(token, {
          //       "messages": jsonEncode(data),
          //     });
          //   },
          //   child: Icon(Icons.call_made_outlined),
          //   backgroundColor: Colors.yellow,
          // ),
          FloatingActionButton(
            heroTag: 'camera',
            onPressed: () {
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
                  // {
                  //   "ev": "message",
                  //   "fn": jsonEncode({
                  //     "to": remoteSessionId,
                  //     "roomType": "video",
                  //     "type": "unmute",
                  //     "payload": {"name": "audio"}
                  //   }),
                  //   "sessionId": localSessionId,
                  // }
                ]),
              });
            },
            child: const Icon(Icons.camera),
          ),
          FloatingActionButton(
            heroTag: 'end',
            onPressed: () {
              CallService().leaveCall({"all": true}, token);
              dispose();
              Navigator.pop(context);
            },
            backgroundColor: Colors.red,
            child: const Icon(Icons.call_end),
          ),
          FloatingActionButton(
            heroTag: 'mic',
            onPressed: () {
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
            },
            child: const Icon(Icons.mic),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Flexible(
                child: Container(
                    key: const Key("remote"),
                    margin: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                    decoration: const BoxDecoration(color: Colors.black),
                    child: RTCVideoView(_remoteRenderer)),
              ),
              Flexible(
                child: Container(
                    key: const Key("local"),
                    width: 150,
                    height: 300,
                    margin: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                    decoration: const BoxDecoration(color: Colors.black),
                    child: RTCVideoView(_localRenderer)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
