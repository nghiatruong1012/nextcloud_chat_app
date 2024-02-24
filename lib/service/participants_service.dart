import 'dart:convert';

import 'package:nextcloud_chat_app/models/conversations.dart';
import 'package:nextcloud_chat_app/models/participants.dart';
import 'package:nextcloud_chat_app/service/request.dart';
import 'package:http/http.dart' as http;

class ParticipantsService {
  Future<List<Participant>> getListParticipants(String token) async {
    Map<String, String> requestHeaders = await HTTPService().authHeader();
    try {
      final response = await http.get(
        Uri(
          scheme: 'http',
          host: host,
          port: 8080,
          path: '/ocs/v2.php/apps/spreed/api/v4//room/$token/participants',
        ),
        headers: requestHeaders,
        // body: jsonEncode(params ?? {}),
      );
      if (response.statusCode == 200) {
        HTTPService().updateCookie(response);
        print('Success');
        print("conversation_rooom" + response.headers.toString());
        print(response.headers.keys.toList());
        print(response.headers.values.toList());
        print(response.headers['set-cookie']);

        List<dynamic> data = jsonDecode(response.body)["ocs"]["data"];
        List<Participant> listParticipant =
            data.map((item) => Participant.fromJson(item)).toList();
        return listParticipant;
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

  Future<Conversations> joinConversation(String token) async {
    Map<String, String> requestHeaders = await HTTPService().authHeader();
    try {
      print(
        Uri(
            scheme: 'http',
            host: host,
            port: 8080,
            path:
                '/ocs/v2.php/apps/spreed/api/v4//room/$token/participants/active',
            query: 'includeStatus=true'),
      );

      final response = await http.post(
        Uri(
          scheme: 'http',
          host: host,
          port: 8080,
          path:
              '/ocs/v2.php/apps/spreed/api/v4//room/$token/participants/active',
        ),
        headers: requestHeaders,
        // body: jsonEncode(params ?? {}),
      );
      if (response.statusCode == 200) {
        HTTPService().updateCookie(response);
        print('Success');
        print("conversation_rooom" + response.headers.toString());
        print(response.headers.keys.toList());
        print(response.headers.values.toList());
        print(response.headers['set-cookie']);

        // List<dynamic> data = jsonDecode(response.body)["ocs"]["data"];
        // List<Conversations> listConversation =
        //     data.map((item) => Conversations.fromJson(item)).toList();
        return Conversations.fromJson(jsonDecode(response.body)["ocs"]["data"]);
        // return Conversations.fromJson(jsonDecode(response.body));
      } else {
        print(response.statusCode.toString());
        return Conversations.empty;
      }
    } catch (e) {
      print(e);
      return Conversations.empty;
    }
  }

  Future<void> leaveConversation(String token) async {
    Map<String, String> requestHeaders = await HTTPService().authHeader();
    try {
      final response = await http.delete(
        Uri(
          scheme: 'http',
          host: host,
          port: 8080,
          path:
              '/ocs/v2.php/apps/spreed/api/v4//room/$token/participants/active',
        ),
        headers: requestHeaders,
        // body: jsonEncode(params ?? {}),
      );
      if (response.statusCode == 200) {
        HTTPService().updateCookie(response);
        print('Success');
        print("conversation_rooom" + response.headers.toString());
        print(response.headers.keys.toList());
        print(response.headers.values.toList());
        print(response.headers['set-cookie']);

        // List<dynamic> data = jsonDecode(response.body)["ocs"]["data"];
        // List<Conversations> listConversation =
        //     data.map((item) => Conversations.fromJson(item)).toList();

        // return Conversations.fromJson(jsonDecode(response.body));
      } else {
        print(response.statusCode.toString());
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteConversation(String token) async {
    Map<String, String> requestHeaders = await HTTPService().authHeader();
    try {
      final response = await http.delete(
        Uri(
          scheme: 'http',
          host: host,
          port: 8080,
          path: '/ocs/v2.php/apps/spreed/api/v4//room/$token/participants/self',
        ),
        headers: requestHeaders,
        // body: jsonEncode(params ?? {}),
      );
      if (response.statusCode == 200) {
        HTTPService().updateCookie(response);
        print('Success');
        print("conversation_rooom" + response.headers.toString());
        print(response.headers.keys.toList());
        print(response.headers.values.toList());
        print(response.headers['set-cookie']);

        // List<dynamic> data = jsonDecode(response.body)["ocs"]["data"];
        // List<Conversations> listConversation =
        //     data.map((item) => Conversations.fromJson(item)).toList();

        // return Conversations.fromJson(jsonDecode(response.body));
      } else {
        print(response.statusCode.toString());
      }
    } catch (e) {
      print(e);
    }
  }
}
