import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionDecryption {
  bool isEncrypted(String text) {
    try {
      // Giải mã chuỗi, nếu không có lỗi, đây là chuỗi đã được mã hóa
      final decode = base64.decode(text);
      return true;
    } catch (e) {
      // Nếu có lỗi, đây không phải là chuỗi đã được mã hóa
      return false;
    }
  }

// Hàm mã hóa chuỗi
  String encryptString(String plainText) {
    final keyString = 'my32lengthsupersecretnooneknows1';
    final ivString = 'my32lengthsupers';
    final key = encrypt.Key.fromUtf8(keyString);
    final iv = encrypt.IV.fromUtf8(ivString);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

// Hàm giải mã chuỗi
  String decryptString(String encryptedText) {
    final keyString = 'my32lengthsupersecretnooneknows1';
    final ivString = 'my32lengthsupers';
    if (isEncrypted(encryptedText)) {
      final key = encrypt.Key.fromUtf8(keyString);
      final iv = encrypt.IV.fromUtf8(ivString);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      try {
        final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
        // print("decrypt" + decrypted);
        return decrypted;
      } catch (e) {
        return encryptedText;
      }
    } else {
      return encryptedText;
    }
  }
}
