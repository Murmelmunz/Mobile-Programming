import 'dart:async';
import 'dart:io';
import 'package:aqueduct/aqueduct.dart';
import 'controller/TestController.dart';
import 'controller/RoomController.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Channel extends ApplicationChannel {
  DbCollection testCollection;
  DbCollection roomCollection;
  
  @override
  Future prepare() async {
    Db db = new Db("mongodb://localhost:27017/test");
    await db.open();
    testCollection = db.collection('test');
    roomCollection = db.collection('rooms');
    insert();
  }

  insert() async {
    await this.testCollection.insertAll([
      {'login': 'jdoe', 'name': 'John Doe', 'email': 'john@doe.com'},
      {'login': 'lsmith', 'name': 'Lucy Smith', 'email': 'lucy@smith.com'},
      {'login': 'a', 'name': 'a a', 'email': 'a@a.com'}
    ]);
  }

  @override
  Controller get entryPoint {
    final router = Router();

    router.route("/").linkFunction((request) async {
      return new Response.ok('Hello world')..contentType = ContentType.TEXT;
    });

    router.route("/test/[:id]").link(() => TestController(this.testCollection));

    router.route("/room/[:id]").link(() => RoomController(this.roomCollection));

    return router;
  }
}
