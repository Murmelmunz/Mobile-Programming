import 'dart:async';
import 'dart:io';
import 'package:aqueduct/aqueduct.dart';
import 'controller/RoomController.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Channel extends ApplicationChannel {
  DbCollection roomCollection;
  DbCollection counterCollection;
  bool c = false;
  var socket;

  @override
  Future prepare() async {
    Db db = new Db("mongodb://localhost:27017/test");
    await db.open();
    roomCollection = db.collection('rooms');
  }

  @override
  Controller get entryPoint {
    final router = Router();

    router.route("/").linkFunction((request) async {
      return new Response.ok('Hello world')..contentType = ContentType.TEXT;
    });

    router.route("/room/[:id]").link(() => RoomController(
        this.roomCollection, this.counterCollection, this.socket));

    router.route("/connect").linkFunction((request) async {
      socket = await WebSocketTransformer.upgrade(request.raw);
      socket.listen((a) => {print(a)});

      socket.add("data");

      return null;
    });

    return router;
  }
}
