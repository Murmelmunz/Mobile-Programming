import 'dart:io';
import 'dart:async';
import 'package:aqueduct/aqueduct.dart';
import 'package:mongo_dart/mongo_dart.dart';

class RoomController extends ResourceController {
  DbCollection roomCollection;

  RoomController(roomCollection) {
    this.roomCollection = roomCollection;
  }

  @Operation.get()
  Future<Response> getAll() async {
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

  @Operation.post()
  Future<Response> create() async {
    Map<String, dynamic> body = request.body.as();

    var id;

    await body.forEach((k, v) {
      if (k.contains('roomId')) {
        id = v;
      }
    });

    var updateContent = await roomCollection.findOne({"roomId": id});

    if (updateContent == null) {
      roomCollection.insert(body);
    } else {
      return Response.conflict(body: 'room with the roomId alresy exists');
    }

    return Response.ok('created new room');
  }

  @Operation.put('id')
  Future<Response> update(@Bind.path('id') int id) async {
    var roomIdContent = await roomCollection.findOne(where.eq("roomId", id));

    if (roomIdContent == null) {
      return Response.notFound(body: 'room with the roomId $id not exists');
    }

    Map<String, dynamic> body = request.body.as();

    var updateContent = await roomCollection.findOne({"roomId": id});

    body.entries.forEach((f) => {updateContent[f.key] = f.value});

    await roomCollection.save(updateContent);

    return Response.ok("item on pos $id updated");
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