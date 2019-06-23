import 'dart:io';
import 'dart:async';
import 'package:aqueduct/aqueduct.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:math';
import 'dart:core';

class ContributionController extends ResourceController {
  DbCollection roomCollection;
  DbCollection contributionCollection;

  ContributionController(roomCollection, contributionCollection) {
    this.roomCollection = roomCollection;
    this.contributionCollection = contributionCollection;
  }

  @Operation.get('id', 'userId')
  Future<Response> getAll(
      @Bind.path('id') int id, @Bind.path('userId') int userId) async {
    Map updateContentRoom =
        await roomCollection.findOne(where.eq("roomId", id));

    int length = updateContentRoom["user"].length;
    int n = 0;
    await updateContentRoom.forEach((a, b) async {
      if (a.contains("user")) {
        while (n < length) {
          if (updateContentRoom["user"][n]["userId"] == userId) {
            break;
          }
          n++;
        }
      }
    });
    return Response.ok(updateContentRoom['user'][n]["contribution"]);
  }

  generateId() async {
    var rng = new Random();

    var id = 0;

    while (id < 1000) {
      id = id + rng.nextInt(999999);
    }

    return id;
  }

  @Operation.post('id', 'userId')
  Future<Response> create(
      @Bind.path('id') int id, @Bind.path('userId') int userId) async {
    Map<String, dynamic> body = request.body.as();

    var contributionId = await generateId();

    var contributionCollectionContent = await contributionCollection
        .findOne({"contributionId": contributionId});

    while (contributionCollectionContent != null) {
      contributionId = await generateId();
      contributionCollectionContent = await contributionCollection
          .findOne({"contributionId": contributionId});
    }

    body["contribution"][0]['contributionId'] = contributionId;
    //body["contribution"][0]['name'] = "asdasdasd";
    await contributionCollection.insert({"contributionId": contributionId});
    //

    Map updateContentRoom = await roomCollection.findOne({"roomId": id});

    var a = await roomCollection.findOne({"roomId": id});

    int length = updateContentRoom["user"].length;
    int n = 0;
    await a.forEach((a, b) async {
      if (a.contains("user")) {
        while (n < length) {
          if (updateContentRoom["user"][n]["userId"] == userId) {
            break;
          }
          n++;
        }
      }
    });

    Map c = updateContentRoom["user"][n];
    await c.forEach((k, l) {
      if (k == "name") {
        body["contribution"][0]["name"] = l;
      }
    });

    Map b = await updateContentRoom["user"][n]["contribution"];

    if (b != null) {
      await b.forEach((d, e) {
        if (d == "contribution") {
          body["contribution"] += e;
        }
      });

      await a.addAll(body);

      await roomCollection.save(a);
    }

    updateContentRoom["user"][n]["contribution"] = body;

    await roomCollection.save(updateContentRoom);

    return Response.ok(body);
  }

  @Operation.put('id', 'userId', 'contributionId')
  Future<Response> start(
      @Bind.path('id') int id,
      @Bind.path('userId') int userId,
      @Bind.path('contributionId') int contributionId) async {
    Map<String, dynamic> body = request.body.as();

    Map updateContentRoom = await roomCollection.findOne({"roomId": id});

    int length = updateContentRoom["user"].length;
    int n = 0;
    await updateContentRoom.forEach((a, b) async {
      if (a.contains("user")) {
        while (n < length) {
          if (updateContentRoom["user"][n]["userId"] == userId) {
            break;
          }
          n++;
        }
      }
    });

    int timeStop = null;
    int timeStart;

    await body.forEach((a, b) async {
      if (a == "timeStop") {
        timeStop = b;
      }
    });

    Map b = updateContentRoom["user"][n]["contribution"];
    Map c;

    int q = 0;
    await b.forEach((k, l) async {
      if (k == "contribution") {
        while (q < l.length) {
          if (l[q]["contributionId"] == contributionId) {
            timeStart = l[q]["timeStart"];
            c = l[q];
            break;
          } else
            q++;
        }
      }
    });

    if (timeStop != null) {
      int time = timeStop - timeStart;
      await body.addAll({"time": time});
    }

    await body.addAll(c);

    updateContentRoom["user"][n]["contribution"]["contribution"][0] = body;

    await roomCollection.save(updateContentRoom);

    return Response.ok(body);
  }
}
