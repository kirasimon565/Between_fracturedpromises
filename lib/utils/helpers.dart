import 'dart:math';

class AppHelpers {
  static String generateId() {
    var r = Random();
    return String.fromCharCodes(List.generate(10, (index) => r.nextInt(33) + 89));
  }
}
