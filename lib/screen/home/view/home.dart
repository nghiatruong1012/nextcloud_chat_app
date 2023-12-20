import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextcloud_chat_app/authentication/bloc/authentication_bloc.dart';
import 'package:nextcloud_chat_app/screen/home/bloc/home_bloc.dart';
import 'package:nextcloud_chat_app/service/conversation_service.dart';
import 'package:nextcloud_chat_app/service/request.dart';
import 'package:nextcloud_chat_app/utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => HomePage());
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // @override
  // void initState() {
  //   // TODO: implement initState
  //   context.read<HomeBloc>().add(LoadConversationEvent());
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("Home")),
      body: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (previous, current) =>
            previous.listConversations != current.listConversations,
        builder: (context, state) {
          if (state.listConversations != null &&
              state.listConversations!.isNotEmpty) {
            return ListView.builder(
              itemCount: state.listConversations!.length,
              itemBuilder: (context, index) => ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: FutureBuilder(
                          future: ConversationService().getConversationAvatar(
                              state.listConversations![index].token!),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return snapshot.data ?? Container();
                            } else {
                              return CircularProgressIndicator();
                            }
                          })),
                ),
                title: Text(
                    state.listConversations![index].displayName.toString()),
                subtitle: Text(
                  state.listConversations![index].lastMessage!.message
                      .toString(),
                  maxLines: 1,
                ),
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
