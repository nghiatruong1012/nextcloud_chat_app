import 'dart:convert';
import 'dart:io';

import 'package:nextcloud_chat_app/models/user_data.dart';
import 'package:nextcloud_chat_app/service/request.dart';
import 'package:http/http.dart' as http;

class UserService {
  Future<UserData> getUserData(String userId) async {
    Map<String, String> requestHeaders = await HTTPService().authHeader();
    try {
      final response = await http.get(
        Uri(
          scheme: 'http',
          host: host,
          port: 8080,
          path: '/ocs/v1.php/cloud/users/$userId',
        ),
        headers: requestHeaders,
        // body: jsonEncode(params ?? {}),
      );
      if (response.statusCode == 200) {
        print(response.body);
        return UserData.fromJson(jsonDecode(response.body)["ocs"]["data"]);
      } else {
        print(response.statusCode.toString());
        return UserData.empty;
      }
    } catch (e) {
      print(e);
      return UserData.empty;
    }
  }

  Future<void> putUserData(String userId, params) async {
    Map<String, String> requestHeaders = await HTTPService().authHeader();
    try {
      final response = await http.put(
        Uri(
          scheme: 'http',
          host: host,
          port: 8080,
          path: '/ocs/v1.php/cloud/users/$userId',
        ),
        headers: requestHeaders,
        body: jsonEncode(params ?? {}),
      );
      if (response.statusCode == 200) {
        print(response.body);
        return;
      } else {
        print(response.statusCode.toString());
        return;
      }
    } catch (e) {
      print(e);
      return;
    }
  }

  Future<void> changeAvatar(File file) async {
    Map<String, String> requestHeaders = await HTTPService().authHeader();
    final fileByte = await file.readAsBytes();

    try {
      final response = await http.post(
        Uri(
          scheme: 'http',
          host: host,
          port: 8080,
          path: '/avatar',
        ),
        headers: requestHeaders,
        body: fileByte,
      );
      if (response.statusCode == 200) {
        print(response.body);
        return;
      } else {
        print(response.statusCode.toString());
        return;
      }
    } catch (e) {
      print(e);
      return;
    }
  }

  Future<void> deleteAvatar() async {
    Map<String, String> requestHeaders = await HTTPService().authHeader();

    try {
      final response = await http.delete(
        Uri(
          scheme: 'http',
          host: host,
          port: 8080,
          path: '/avatar',
        ),
        headers: requestHeaders,
        // body: fileByte,
      );
      if (response.statusCode == 200) {
        print('delete avatar');
        return;
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
