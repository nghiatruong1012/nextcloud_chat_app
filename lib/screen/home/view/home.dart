import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextcloud_chat_app/authentication/bloc/authentication_bloc.dart';
import 'package:nextcloud_chat_app/screen/chat/view/chat.dart';
import 'package:nextcloud_chat_app/screen/home/bloc/home_bloc.dart';
import 'package:nextcloud_chat_app/service/conversation_service.dart';
import 'package:nextcloud_chat_app/service/request.dart';
import 'package:nextcloud_chat_app/utils.dart';
import 'package:nextcloud_chat_app/widgets/loading_widgets.dart';

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
    final user = context.select((AuthenticationBloc bloc) => bloc.state.user);
    return Scaffold(
      // appBar: AppBar(title: Text("Home")),
      body: SafeArea(
        child: Column(
          children: [
            Stack(alignment: FractionalOffset.centerRight, children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    hintText: 'Tìm kiếm',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: 30,
                height: 30,
                margin: EdgeInsets.only(right: 30),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: FutureBuilder(
                        future: ConversationService().getConversationAvatar(
                            '', user.username.toString(), ''),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return snapshot.data ?? Container();
                          } else {
                            return CircularProgressIndicator();
                          }
                        })),
              ),
            ]),
            BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (previous, current) =>
                  previous.listConversations != current.listConversations,
              builder: (context, state) {
                if (state.listConversations != null &&
                    state.listConversations!.isNotEmpty) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: state.listConversations!.length,
                      itemBuilder: (context, index) => ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              ChatProvider.route(
                                  state.listConversations![index].token!,
                                  state.listConversations![index].lastMessage!
                                      .id!));
                        },
                        leading: Container(
                          width: 40,
                          height: 40,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: FutureBuilder(
                                  future: ConversationService()
                                      .getConversationAvatar(
                                          state
                                              .listConversations![index].token!,
                                          state.listConversations![index].name!,
                                          state.listConversations![index]
                                              .lastMessage!.actorType!),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return snapshot.data ?? Container();
                                    } else {
                                      return CircularProgressIndicator();
                                    }
                                  })),
                        ),
                        title: Text(state.listConversations![index].displayName
                            .toString()),
                        subtitle: Text(
                          state.listConversations![index].lastMessage!.message
                              .toString(),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  );
                } else {
                  return ListLoading();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
