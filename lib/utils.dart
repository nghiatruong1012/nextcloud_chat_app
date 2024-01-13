import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
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
const String localhost = "http:/${host}:8080";

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
