// import 'dart:convert';

// import 'package:encrypt/encrypt.dart' as encrypt;

// class EncryptionDecryption {
//   bool isEncrypted(String text) {
//     try {
//       // Giải mã chuỗi, nếu không có lỗi, đây là chuỗi đã được mã hóa
//       final decode = base64.decode(text);
//       return true;
//     } catch (e) {
//       // Nếu có lỗi, đây không phải là chuỗi đã được mã hóa
//       return false;
//     }
//   }

// // Hàm mã hóa chuỗi
//   String encryptString(String plainText) {
//     final keyString = 'my32lengthsupersecretnooneknows1';
//     final ivString = 'my32lengthsupers';
//     final key = encrypt.Key.fromUtf8(keyString);
//     final iv = encrypt.IV.fromUtf8(ivString);
//     final encrypter = encrypt.Encrypter(encrypt.AES(key));
//     final encrypted = encrypter.encrypt(plainText, iv: iv);
//     return encrypted.base64;
//   }

// // Hàm giải mã chuỗi
//   String decryptString(String encryptedText) {
//     final keyString = 'my32lengthsupersecretnooneknows1';
//     final ivString = 'my32lengthsupers';
//     if (isEncrypted(encryptedText)) {
//       final key = encrypt.Key.fromUtf8(keyString);
//       final iv = encrypt.IV.fromUtf8(ivString);
//       final encrypter = encrypt.Encrypter(encrypt.AES(key));
//       try {
//         final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
//         // print("decrypt" + decrypted);
//         return decrypted;
//       } catch (e) {
//         return encryptedText;
//       }
//     } else {
//       return encryptedText;
//     }
//   }
// }
import 'dart:convert';

import 'package:diffie_hellman/diffie_hellman.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:nextcloud_chat_app/service/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<String> getKeyString(String username, String otherUsername) async {
    try {
      SharedPreferences sharedKey = await SharedPreferences.getInstance();
      String privateKeyString = sharedKey.getString(username) ?? '';
      String publicKeyString =
          await FirebaseService().fetchDataFromFirestore(username);
      String otherPublicKeyString =
          await FirebaseService().fetchDataFromFirestore(otherUsername);

      // Check if any of the keys retrieved are empty
      if (privateKeyString.isEmpty ||
          publicKeyString.isEmpty ||
          otherPublicKeyString.isEmpty) {
        return '';
        // throw Exception(
        //     "One or more keys are empty or could not be retrieved.");
      }

      DhPrivateKey privateKey = DhPrivateKey.fromPem(privateKeyString);
      DhPublicKey publicKey = DhPublicKey.fromPem(publicKeyString);
      DhPublicKey otherPublicKey = DhPublicKey.fromPem(otherPublicKeyString);

      // Ensure that all keys were parsed successfully
      if (privateKey == null || publicKey == null || otherPublicKey == null) {
        return '';
        // throw Exception("Failed to parse one or more keys.");
      }

      DhPkcs3Engine dhEngine = DhPkcs3Engine.fromKeyPair(
          DhKeyPair(publicKey: publicKey, privateKey: privateKey));
      String sharedSecret = dhEngine
          .computeSecretKey(otherPublicKey.value)
          .toRadixString(16)
          .substring(0, 48);

      return sharedSecret;
    } catch (e) {
      // Print or log the error for debugging
      print("Error in getKeyString: $e");
      // Return null or rethrow the error depending on your application's logic
      // throw ArgumentError.value(e);
      return '';
    }
  }

  // Hàm mã hóa chuỗi
  String encryptString(String plainText, String secretKey) {
    final keyString = secretKey.substring(0, 32);
    final ivString = secretKey.substring(32, 48);
    final key = encrypt.Key.fromUtf8(keyString);
    final iv = encrypt.IV.fromUtf8(ivString);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

// Hàm giải mã chuỗi
  String decryptString(String encryptedText, String secretKey) {
    final keyString = secretKey.substring(0, 32);
    final ivString = secretKey.substring(32, 48);
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
