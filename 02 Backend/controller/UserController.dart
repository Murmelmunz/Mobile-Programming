import 'dart:io';
import 'dart:async';
import 'package:aqueduct/aqueduct.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:password/password.dart';
import 'dart:convert';
import 'dart:math';

class UserController extends ResourceController {
  DbCollection userCollection;
  DbCollection roomCollection;

  UserController(userCollection, roomCollection) {
    this.userCollection = userCollection;
    this.roomCollection = roomCollection;
  }

  generateId() async {
    var rng = new Random();

    var id = 0;

    while (id < 1000) {
      id = id + rng.nextInt(999999);
    }

    return id;
  }

  @Operation.get('id')
  Future<Response> getAll(@Bind.path('id') int roomId) async {
    Map test = await roomCollection.findOne(where.eq("roomId", roomId));
    return Response.ok(test['user']);
  }

  @Operation.post('id')
  Future<Response> create(@Bind.path('id') int id) async {
    Map<String, dynamic> body = request.body.as();

    var userId = await generateId();

    var userCollectionContent =
        await userCollection.findOne({"userId": userId});

    while (userCollectionContent != null) {
      userId = await generateId();
      userCollectionContent = await userCollection.findOne({"userId": userId});
    }

    body['user'][0]['userId'] = userId;
    await userCollection.insert({"userId": userId});

    var password = body['user'][0]['password'];
    var roomPassword = body['user'][0]['roomPassword'];

    final hash = Password.hash(password, PBKDF2());
    body['user'][0]['password'] = hash;

    var updateContent = await roomCollection.findOne({"roomId": id});

    var roomPasswordRoomCollection;

    await updateContent.forEach((a, b) {
      if (a.contains('password')) {
        roomPasswordRoomCollection = b;
      }
    });

    var roomPasswordHash;

    if (roomPasswordRoomCollection != null && roomPassword != null) {
      roomPasswordHash = Password.hash(roomPassword, PBKDF2());
      body['user'][0]['roomPassword'] = roomPasswordHash;
    } else if (roomPassword == null && roomPasswordRoomCollection != null) {
      return Response.unauthorized(body: 'give the password for the room');
    }

    await updateContent.forEach((a, b) async {
      if (a.contains("user")) {
        body["user"] += b;
      }
    });

    await updateContent.addAll(body);

    if (roomPasswordRoomCollection != null) {
      if (roomPasswordHash == roomPasswordRoomCollection) {
        await roomCollection.save(updateContent);
        return Response.ok(body);
      } else {
        return Response.unauthorized(body: "false room password");
      }
    } else {
      await roomCollection.save(updateContent);
      return Response.ok(body);
    }
  }

  @Operation.delete('id', 'userId')
  Future<Response> delete(
      @Bind.path('id') int id, @Bind.path('userId') int userId) async {
    Map bodyFromRoom = await roomCollection.findOne((where.eq("roomId", id)));
    Map bodyFromRoom2 =
        await roomCollection.findOne((where.eq("user.userId", userId)));

    if (bodyFromRoom == null) {
      return Response.notFound(body: 'room with the roomId $id not exists');
    }
    if (bodyFromRoom2 == null) {
      return Response.notFound(body: 'user with userId $userId not exists');
    }

    await bodyFromRoom['user']
        .removeWhere((value) => value["userId"] == userId);
    await roomCollection.save(bodyFromRoom);

    return Response.ok("user with the user id removed");
  }
}