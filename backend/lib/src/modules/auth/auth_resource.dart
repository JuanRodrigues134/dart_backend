import 'dart:async';
import 'dart:convert';

import 'package:backend/src/core/services/bcrypt/bcrypt_service.dart';
import 'package:backend/src/core/services/jwt/jwt_service.dart';
import 'package:backend/src/core/services/request_extractor/request_extractor.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

import '../../core/services/database/remote_database.dart';

class AuthResource extends Resource {
  @override
  List<Route> get routes => [
        // login
        Route.get('/auth/login', _login),
        // refresh_token
        Route.get('/auth/refresh_token', _refreshToken),
        // check_token
        Route.get('/auth/check_token', _checkToken),
        // update_password
        Route.post('/auth/update_password', _updatePassword),
      ];

  FutureOr<Response> _login(Request request, Injector injector) async {
    final database = injector.get<RemoteDatabase>();
    final bcrypit = injector.get<BCryptService>();
    final extractor = injector.get<RequestExtractor>();
    final jwt = injector.get<JwtService>();
    final credential = extractor.getAuthorizationBasic(request);
    final result = await database.query(
      'SELECT id, password, role FROM "User" WHERE email = @email;',
      variables: {
        'email': credential.email,
      },
    );

    if (result.isEmpty) {
      return Response.forbidden(jsonEncode({
        'error': 'Email ou senha invalida',
      }));
    }

    final userMap = result.map((e) => e['User']).first!;

    if (bcrypit.checkHash(credential.password, userMap['password'])) {
      return Response.forbidden(jsonEncode({
        'error': 'Email ou senha invalida',
      }));
    }

    final payload = userMap..remove('password');

    payload['exp'] = _determineExpiration(Duration(minutes: 10));
    final accesToken = jwt.generateToken(payload, 'accessToken');

    payload['exp'] = _determineExpiration(Duration(days: 3));
    final refreshToken = jwt.generateToken(payload, 'refreshToken');

    return Response.ok(jsonEncode({
      'acces_token': accesToken,
      'refresh_token': refreshToken,
    }));
  }

  FutureOr<Response> _refreshToken() {
    return Response.ok('body');
  }

  FutureOr<Response> _checkToken() {
    return Response.ok('body');
  }

  FutureOr<Response> _updatePassword() {
    return Response.ok('body');
  }

  int _determineExpiration(Duration duration) {
    final expiresDate = DateTime.now().add(duration);
    final expiresIn = Duration(milliseconds: expiresDate.millisecondsSinceEpoch);

    return expiresIn.inSeconds;
  }
}
