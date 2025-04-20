// app_encrypt_service.dart
import 'dart:convert';

class AppEncryptService {
  final String _secretKey = '!q?uA9>R@2co{X#8t';

  String encrypt(String input) {
    return _xor(input, _secretKey);
  }

  String decrypt(String encrypted) {
    return _xorDecode(encrypted, _secretKey);
  }

  String _xor(String text, String key) {
    List<int> textCodes = text.codeUnits;
    List<int> keyCodes = key.codeUnits;
    List<int> result = [];

    for (int i = 0; i < textCodes.length; i++) {
      result.add(textCodes[i] ^ keyCodes[i % keyCodes.length]);
    }

    return base64Encode(result);
  }

  String _xorDecode(String encoded, String key) {
    List<int> encodedBytes = base64Decode(encoded);
    List<int> keyCodes = key.codeUnits;
    List<int> result = [];

    for (int i = 0; i < encodedBytes.length; i++) {
      result.add(encodedBytes[i] ^ keyCodes[i % keyCodes.length]);
    }

    return String.fromCharCodes(result);
  }
}
