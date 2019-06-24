import 'dart:io';
import 'dart:async';
import 'package:aqueduct/aqueduct.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:math';
import 'package:password/password.dart';
import 'dart:convert';

class RoomController extends ResourceController {
  DbCollection roomCollection;
  DbCollection categoryCollection;
  var socket;

  RoomController(roomCollection, categoryCollection, socket) {
    this.roomCollection = roomCollection;
    this.categoryCollection = categoryCollection;
    this.socket = socket;
  }

  @Operation.get()
  Future<Response> getAll() async {
    if (this.socket != null) {
      this.socket.add("Hello from RoomController");
    }

    List roomCollectionContent = [];

    await roomCollection.find().forEach((v) => {roomCollectionContent.add(v)});

    return Response.ok(roomCollectionContent);
  }

  @Operation.get('id')
  Future<Response> getOne(@Bind.path('id') int id) async {
    var roomIdContent = await roomCollection.findOne(where.eq("roomId", id));

    if (roomIdContent == null) {
      return Response.notFound(body: 'room with the roomId $id not exists');
    }

    return Response.ok(roomIdContent);
  }

  generateId() async {
    var rng = new Random();

    var id = 0;

    while (id < 1000) {
      id = id + rng.nextInt(999999);
    }

    return id;
  }

  @Operation.post()
  Future<Response> create() async {
    Map<String, dynamic> body = request.body.as();

    var id = await generateId();

    var updateContentRoom = await roomCollection.findOne({"roomId": id});

    while (updateContentRoom != null) {
      id = await generateId();
      updateContentRoom = await roomCollection.findOne({"roomId": id});
    }

    body['roomId'] = id;

    var password;

    await body.forEach((k, v) {
      if (k.contains('password')) {
        password = v;
      }
    });

    if (password != null) {
      final hash = Password.hash(password, PBKDF2());
      body['password'] = hash;
    }

    Map<String, dynamic> contentFromCategory;

    await body.forEach((k, v) {
      if (k.contains('categories')) {
        var t = 0;
        while (t < v.length) {
          contentFromCategory = v[t];
          this.getCategoryName(contentFromCategory);
          t++;
        }
      }
    });

    await roomCollection.insert(body);

    return Response.ok(body);
  }

  getCategoryName(contentFromCategory) async {
    String categoryName;

    await contentFromCategory.forEach((k, v) {
      categoryName = v;
      this.helperMethodToCheckIfCategoryExists(
          categoryName, contentFromCategory);
    });
  }

  helperMethodToCheckIfCategoryExists(categoryName, contentFromCategory) async {
    var contentCategory =
        await categoryCollection.findOne({"name": categoryName});

    if (contentCategory == null) {
      await this.categoryCollection.insert(contentFromCategory);
    }
  }

  @Operation.put('id')
  Future<Response> update(@Bind.path('id') int id) async {
    var roomIdContent = await roomCollection.findOne(where.eq("roomId", id));

    if (roomIdContent == null) {
      return Response.notFound(body: 'room with the roomId $id not exists');
    }

    Map<String, dynamic> body = request.body.as();

    var updateContent = await roomCollection.findOne({"roomId": id});

    await body.entries.forEach((f) => {updateContent[f.key] = f.value});

    await roomCollection.save(updateContent);

    return Response.ok("room with the roomId $id updated");
  }

  @Operation.delete('id')
  Future<Response> delete(@Bind.path('id') int id) async {
    var roomIdContent = await roomCollection.findOne(where.eq("roomId", id));

    if (roomIdContent == null) {
      return Response.notFound(body: 'room with the roomId $id not exists');
    }

    roomCollection.remove(where.eq("roomId", id));

    return Response.ok("room with the roomId $id removed");
  }
}
