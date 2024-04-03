import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import './service/request.dart';

Map<String, String> parseInputString(String inputString) {
  Map<String, String> result = {};

  RegExp regex = RegExp(r"server:([^&]+)&user:([^&]+)&password:([^&]+)");

  Match? match = regex.firstMatch(inputString);
  if (match != null) {
    result['server'] = match.group(1)!;
    result['user'] = match.group(2)!;
    result['password'] = match.group(3)!;
  }

  return result;
}

// const String localhost = "http://192.168.0.178:8080";
const String localhost = "http:/$host:8080";

String generateRandomString(int length) {
  const characters =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random.secure();
  return String.fromCharCodes(Iterable.generate(
      length, (_) => characters.codeUnitAt(random.nextInt(characters.length))));
}

String calculateSha256(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

String generateRandomStringWithSha256(int length) {
  // Tạo một chuỗi ngẫu nhiên
  String randomString = generateRandomString(length);

  // Tính toán giá trị SHA-256 của chuỗi
  String sha256Hash = calculateSha256(randomString);

  // Trả về chuỗi SHA-256
  return sha256Hash;
}

String formatFileSize(int fileSizeInBytes) {
  const int KB = 1024;
  const int MB = KB * 1024;
  const int GB = MB * 1024;
  const int TB = GB * 1024;

  if (fileSizeInBytes >= TB) {
    return "${(fileSizeInBytes / TB).toStringAsFixed(2)} TB";
  } else if (fileSizeInBytes >= GB) {
    return "${(fileSizeInBytes / GB).toStringAsFixed(2)} GB";
  } else if (fileSizeInBytes >= MB) {
    return "${(fileSizeInBytes / MB).toStringAsFixed(2)} MB";
  } else if (fileSizeInBytes >= KB) {
    return "${(fileSizeInBytes / KB).toStringAsFixed(2)} KB";
  } else {
    return "$fileSizeInBytes Bytes";
  }
}

bool containsOnlyEmojis(String text) {
  RegExp emojiPattern = RegExp(
    r"[\u{1F600}-\u{1F64F}" // emoticons
    r"\u{1F300}-\u{1F5FF}" // symbols & pictographs
    r"\u{1F680}-\u{1F6FF}" // transport & map symbols
    r"\u{1F700}-\u{1F77F}" // alchemical symbols
    r"\u{1F780}-\u{1F7FF}" // Geometric Shapes Extended
    r"\u{1F800}-\u{1F8FF}" // Supplemental Arrows-C
    r"\u{1F900}-\u{1F9FF}" // Supplemental Symbols and Pictographs
    r"\u{1FA00}-\u{1FA6F}" // Chess Symbols
    r"\u{1FA70}-\u{1FAFF}" // Symbols and Pictographs Extended-A
    r"\u{2702}-\u{27B0}" // Dingbats
    r"\u{24C2}-\u{1F251}" // Enclosed characters
    "]+",
    unicode: true,
  );

  return emojiPattern.hasMatch(text);
}

bool isUrl(String string) {
  // Regular expression to match URLs
  RegExp urlRegex = RegExp(
      r"^(?:http|https):\/\/(?:www\.)?[a-zA-Z0-9\-\.]+(?:\.[a-zA-Z]{2,})+(?:[\/?=&#]?[a-zA-Z0-9\-\.\?,'\/\\\+&%\$#_]*)?$");
  return urlRegex.hasMatch(string);
}

class Utils {
  static int appId = 834139992;
  static String appSignin =
      "fd07646c89be06a8b19db880c9508805423ce1d4d2b8691fa37d1b51765d20a4";
  void showToast(String message) => Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
}
