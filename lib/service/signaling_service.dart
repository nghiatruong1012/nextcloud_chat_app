import "dart:convert";

import "package:http/http.dart" as http;
import "package:nextcloud_chat_app/service/request.dart";

class SignalingService {
  Future<void> postSignal(String token, params) async {
    Map<String, String> requestHeaders = await HTTPService().authHeader();

    try {
      final response = await http.post(
        Uri(
          scheme: 'http',
          host: host,
          port: 8080,
          path: '/ocs/v2.php/apps/spreed/api/v3/signaling/${token}',
        ),
        headers: requestHeaders,
        body: jsonEncode(params ?? {}),
      );
      if (response.statusCode == 200) {
        print("post signal sucsess");
      } else {
        print("post signal error" + response.statusCode.toString());
      }
    } catch (e) {
      print(e);
    }
  }
}
