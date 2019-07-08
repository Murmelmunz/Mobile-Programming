import 'dart:io';
import 'dart:async';
import 'package:aqueduct/aqueduct.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:math';
import 'dart:core';

class ContributionController extends ResourceController {
  DbCollection roomCollection;
  DbCollection contributionCollection;
  DbCollection evaluationCollection;

  ContributionController(
      roomCollection, contributionCollection, evaluationCollection) {
    this.roomCollection = roomCollection;
    this.contributionCollection = contributionCollection;
    this.evaluationCollection = evaluationCollection;
  }

  @Operation.get('id', 'userId')
  Future<Response> getAll(
      @Bind.path('id') int id, @Bind.path('userId') int userId) async {
    Map updateContentRoom =
        await roomCollection.findOne(where.eq("roomId", id));

    int length = updateContentRoom["user"].length;
    int positionFromUser = 0;
    await updateContentRoom.forEach((a, b) async {
      if (a.contains("user")) {
        while (positionFromUser < length) {
          if (updateContentRoom["user"][positionFromUser]["userId"] == userId) {
            break;
          }
          positionFromUser++;
        }
      }
    });
    return Response.ok(
        updateContentRoom['user'][positionFromUser]["contribution"]);
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

    await contributionCollection.insert({"contributionId": contributionId});

    Map updateContentRoom = await roomCollection.findOne({"roomId": id});

    var contentRoom2 = await roomCollection.findOne({"roomId": id});

    int length = updateContentRoom["user"].length;
    int postionFromUser = 0;
    await contentRoom2.forEach((a, b) async {
      if (a.contains("user")) {
        while (postionFromUser < length) {
          if (updateContentRoom["user"][postionFromUser]["userId"] == userId) {
            break;
          }
          postionFromUser++;
        }
      }
    });

    Map contentFromUser = updateContentRoom["user"][postionFromUser];
    await contentFromUser.forEach((k, l) {
      if (k == "name") {
        body["contribution"][0]["name"] = l;
      }
      if (k == "userId") {
        body["contribution"][0]["userId"] = l;
      }
    });

    Map contentFromContribution =
        await updateContentRoom["user"][postionFromUser]["contribution"];

    if (contentFromContribution != null) {
      await contentFromContribution.forEach((d, e) {
        if (d == "contribution") {
          body["contribution"] += e;
        }
      });

      await contentRoom2.addAll(body);

      await roomCollection.save(contentRoom2);
    }

    updateContentRoom["user"][postionFromUser]["contribution"] = body;

    await roomCollection.save(updateContentRoom);

    var contentRoomContent = await updateContentRoom["contributionsAll"];
    //print(contentRoomContent.length);

    if (contentRoomContent != null && contentRoomContent.length != 0) {
      contentRoomContent = await updateContentRoom["contributionsAll"][0];
    }

    if (contentRoomContent == null) {
      var contentRoomContentTemp = await roomCollection.findOne({"roomId": id});
      contentRoomContentTemp["contributionsAll"] = body["contribution"];
      await roomCollection.save(contentRoomContentTemp);
      await evaluationCollection.insert(body["contribution"][0]);
    } else {
      var contentRoomContentTemp = await roomCollection.findOne({"roomId": id});
      var contentRoomContentTemp2 = contentRoomContentTemp["contributionsAll"];
      contentRoomContentTemp2.add(body["contribution"][0]);
      contentRoomContentTemp["contributionsAll"] = contentRoomContentTemp2;
      print(contentRoomContentTemp["contributionsAll"]);
      await roomCollection.save(contentRoomContentTemp);
      await evaluationCollection.insert(body["contribution"][0]);
    }

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
    int positionFromUser = 0;
    await updateContentRoom.forEach((a, b) async {
      if (a.contains("user")) {
        while (positionFromUser < length) {
          if (updateContentRoom["user"][positionFromUser]["userId"] == userId) {
            break;
          }
          positionFromUser++;
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

    Map contentFromContribution =
        updateContentRoom["user"][positionFromUser]["contribution"];
    Map contentFromContributionInPosition;

    int positionContribution = 0;
    await contentFromContribution.forEach((k, l) async {
      if (k == "contribution") {
        while (positionContribution < l.length) {
          if (l[positionContribution]["contributionId"] == contributionId) {
            timeStart = l[positionContribution]["timeStart"];
            contentFromContributionInPosition = l[positionContribution];
            break;
          } else
            positionContribution++;
        }
      }
    });

    if (timeStop != null) {
      int time = timeStop - timeStart;
      await body.addAll({"time": time});
    }

    await body.addAll(contentFromContributionInPosition);

    updateContentRoom["user"][positionFromUser]["contribution"]["contribution"]
        [0] = body;

    await roomCollection.save(updateContentRoom);

    return Response.ok(body);
  }

  @Operation.delete('id', 'userId', 'contributionId')
  Future<Response> delete(
      @Bind.path('id') int id,
      @Bind.path('userId') int userId,
      @Bind.path('contributionId') int contributionId) async {
    Map bodyFromRoom = await roomCollection.findOne((where.eq("roomId", id)));
    Map updateContentRoom = await roomCollection.findOne({"roomId": id});

    int length = updateContentRoom["user"].length;
    int positionFromUser = 0;
    await updateContentRoom.forEach((a, b) async {
      if (a.contains("user")) {
        while (positionFromUser < length) {
          if (updateContentRoom["user"][positionFromUser]["userId"] == userId) {
            break;
          }
          positionFromUser++;
        }
      }
    });

    Map a = bodyFromRoom['user'][positionFromUser]['contribution'];

    await a["contribution"].removeWhere(
        (contribution) => contribution["contributionId"] == contributionId);

    await roomCollection.save(bodyFromRoom);

    Map bodyFromRoom2 = await roomCollection.findOne((where.eq("roomId", id)));
    Map b = bodyFromRoom2;

    await b["contributionsAll"].removeWhere(
        (contribution) => contribution["contributionId"] == contributionId);

    await roomCollection.save(bodyFromRoom2);

    return Response.ok(
        "contribution with the contributionId  $contributionId removed");
  }
}
