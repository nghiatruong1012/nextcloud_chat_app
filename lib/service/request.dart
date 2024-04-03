import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// const String host = '192.168.0.178';
const String host = '192.168.1.27';
// const String host = '192.168.43.165';

class HTTPService {
  // String? cookie;
  Future<Map<String, String>> authHeader() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Map<String, dynamic> userMap = jsonDecode(prefs.getString('user') ?? "{}");
    // var token = "null";
    // var domain = "null";
    String? server = prefs.getString("server");
    String? username = prefs.getString("username");
    String? password = prefs.getString("password");
    String? cookie = prefs.getString("cookie");

    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    Map<String, String> requestHeaders = {};

    requestHeaders["Accept"] = "application/json";
    requestHeaders["Content-type"] = "application/json";
    requestHeaders["OCS-APIRequest"] = "true";
    if (cookie != null) {
      requestHeaders["Cookie"] = cookie;
    }
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
    String? cookie = prefs.getString("cookie");
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    Map<String, String> requestHeaders = {};
    if (cookie != null) {
      requestHeaders["Cookie"] = cookie;
    }
    requestHeaders["OCS-APIRequest"] = "true";
    requestHeaders["Authorization"] = basicAuth;
    return requestHeaders;
  }

  Future<void> updateCookie(http.Response response) async {
    String? allSetCookie = response.headers['set-cookie'];
    Map<String, String> mapCookies = {};
    String stringCookie = "";

    if (allSetCookie != null) {
      var setCookies = allSetCookie.split(',');

      for (var setCookie in setCookies) {
        var cookies = setCookie.split(';');

        for (var cookie in cookies) {
          if (cookie.isNotEmpty) {
            var keyValue = cookie.split('=');
            if (keyValue.length == 2) {
              var key = keyValue[0].trim();
              var value = keyValue[1];

              // ignore keys that aren't cookies
              if (key == 'path' || key == 'expires') continue;

              mapCookies[key] = value;
            }
          }
        }
      }

      stringCookie = mapCookies.entries
          .map((entry) => '${entry.key}=${entry.value}')
          .join(';');

      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setString('cookie', stringCookie);
    } else {}
  }

  // Future<void> updateCookie(http.Response response) async {
  //   String? rawCookie = response.headers['set-cookie'];

  //   if (rawCookie != null) {
  //     // int index = rawCookie.indexOf(';');
  //     // cookie = (index == -1) ? rawCookie : rawCookie.substring(0, index);
  //     // print(cookie);
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     print('cookie: ' + rawCookie!);

  //     prefs.setString('cookie', rawCookie);
  //   }
  // }

  Future<Map<String, String>> uploadHeader() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> userMap = jsonDecode(prefs.getString('user') ?? "{}");
    var token = "null";
    var domain = "null";
    if (userMap["user_id"] != null && userMap["user_id"] > 0) {
      token = userMap["token"];
      domain = userMap["store"]["domain"];
    }
    Map<String, String> requestHeaders = {};

    requestHeaders["x-access-token"] = token ?? "";
    requestHeaders["x-shop-domain"] = domain ?? "";
    return requestHeaders;
  }
}
