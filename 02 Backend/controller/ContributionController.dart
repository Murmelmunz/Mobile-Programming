import 'dart:io';
import 'dart:async';
import 'package:aqueduct/aqueduct.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:math';

class ContributionController extends ResourceController {
  DbCollection roomCollection;
  DbCollection contributionCollection;

  ContributionController(roomCollection, contributionCollection) {
    this.roomCollection = roomCollection;
    this.contributionCollection = contributionCollection;
  }

  @Operation.get('id', 'userId')
  Future<Response> getAll(
      @Bind.path('id') int id, @Bind.path('userId') int userId) async {}

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
    print(n);
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
}
