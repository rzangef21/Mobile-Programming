import 'package:encrypt/encrypt.dart';
import 'dart:convert';

void main() {
  // 1. Buat key dan IV (harus panjangnya sesuai)
  final key = Key.fromUtf8('0123456789ABCDEF0123456789ABCDEF');
  final iv = IV.fromUtf8('0123456789ABCDEF');

  // 2. Buat encrypter AES
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

  // 3. Data yang ingin dienkripsi
  final plainText = 'Ini adalah rahasia besar saya 🤖';

  // 4. Enkripsi
  final encrypted = encrypter.encrypt(plainText, iv: iv);
  print('🔐 Encrypted (base 64): ${encrypted.base64}');

  //  5. Deskripsi
  final decrypted = encrypter.decrypt(encrypted, iv: iv);
  print('🔓 Decrypted text: $decrypted');

  // 6. Bisa juga enkripsi ke dalam bentuk JSON
  final data = {'user': 'Alvi Choirinnikmah', 'token': 'choi191'};
  final jsonString = jsonEncode(data);
  final encryptedJson = encrypter.encrypt(jsonString, iv: iv);
  print('🔐 Encrypted JSON: ${encryptedJson.base64}');

  final decryptedJson = encrypter.decrypt(encryptedJson, iv: iv);
  print('📄 Decrypted JSON: $decryptedJson');
}