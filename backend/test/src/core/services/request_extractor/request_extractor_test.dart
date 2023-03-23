import 'dart:convert';

import 'package:backend/src/core/services/request_extractor/request_extractor.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  final extractor = RequestExtractor();

  test('request getAuthorizationBearer', () async {
    final request = Request('GET', Uri.parse('http://localhost/'), headers: {
      'authorization': 'bearer faadafasfqwasfadadsafqwqgasadasfqf',
    });

    final token = extractor.getAuthorizationBearer(request);

    expect(token, 'faadafasfqwasfadadsafqwqgasadasfqf');
  });

  test('request getBasicAuthorization', () async {
    var credentialAuth = 'juan.rabelo@teste.com.br:123';
    credentialAuth = base64Encode(credentialAuth.codeUnits);

    final request = Request('GET', Uri.parse('http://localhost/'), headers: {
      'authorization': 'Basic $credentialAuth',
    });

    final credential = extractor.getAuthorizationBasic(request);

    expect(credential.email, 'juan.rabelo@teste.com.br');
    expect(credential.password, '123');
  });
}
