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
            host: '192.168.1.86',
            port: 8080,
            path: '/ocs/v2.php/apps/spreed/api/v4/room',
            query: 'includeStatus=true'),
      );

      final response = await http.get(
        Uri(
            scheme: 'http',
            host: '192.168.1.86',
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

  Future<Image> getConversationAvatar(String token) async {
    Map<String, String> requestHeaders = await HTTPService().authImgHeader();
    try {
      print(
        Uri(
          scheme: 'http',
          host: '192.168.1.86',
          port: 8080,
          path: '/ocs/v2.php/apps/spreed/api/v1/room/$token/avatar',
        ),
      );

      final response = await http.get(
        Uri(
          scheme: 'http',
          host: '192.168.1.86',
          port: 8080,
          path: '/ocs/v2.php/apps/spreed/api/v1/room/$token/avatar',
        ),

        headers: requestHeaders,
        // body: jsonEncode(params ?? {}),
      );
      if (response.statusCode == 200) {
        print('Success');
        print(response.bodyBytes);
        // Create an Image widget from the bytes
        return Image.memory(
          response.bodyBytes,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            return Image.memory(response.bodyBytes);
          },
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
