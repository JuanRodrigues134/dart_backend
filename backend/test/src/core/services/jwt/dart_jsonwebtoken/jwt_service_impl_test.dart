import 'package:backend/src/core/services/dot_env/dot_env_service.dart';
import 'package:backend/src/core/services/jwt/dart_jsonwebtoken/jwt_service_impl.dart';
import 'package:test/test.dart';

void main() {
  test('jwt create', () async {
    final dotEnvService = DotEnvService(mocks: {
      'JWT_KEY': 'jhasjahsajhsjahsjahsjahjahs',
    });
    final jwt = JwtServiceImpl(dotEnvService);
    final expiresData = DateTime.now().add(Duration(seconds: 30));
    final expiresIn =
        Duration(milliseconds: expiresData.millisecondsSinceEpoch).inSeconds;

    final token = jwt.generateToken({
      'id': 1,
      'role': 'user',
      'exp': expiresIn,
    }, 'accessToken');

    print(token);
  });

  test('verify token', () async {
    final dotEnvService = DotEnvService(mocks: {
      'JWT_KEY': 'jhasjahsajhsjahsjahsjahjahs',
    });
    final jwt = JwtServiceImpl(dotEnvService);

    jwt.verifyToken(
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwicm9sZSI6InVzZXIiLCJleHAiOjE2Nzk1Mjg1NDMsImlhdCI6MTY3OTUyODUxMywiYXVkIjoiYWNjZXNzVG9rZW4ifQ.1c3GtZcrfb8lkCpsSoS_5haSHcAOqKOV8WYQ10_BmIA',
      'accessToken',
    );
  });

  test('jwt payload', () async {
    final dotEnvService = DotEnvService(mocks: {
      'JWT_KEY': 'jhasjahsajhsjahsjahsjahjahs',
    });
    final jwt = JwtServiceImpl(dotEnvService);

    final payload = jwt.getPayload(
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwicm9sZSI6InVzZXIiLCJleHAiOjE2Nzk1Mjg1NDMsImlhdCI6MTY3OTUyODUxMywiYXVkIjoiYWNjZXNzVG9rZW4ifQ.1c3GtZcrfb8lkCpsSoS_5haSHcAOqKOV8WYQ10_BmIA',
    );

    print(payload);
  });
}
