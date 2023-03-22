import 'dart:async';
import 'dart:convert';

import 'package:backend/src/core/services/database/remote_database.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

class UserResource extends Resource {
  @override
  List<Route> get routes => [
        Route.get('/user', _getAllUsers),
        Route.get('/user/:id', _getUserById),
        Route.post('/user', _createUser),
        Route.put('/user', _updateUser),
        Route.delete('/user/:id', _deleteUser),
      ];

  FutureOr<Response> _getAllUsers(Injector injector) async {
    final database = injector.get<RemoteDatabase>();

    final result = await database.query('SELECT id, name, email, role FROM "User";');
    final listUsers = result
        .where((element) => element.containsKey('User'))
        .map((e) => e['User'])
        .toList();
    return Response.ok(jsonEncode(listUsers));
  }

  FutureOr<Response> _getUserById(Injector injector, ModularArguments arguments) async {
    final id = arguments.params['id'];
    final database = injector.get<RemoteDatabase>();
    final result = await database.query(
      'SELECT id, name, email, role FROM "User" WHERE id = @id;',
      variables: {
        'id': id,
      },
    );
    final userMap = result.map((e) => e['User']).first;

    return Response.ok(jsonEncode(userMap));
  }

  FutureOr<Response> _deleteUser(Injector injector, ModularArguments arguments) async {
    final id = arguments.params['id'];
    final database = injector.get<RemoteDatabase>();
    await database.query(
      'DELETE FROM "User" WHERE id = @id;',
      variables: {
        'id': id,
      },
    );

    return Response.ok(jsonEncode({'message': 'deleted $id'}));
  }

  FutureOr<Response> _createUser(Injector injector, ModularArguments arguments) async {
    final userParams = (arguments.data as Map).cast<String, dynamic>();
    userParams.remove('id');

    final database = injector.get<RemoteDatabase>();
    final result = await database.query(
      'INSERT INTO "User"(name, email, password) VALUES ( @name, @email, @password ) RETURNING id, email, role, name;',
      variables: userParams,
    );

    final userMap = result.map((e) => e['User']).first;

    return Response.ok(jsonEncode(userMap));
  }

  FutureOr<Response> _updateUser(Injector injector, ModularArguments arguments) async {
    final userParams = (arguments.data as Map).cast<String, dynamic>();
    final columns = userParams.keys
        .where((key) => key != 'id' || key != 'password')
        .map((key) => '$key=@$key')
        .toList();

    final database = injector.get<RemoteDatabase>();
    final result = await database.query(
      'UPDATE "User" SET ${columns.join(',')} WHERE id = @id RETURNING id, email, role, name;',
      variables: userParams,
    );

    final userMap = result.map((e) => e['User']).first;

    return Response.ok(jsonEncode(userMap));
  }
}
