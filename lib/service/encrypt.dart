import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:encrypt/encrypt.dart';

class EncryptionDecryption {
  // static final key=encrypt.Key.fromLength(32);
  // static final iv=encrypt.IV.fromLength(16);
  // static final encrypter=encrypt.Encrypter(encrypt.AES(key));

  // static encryptMessage(String plainMessageText){
  //   final encrypted=encrypter.encrypt(plainMessageText,iv: iv);
  //   return encrypted.base64;
  // }
  // static decryptMessage(encryptedMessageText){
  //   return encrypter.decrypt(encryptedMessageText,iv:iv);
  // }

  // Hàm mã hóa tin nhắn với khóa được chỉ định
  String encryptMessage(String keyString, String message) {
    final key = Key.fromUtf8(keyString);
    final iv = IV.fromLength(16); // Độ dài của iv phải là 16 cho AES
    final encrypter = Encrypter(AES(key));

    final encryptedText = encrypter.encrypt(message, iv: iv);
    return encryptedText.base64;
  }

// Hàm giải mã tin nhắn với khóa được chỉ định
  String decryptMessage(String keyString, String encryptedMessage) {
    final key = Key.fromUtf8(keyString);
    final iv = IV.fromLength(16); // Độ dài của iv phải là 16 cho AES
    final encrypter = Encrypter(AES(key));

    final encrypted = Encrypted.fromBase64(encryptedMessage);
    final decryptedText = encrypter.decrypt(encrypted, iv: iv);
    return decryptedText;
  }
}
