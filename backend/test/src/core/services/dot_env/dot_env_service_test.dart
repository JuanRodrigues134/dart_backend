import 'package:backend/src/core/services/dot_env/dot_env_service.dart';
import 'package:test/test.dart';

void main() {
  test('dot env service ...', () async {
    final service = DotEnvService(mocks: {});

    expect(service['DATABASE_URL'], 'postgres://postgres:postgrespw@localhost:32769');
  });
}
