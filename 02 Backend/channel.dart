import 'dart:async';
import 'dart:io';
import 'package:aqueduct/aqueduct.dart';
import 'controller/CategoryController.dart';
import 'controller/ContributionController.dart';
import 'controller/RoomController.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'controller/UserController.dart';

class Channel extends ApplicationChannel {
  DbCollection roomCollection;
  DbCollection categoryCollection;
  DbCollection userCollection;
  DbCollection contributionCollection;
  var socket;

  @override
  Future prepare() async {
    Db db = new Db("mongodb://localhost:27017/test");
    await db.open();
    roomCollection = await db.collection('rooms');
    categoryCollection = await db.collection('category');
    userCollection = await db.collection('userT');
    contributionCollection = await db.collection('contribution');

    var collectionEmpty;

    await categoryCollection.count().then((a) {
      collectionEmpty = a;
    });

    if (collectionEmpty == 0) {
      await categoryCollection.insertAll([
        {'name': "test1"},
        {'name': "test2"},
        {'name': "test3"}
      ]);
    }
  }

  @override
  Controller get entryPoint {
    final router = Router();

    router.route("/").linkFunction((request) async {
      return new Response.ok('Hello world')..contentType = ContentType.TEXT;
    });

    router.route("/room/[:id]").link(() => RoomController(
        this.roomCollection, this.categoryCollection, this.socket));

    router.route("room/category/[:name]").link(
        () => CategoryController(this.categoryCollection, this.roomCollection));

    router
        .route("room/:id/user/[:userId]")
        .link(() => UserController(this.userCollection, this.roomCollection));

    router.route("room/:id/user/:userId/contribution/[:contributionId]").link(() =>
        ContributionController(
            this.roomCollection, this.contributionCollection));

    router.route("/connect").linkFunction((request) async {
      socket = await WebSocketTransformer.upgrade(request.raw);
      socket.listen((a) => {print(a)});

      socket.add("data");

      return null;
    });

    return router;
  }
}
