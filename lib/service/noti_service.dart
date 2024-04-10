import 'dart:convert';

import 'package:nextcloud_chat_app/service/request.dart';
import 'package:http/http.dart' as http;

class NotiService {
  Future<List<dynamic>> getNoti() async {
    Map<String, String> requestHeaders = await HTTPService().authHeader();

    // Make an API request and parse the response
    // Replace 'API_ENDPOINT' with the actual API endpoint
    final response = await http.get(
      Uri(
        scheme: 'http',
        host: host,
        port: 8080,
        path: '/ocs/v2.php/apps/notifications/api/v2/notifications',
      ),
      headers: requestHeaders,
      // body: jsonEncode(params ?? {}),
    );
    if (response.statusCode == 200) {
      print(
          "notification" + jsonDecode(response.body)['ocs']['data'].toString());
      return jsonDecode(response.body)['ocs']['data'];
    } else {
      print("fail get noti");

      throw Exception('Failed to load data');
    }
  }
}
