import 'dart:convert';

import 'package:nextcloud_chat_app/models/list_user.dart';
import 'package:nextcloud_chat_app/service/request.dart';
import 'package:http/http.dart' as http;

class CreateConversationService {
  Future<List<UserConversation>> getListUser(params) async {
    Map<String, String> requestHeaders = await HTTPService().authHeader();
    print("param: " + params.toString());
    try {
      // print(
      //   Uri(
      //       scheme: 'http',
      //       host: host,
      //       port: 8080,
      //       path: '/ocs/v2.php/apps/spreed/api/v4/room',
      //       query: 'includeStatus=true'),
      // );

      final response = await http.get(
        Uri(
          scheme: 'http',
          host: host,
          port: 8080,
          path: '/ocs/v2.php/core/autocomplete/get',
          queryParameters: params,
        ),
        headers: requestHeaders,
        // body: jsonEncode(params ?? {}),
      );
      if (response.statusCode == 200) {
        print('Success');
        print("user-create${response.body}");
        List<dynamic> data = jsonDecode(response.body)["ocs"]["data"];
        List<UserConversation> listUser =
            data.map((item) => UserConversation.fromJson(item)).toList();
        for (var element in listUser) {
          print("useraa: " + element.label.toString());
        }
        return listUser;

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
}
