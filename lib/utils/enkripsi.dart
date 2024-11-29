import 'dart:convert';
import 'package:crypto/crypto.dart';

String encryptPassword(String password) {
  var bytes = utf8.encode(password); // Mengonversi password ke dalam bytes
  var digest = sha256.convert(bytes); // Menggunakan SHA-256 untuk mengenkripsi
  return digest.toString(); // Mengembalikan hasil enkripsi sebagai string
}

