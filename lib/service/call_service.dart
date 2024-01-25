import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nextcloud_chat_app/service/request.dart';

class CallService {
  Future<void> joinCall(params, String token) async {
    Map<String, String> requestHeaders = await HTTPService().authHeader();
    print(requestHeaders['Cookie']);
    try {
      final response = await http.post(
        Uri(
          scheme: 'http',
          host: host,
          port: 8080,
          path: '/ocs/v2.php/apps/spreed/api/v4/call/${token}',
        ),
        headers: requestHeaders,
        body: jsonEncode(params ?? {}),
      );
      if (response.statusCode == 200) {
        print('Call Success');
        // return Conversations.fromJson(jsonDecode(response.body));
      } else {
        print(response.statusCode.toString());
        // return [];
      }
    } catch (e) {
      print(e);
      // return [];
    }
  }
}
