import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nextcloud_chat_app/models/conversations.dart';
import 'package:nextcloud_chat_app/service/request.dart';
import 'package:http/http.dart' as http;

class ConversationService {
  Future<List<Conversations>> getUserConversations(params) async {
    Map<String, String> requestHeaders = await HTTPService().authHeader();
    try {
      print(
        Uri(
            scheme: 'http',
            host: host,
            port: 8080,
            path: '/ocs/v2.php/apps/spreed/api/v4/room',
            query: 'includeStatus=true'),
      );

      final response = await http.get(
        Uri(
            scheme: 'http',
            host: host,
            port: 8080,
            path: '/ocs/v2.php/apps/spreed/api/v4/room',
            query: 'includeStatus=true'),
        headers: requestHeaders,
        // body: jsonEncode(params ?? {}),
      );
      if (response.statusCode == 200) {
        print('Success');
        print("conversation_room" + response.body);
        List<dynamic> data = jsonDecode(response.body)["ocs"]["data"];
        List<Conversations> listConversation =
            data.map((item) => Conversations.fromJson(item)).toList();
        return listConversation;
        // return Conversations.fromJson(jsonDecode(response.body));
      } else {
        print(response.statusCode.toString());
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<Conversations> creatConversation(params) async {
    Map<String, String> requestHeaders = await HTTPService().authHeader();
    try {
      // print(
      //   Uri(
      //       scheme: 'http',
      //       host: host,
      //       port: 8080,
      //       path: '/ocs/v2.php/apps/spreed/api/v4/room',
      //       query: 'includeStatus=true'),
      // );

      final response = await http.post(
        Uri(
          scheme: 'http',
          host: host,
          port: 8080,
          path: '/ocs/v2.php/apps/spreed/api/v4/room',
        ),
        headers: requestHeaders,
        body: jsonEncode(params ?? {}),
      );
      if (response.statusCode == 200 && response.statusCode == 201) {
        print('Create Success');
        print("conversation_room" + response.body);
        // List<dynamic> data = jsonDecode(response.body)["ocs"]["data"];
        // List<Conversations> listConversation =
        //     data.map((item) => Conversations.fromJson(item)).toList();
        // return listConversation;
        return Conversations.fromJson(jsonDecode(response.body)["ocs"]["data"]);
      } else {
        print(response.statusCode.toString());
        return Conversations.empty;
      }
    } catch (e) {
      print("create error:" + e.toString());
      return Conversations.empty;
    }
  }

  Future<Image> getConversationAvatar(
      String token, String name, String actorType, int size) async {
    Map<String, String> requestHeaders = await HTTPService().authImgHeader();
    print(actorType);
    if (actorType == 'bots') {
      try {
        print(
          Uri(
            scheme: 'http',
            host: host,
            port: 8080,
            path: '/ocs/v2.php/apps/spreed/api/v1/room/$token/avatar',
          ),
        );

        final response = await http.get(
          Uri(
            scheme: 'http',
            host: host,
            port: 8080,
            path: '/ocs/v2.php/apps/spreed/api/v1/room/$token/avatar',
          ),

          headers: requestHeaders,
          // body: jsonEncode(params ?? {}),
        );
        if (response.statusCode == 200) {
          print('Success');

          // Create an Image widget from the bytes
          return Image.memory(
            response.bodyBytes,
            errorBuilder: (context, error, stackTrace) {
              return SvgPicture.memory(response.bodyBytes);
            },
          );
          // return Conversations.fromJson(jsonDecode(response.body));
        } else {
          return Image.memory(response.bodyBytes);
        }
      } catch (e) {
        print(e);
        throw Exception();
      }
    } else {
      try {
        final response = await http.get(
          Uri(
            scheme: 'http',
            host: host,
            port: 8080,
            path: '/avatar/$name/$size?v=0',
          ),

          headers: requestHeaders,
          // body: jsonEncode(params ?? {}),
        );
        if (response.statusCode == 200) {
          print('Success');

          // Create an Image widget from the bytes
          return Image.memory(
            response.bodyBytes,
            errorBuilder: (context, error, stackTrace) {
              return SvgPicture.memory(response.bodyBytes);
            },
          );
          // return Conversations.fromJson(jsonDecode(response.body));
        } else {
          return Image.memory(response.bodyBytes);
        }
      } catch (e) {
        print(e);
        throw Exception();
      }
    }
  }

  Future<void> setNotificationLevel(String token, params) async {
    Map<String, String> requestHeaders = await HTTPService().authHeader();
    try {
      final response = await http.post(
        Uri(
          scheme: 'http',
          host: host,
          port: 8080,
          path: '/ocs/v2.php/apps/spreed/api/v4/room/$token/notify',
        ),
        headers: requestHeaders,
        body: jsonEncode(params ?? {}),
      );
      if (response.statusCode == 200) {
        print('Success');
        return;
        // return Conversations.fromJson(jsonDecode(response.body));
      } else {
        print(response.statusCode.toString());
        return;
      }
    } catch (e) {
      print(e);
      return;
    }
  }

  Future<void> setCallNotificationLevel(String token, params) async {
    Map<String, String> requestHeaders = await HTTPService().authHeader();
    try {
      final response = await http.post(
        Uri(
          scheme: 'http',
          host: host,
          port: 8080,
          path: '/ocs/v2.php/apps/spreed/api/v4/room/$token/notify-calls',
        ),
        headers: requestHeaders,
        body: jsonEncode(params ?? {}),
      );
      if (response.statusCode == 200) {
        print('Success');
        return;
        // return Conversations.fromJson(jsonDecode(response.body));
      } else {
        print(response.statusCode.toString());
        return;
      }
    } catch (e) {
      print(e);
      return;
    }
  }
}
