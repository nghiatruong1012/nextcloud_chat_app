import 'dart:convert';
import 'dart:io';

import 'package:nextcloud_chat_app/models/chats.dart';
import 'package:nextcloud_chat_app/service/request.dart';
import 'package:http/http.dart' as http;
import 'package:nextcloud_chat_app/utils.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

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

  Future<Map<dynamic, dynamic>> getShared(String token, String type) async {
    Map<String, String> requestHeaders = await HTTPService().authHeader();
    try {
      print(
        Uri(
            scheme: 'http',
            host: host,
            port: 8080,
            path: '/ocs/v2.php/apps/spreed/api/v1/chat/$token/share',
            query: 'objectType=$type'),
      );

      final response = await http.get(
        Uri(
            scheme: 'http',
            host: host,
            port: 8080,
            path: '/ocs/v2.php/apps/spreed/api/v1/chat/$token/share',
            query: 'objectType=$type'),
        headers: requestHeaders,
        // body: jsonEncode(params ?? {}),
      );
      if (response.statusCode == 200) {
        print('Success');
        print(jsonDecode(response.body)["ocs"]["data"]);
        Map<dynamic, dynamic> data = jsonDecode(response.body)["ocs"]["data"];
        // List<Chat> listChat = data.map((item) => Chat.fromJson(item)).toList();
        return data;
        // return Conversations.fromJson(jsonDecode(response.body));
      } else {
        print(response.statusCode.toString());
        return {};
      }
    } catch (e) {
      print(e);
      return {};
    }
  }

  Future<http.Response> receiveMessage(String token, params) async {
    Map<String, String> requestHeaders = await HTTPService().authHeader();

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
    print("receive mess" + response.body);

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

  Future<void> reactMessage(String token, String messId, params) async {
    Map<String, String> requestHeaders = await HTTPService().authHeader();

    final response = await http.post(
      Uri(
        scheme: 'http',
        host: host,
        port: 8080,
        path: '/ocs/v2.php/apps/spreed/api/v1/reaction/$token/$messId',
      ),
      headers: requestHeaders,
      body: jsonEncode(params ?? {}),
    );
    // return response;
    if (response.statusCode == 200) {
      print('Success');
    } else {
      print("fail" + response.statusCode.toString());
    }
  }

  Future<void> downloadAndOpenFile(
      String user, String fileUrl, String filePath, String fileName) async {
    String baseUrl = 'http://localhost:8080';
    if (fileUrl.startsWith(baseUrl)) {
      // Cut the base URL from the original URL
      fileUrl.substring(baseUrl.length);
    }
    Map<String, String> requestHeaders = await HTTPService().authImgHeader();

    final response = await http.get(
      Uri(
        scheme: 'http',
        host: host,
        port: 8080,
        path: '/remote.php/dav/files/${user}/${filePath}',
      ),

      headers: requestHeaders,
      // body: jsonEncode(params ?? {}),
    );

    if (response.statusCode == 200) {
      print("download sucsess");
      final String dir = (await getExternalStorageDirectory())!.path;
      final String localPath = '$dir/$fileName'; // Replace with your file name
      print(localPath);

      File file = File(localPath);

      await file.writeAsBytes(response.bodyBytes);
      if (await file.exists()) {
        print('File exists');
      } else {
        print('File does not exist');
      }

      // Open the file
      try {
        OpenFile.open(localPath);
        print('open sucsess');
      } catch (e) {
        print('Error opening file: $e');
      }
    } else {
      throw Exception(
          'Failed to download file' + response.statusCode.toString());
    }
  }

  Future<void> uploadAndSharedFile(String user, String filePath,
      String fileName, File file, String token) async {
    Map<String, String> requestHeaders = await HTTPService().authImgHeader();
    Map<String, String> requestHeaders2 = await HTTPService().authHeader();

    // var request = http.MultipartRequest(
    //     "PUT",
    //     Uri(
    //       scheme: 'http',
    //       host: host,
    //       port: 8080,
    //       path: '/remote.php/dav/files/${user}/${fileName}',
    //     ));

    // request.files.add(await http.MultipartFile.fromPath(fileName, filePath));

    // request.headers.addAll(requestHeaders);
    // final response = await http.post(
    // host, '/admin/v1/upload_file'
    //   headers: requestHeaders,
    //   body: params,
    // );
    // print(request.files);
    // final response = await request.send();
    final fileByte = await file.readAsBytes();

    final response = await http.put(
      Uri(
        scheme: 'http',
        host: host,
        port: 8080,
        path: '/remote.php/dav/files/${user}/Talk/${fileName}',
      ),
      headers: requestHeaders,
      body: fileByte,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final rp = await http.post(
          Uri(
              scheme: 'http',
              host: host,
              port: 8080,
              path: '/ocs/v2.php/apps/files_sharing/api/v1/shares'),
          headers: requestHeaders2,
          body: jsonEncode({
            "shareType": 10,
            "path": "//Talk/${fileName}",
            "shareWith": token,
            "referenceId": generateRandomStringWithSha256(64),
            "talkMetaData": "{\"messageType\":\"\"}"
          }));
      if (rp.statusCode == 200) {
        print('Shared sucsess');
      } else {
        print('shared fail' + rp.statusCode.toString());
      }
    } else {
      throw Exception('Failed to upload file' + response.statusCode.toString());
    }
  }
}
