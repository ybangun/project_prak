import 'dart:convert';

import 'package:crypto/crypto.dart';

class UserManager {
  static String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Map<String, String> users = {
    'andi': hashPassword('andi123'), // 'andi123' terenkripsi dengan SHA-256
    'maya': hashPassword('maya123'), // 'maya123' terenkripsi dengan SHA-256
  };
}
