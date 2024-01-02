import 'dart:convert';

import 'package:nextcloud_chat_app/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

// const String host = '192.168.0.178';
const String host = '192.168.1.26';


class HTTPService {
  Future<Map<String, String>> authHeader() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Map<String, dynamic> userMap = jsonDecode(prefs.getString('user') ?? "{}");
    // var token = "null";
    // var domain = "null";
    String? server = prefs.getString("server");
    String? username = prefs.getString("username");
    String? password = prefs.getString("password");
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));

    Map<String, String> requestHeaders = new Map();
    requestHeaders["Accept"] = "application/json";
    requestHeaders["Content-type"] = "application/json";
    requestHeaders["OCS-APIRequest"] = "true";
    requestHeaders["Authorization"] = basicAuth;
    return requestHeaders;
  }

  Future<Map<String, String>> authImgHeader() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Map<String, dynamic> userMap = jsonDecode(prefs.getString('user') ?? "{}");
    // var token = "null";
    // var domain = "null";
    String? server = prefs.getString("server");
    String? username = prefs.getString("username");
    String? password = prefs.getString("password");
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));

    Map<String, String> requestHeaders = new Map();
    requestHeaders["OCS-APIRequest"] = "true";
    requestHeaders["Authorization"] = basicAuth;
    return requestHeaders;
  }

  // Future<Map<String, String>> uploadHeader() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   Map<String, dynamic> userMap = jsonDecode(prefs.getString('user') ?? "{}");
  //   var token = "null";
  //   var domain = "null";
  //   if (userMap["user_id"] != null && userMap["user_id"] > 0) {
  //     token = userMap["token"];
  //     domain = userMap["store"]["domain"];
  //   }
  //   Map<String, String> requestHeaders = new Map();

  //   requestHeaders["x-access-token"] = token ?? "";
  //   requestHeaders["x-shop-domain"] = domain ?? "";
  //   return requestHeaders;
  // }
}
