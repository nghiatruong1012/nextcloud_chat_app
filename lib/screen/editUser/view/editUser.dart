// import 'package:flutter/material.dart';
// import 'package:nextcloud_chat_app/service/conversation_service.dart';

// class EditUser extends StatefulWidget {
//   const EditUser({super.key});

//   @override
//   State<EditUser> createState() => _EditUserState();
// }

// class _EditUserState extends State<EditUser> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: SingleChildScrollView(
//         child: Expanded(
//             child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Container(
//               padding: EdgeInsets.symmetric(vertical: 30),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Center(
//                     child: SizedBox(
//                       height: 100,
//                       width: 100,
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(100),
//                         child: Builder(builder: (context) {
//                           return FutureBuilder(
//                               future: ConversationService()
//                                   .getConversationAvatar(
//                                       '', userData.id.toString(), '', 128),
//                               builder: (context, snapshot) {
//                                 if (snapshot.hasData) {
//                                   return snapshot.data ?? Icon(Icons.person);
//                                 } else {
//                                   return Icon(Icons.person);
//                                 }
//                               });
//                         }),
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   Text(
//                     userData.displayname.toString(),
//                     style: TextStyle(fontSize: 20),
//                   ),
//                 ],
//               ),
//             ),
//             (userData.displayname!.isNotEmpty)
//                 ? Container(
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
//                     child: Row(
//                       children: [
//                         Container(
//                           margin: EdgeInsets.all(10),
//                           width: 20,
//                           child: FaIcon(
//                             FontAwesomeIcons.solidUser,
//                             size: 20,
//                             color: Colors.black,
//                           ),
//                         ),
//                         SizedBox(
//                           width: 10,
//                         ),
//                         Expanded(
//                           child: TextField(
//                             readOnly: true,
//                             enabled: false,
//                             decoration: InputDecoration(
//                                 border: OutlineInputBorder(),
//                                 label: Text('Tên đầy đủ'),
//                                 hintText: userData.displayname,
//                                 floatingLabelBehavior:
//                                     FloatingLabelBehavior.always),
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : Container(),
//             (userData.phone!.isNotEmpty)
//                 ? Container(
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                     child: Row(
//                       children: [
//                         Container(
//                           margin: EdgeInsets.all(10),
//                           width: 20,
//                           child: FaIcon(FontAwesomeIcons.phone, size: 20),
//                         ),
//                         SizedBox(
//                           width: 10,
//                         ),
//                         Expanded(
//                           child: TextField(
//                             readOnly: true,
//                             enabled: false,
//                             decoration: InputDecoration(
//                                 border: OutlineInputBorder(),
//                                 label: Text('Số điện thoại'),
//                                 hintText: userData.phone,
//                                 floatingLabelBehavior:
//                                     FloatingLabelBehavior.always),
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : Container(),
//             (userData.email!.isNotEmpty)
//                 ? Container(
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                     child: Row(
//                       children: [
//                         Container(
//                           margin: EdgeInsets.all(10),
//                           width: 20,
//                           child:
//                               FaIcon(FontAwesomeIcons.solidEnvelope, size: 20),
//                         ),
//                         SizedBox(
//                           width: 10,
//                         ),
//                         Expanded(
//                           child: TextField(
//                             readOnly: true,
//                             enabled: false,
//                             decoration: InputDecoration(
//                                 border: OutlineInputBorder(),
//                                 label: Text('Email'),
//                                 hintText: userData.email,
//                                 floatingLabelBehavior:
//                                     FloatingLabelBehavior.always),
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : Container(),
//             (userData.address!.isNotEmpty)
//                 ? Container(
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                     child: Row(
//                       children: [
//                         Container(
//                           margin: EdgeInsets.all(10),
//                           width: 20,
//                           child: FaIcon(FontAwesomeIcons.locationDot, size: 20),
//                         ),
//                         SizedBox(
//                           width: 10,
//                         ),
//                         Expanded(
//                           child: TextField(
//                             readOnly: true,
//                             enabled: false,
//                             decoration: InputDecoration(
//                                 border: OutlineInputBorder(),
//                                 label: Text('Địa chỉ'),
//                                 hintText: userData.address,
//                                 floatingLabelBehavior:
//                                     FloatingLabelBehavior.always),
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : Container(),
//             (userData.website!.isNotEmpty)
//                 ? Container(
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                     child: Row(
//                       children: [
//                         Container(
//                           margin: EdgeInsets.all(10),
//                           width: 20,
//                           child: FaIcon(FontAwesomeIcons.globe, size: 20),
//                         ),
//                         SizedBox(
//                           width: 10,
//                         ),
//                         Expanded(
//                           child: TextField(
//                             readOnly: true,
//                             enabled: false,
//                             decoration: InputDecoration(
//                                 border: OutlineInputBorder(),
//                                 label: Text('Website'),
//                                 hintText: userData.website,
//                                 floatingLabelBehavior:
//                                     FloatingLabelBehavior.always),
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : Container(),
//             (userData.twitter!.isNotEmpty)
//                 ? Container(
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
//                     child: Row(
//                       children: [
//                         Container(
//                           margin: EdgeInsets.all(10),
//                           width: 20,
//                           child: FaIcon(FontAwesomeIcons.twitter, size: 20),
//                         ),
//                         SizedBox(
//                           width: 10,
//                         ),
//                         Expanded(
//                           child: TextField(
//                             readOnly: true,
//                             enabled: false,
//                             decoration: InputDecoration(
//                                 border: OutlineInputBorder(),
//                                 label: Text('Twitter'),
//                                 hintText: userData.twitter,
//                                 floatingLabelBehavior:
//                                     FloatingLabelBehavior.always),
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : Container(),
//           ],
//         )),
//       ),
//     );
//   }
// }
