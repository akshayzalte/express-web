import 'package:flutter_test/flutter_test.dart';
import 'package:express/main.dart';

void main() {
  test('App instantiation smoke test', () {
    const app = CloudDentalExpressApp();
    expect(app, isNotNull);
  });
}
