// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:nextcloud_chat_app/models/user_data.dart';
import 'package:nextcloud_chat_app/service/conversation_service.dart';
import 'package:nextcloud_chat_app/service/user_service.dart';

class UserInfo extends StatefulWidget {
  UserInfo({
    Key? key,
    required this.userData,
  }) : super(key: key);
  UserData userData;

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  bool isEditing = false;

  TextEditingController displayname = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController website = TextEditingController();
  TextEditingController twitter = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    displayname.text = widget.userData.displayname!;
    phone.text = widget.userData.phone!;
    email.text = widget.userData.email!;
    address.text = widget.userData.address!;
    website.text = widget.userData.website!;
    twitter.text = widget.userData.twitter!;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        bottomOpacity: 0.0,
        elevation: 0.0,
        leading: Container(
          margin: EdgeInsets.all(0),
          padding: EdgeInsets.all(0),
          child: IconButton(
            icon: Icon(Icons.arrow_back_outlined, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: Text(
          'Personal Info',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          (isEditing)
              ? IconButton(
                  onPressed: () {
                    setState(() async {
                      if (displayname.text != widget.userData.displayname) {
                        UserService().putUserData(widget.userData.id!,
                            {"key": "displayname", "value": displayname.text});
                      }
                      if (phone.text != widget.userData.phone) {
                        UserService().putUserData(widget.userData.id!,
                            {"key": "phone", "value": phone.text});
                      }
                      if (email.text != widget.userData.email) {
                        UserService().putUserData(widget.userData.id!,
                            {"key": "email", "value": email.text});
                      }
                      if (address.text != widget.userData.address) {
                        UserService().putUserData(widget.userData.id!,
                            {"key": "address", "value": address.text});
                      }
                      if (website.text != widget.userData.website) {
                        UserService().putUserData(widget.userData.id!,
                            {"key": "website", "value": website.text});
                      }
                      if (twitter.text != widget.userData.twitter) {
                        UserService().putUserData(widget.userData.id!,
                            {"key": "twitter", "value": twitter.text});
                      }

                      widget.userData =
                          await UserService().getUserData(widget.userData.id!);
                      setState(() {
                        isEditing = false;
                      });
                    });
                  },
                  icon: Icon(
                    Icons.check,
                    color: Colors.black,
                  ),
                )
              : IconButton(
                  onPressed: () {
                    setState(() {
                      isEditing = true;
                    });
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Colors.black,
                  )),
        ],
      ),
      body: SingleChildScrollView(
        child: Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Builder(builder: (context) {
                          return FutureBuilder(
                              future: ConversationService()
                                  .getConversationAvatar('',
                                      widget.userData.id.toString(), '', 128),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return snapshot.data ?? Icon(Icons.person);
                                } else {
                                  return Icon(Icons.person);
                                }
                              });
                        }),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    widget.userData.displayname.toString(),
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            (isEditing)
                ? Container(
                    height: 50,
                    margin: EdgeInsets.only(bottom: 20),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.green.withOpacity(0.3),
                            child: IconButton(
                                onPressed: () async {
                                  FilePickerResult? result =
                                      await FilePicker.platform.pickFiles(
                                    type: FileType.image,
                                    // allowedExtensions: ['jpg', 'png'],
                                  );
                                  if (result != null) {
                                    PlatformFile file = result.files.first;
                                    File _file =
                                        File(result.files.single.path!);
                                    UserService().changeAvatar(_file);
                                    // ChatService().uploadAndSharedFile(
                                    //     user.username.toString(),
                                    //     file.path.toString(),
                                    //     file.name,
                                    //     _file,
                                    //     token,
                                    //     '');
                                    setState(() {});
                                  } else {
                                    print('error');
                                  }
                                },
                                icon: Icon(
                                  Icons.upload,
                                  color: Colors.black,
                                )),
                          ),
                          SizedBox(width: 20),
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.green.withOpacity(0.3),
                            child: IconButton(
                              onPressed: () {
                                UserService().deleteAvatar();
                                setState(() {});
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ]),
                  )
                : Container(
                    height: 70,
                  ),
            (widget.userData.displayname!.isNotEmpty || isEditing)
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Row(
                      children: [
                        Container(
                          margin: EdgeInsets.all(10),
                          width: 20,
                          child: FaIcon(
                            FontAwesomeIcons.solidUser,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextField(
                            controller: displayname,
                            enabled: isEditing,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                label: Text('Tên đầy đủ'),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
            (widget.userData.phone!.isNotEmpty || isEditing)
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          margin: EdgeInsets.all(10),
                          width: 20,
                          child: FaIcon(FontAwesomeIcons.phone, size: 20),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextField(
                            enabled: isEditing,
                            controller: phone,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                label: Text('Số điện thoại'),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
            (widget.userData.email!.isNotEmpty || isEditing)
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          margin: EdgeInsets.all(10),
                          width: 20,
                          child:
                              FaIcon(FontAwesomeIcons.solidEnvelope, size: 20),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextField(
                            controller: email,
                            enabled: isEditing,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                label: Text('Email'),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
            (widget.userData.address!.isNotEmpty || isEditing)
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          margin: EdgeInsets.all(10),
                          width: 20,
                          child: FaIcon(FontAwesomeIcons.locationDot, size: 20),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextField(
                            controller: address,
                            enabled: isEditing,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                label: Text('Địa chỉ'),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
            (widget.userData.website!.isNotEmpty || isEditing)
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          margin: EdgeInsets.all(10),
                          width: 20,
                          child: FaIcon(FontAwesomeIcons.globe, size: 20),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextField(
                            enabled: isEditing,
                            controller: website,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                label: Text('Website'),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
            (widget.userData.twitter!.isNotEmpty || isEditing)
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Row(
                      children: [
                        Container(
                          margin: EdgeInsets.all(10),
                          width: 20,
                          child: FaIcon(FontAwesomeIcons.twitter, size: 20),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextField(
                            enabled: isEditing,
                            controller: twitter,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                label: Text('Twitter'),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
          ],
        )),
      ),
    );
  }
}
