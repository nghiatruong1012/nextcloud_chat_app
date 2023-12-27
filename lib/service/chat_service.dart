import 'dart:convert';
import 'dart:io';

import 'package:nextcloud_chat_app/models/chats.dart';
import 'package:nextcloud_chat_app/service/request.dart';
import 'package:http/http.dart' as http;

class ChatService {
  Future<List<Chat>> getChatContext(String token, int messageId) async {
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
            path:
                '/ocs/v2.php/apps/spreed/api/v1/chat/$token/$messageId/context',
            query: 'limit=50'),
        headers: requestHeaders,
        // body: jsonEncode(params ?? {}),
      );
      if (response.statusCode == 200) {
        print('Success');
        print("conversation_room" + response.body);
        List<dynamic> data = jsonDecode(response.body)["ocs"]["data"];
        List<Chat> listChat = data.map((item) => Chat.fromJson(item)).toList();
        return listChat;
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

  Future<http.Response> receiveMessage(String token, params) async {
    Map<String, String> requestHeaders = await HTTPService().authHeader();

    print("receive");
    print(
      Uri(
          scheme: 'http',
          host: host,
          port: 8080,
          path: '/ocs/v2.php/apps/spreed/api/v1/chat/$token',
          queryParameters: params),
    );

    final response = await http.get(
      Uri(
          scheme: 'http',
          host: host,
          port: 8080,
          path: '/ocs/v2.php/apps/spreed/api/v1/chat/$token',
          queryParameters: params),
      headers: requestHeaders,
      // body: jsonEncode(params ?? {}),
    );
    return response;
    // if (response.statusCode == 200) {
    //   print('Success');
    //   print("conversation_room" + response.body);
    //   List<dynamic> data = jsonDecode(response.body)["ocs"]["data"];
    //   List<Chat> listChat = data.map((item) => Chat.fromJson(item)).toList();
    //   return listChat;
    //   // return Conversations.fromJson(jsonDecode(response.body));
    // } else {
    //   print("receive" + response.statusCode.toString());
    //   return [];
    // }
  }

  Future<http.Response> sendMessage(String token, params) async {
    Map<String, String> requestHeaders = await HTTPService().authHeader();

    print("receive");
    print(
      Uri(
          scheme: 'http',
          host: host,
          port: 8080,
          path: '/ocs/v2.php/apps/spreed/api/v1/chat/$token',
          queryParameters: params),
    );

    final response = await http.post(
      Uri(
        scheme: 'http',
        host: host,
        port: 8080,
        path: '/ocs/v2.php/apps/spreed/api/v1/chat/$token',
      ),
      headers: requestHeaders,
      body: jsonEncode(params ?? {}),
    );
    return response;
    // if (response.statusCode == 200) {
    //   print('Success');
    //   print("conversation_room" + response.body);
    //   List<dynamic> data = jsonDecode(response.body)["ocs"]["data"];
    //   List<Chat> listChat = data.map((item) => Chat.fromJson(item)).toList();
    //   return listChat;
    //   // return Conversations.fromJson(jsonDecode(response.body));
    // } else {
    //   print("receive" + response.statusCode.toString());
    //   return [];
    // }
  }
}
