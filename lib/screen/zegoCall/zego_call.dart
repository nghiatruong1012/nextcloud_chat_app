// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:flutter/material.dart';
// import 'package:nextcloud_chat_app/utils.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

// class ZegoCallPage extends StatelessWidget {
//   const ZegoCallPage({
//     Key? key,
//     required this.callID,
//     required this.user,
//   }) : super(key: key);
//   final String callID;
//   final String user;

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: ZegoUIKitPrebuiltCall(
//         appID: Utils.appId,
//         appSign: Utils.appSignin,
//         callID: callID,
//         userID: user,
//         userName: user,
//         config: ZegoUIKitPrebuiltCallConfig.groupVideoCall(),
//       ),
//     );
//   }
// }
