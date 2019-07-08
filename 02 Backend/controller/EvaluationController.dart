import 'dart:io';
import 'dart:async';
import 'package:aqueduct/aqueduct.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:convert';
import 'dart:core';

class EvaluationController extends ResourceController {
  DbCollection evaluationCollection;

  EvaluationController(evaluationCollection) {
    this.evaluationCollection = evaluationCollection;
  }

  @Operation.get('roomId')
  Future<Response> getAll(@Bind.path ('roomId') int roomId) async {

    List evaluationCollectionContent = await evaluationCollection.find({"roomId":roomId}).toList();

    return Response.ok(evaluationCollectionContent);
  }

  @Operation.post('roomId', 'contributionId')
  Future<Response> create(@Bind.path ('roomId') int roomId,
      @Bind.path('contributionId') int contributionId) async {
    Map<String, dynamic> body = request.body.as();

    Map updateContentContribution =
        await evaluationCollection.findOne({"contributionId": contributionId});

    print(updateContentContribution);

    String timeStop = null;
    String timeStart;

    await body.forEach((a, b) async {
      if (a == "timeStop") {
        timeStop = DateTime.parse(b).toString();
      } else if (a == "timeStart") {
        timeStart = DateTime.parse(b).toString();
        updateContentContribution["timeStart"] = timeStart;
        await evaluationCollection.save(updateContentContribution);
      }
    });

    await updateContentContribution.forEach((a, b) {
      if (a == "timeStart") {
        timeStart = b;
      }
    });

    if (timeStop != null) {
      int time = DateTime.parse(timeStop).difference(DateTime.parse(timeStart)).inSeconds;
      updateContentContribution["timeStop"] = timeStop;
      updateContentContribution["time"] = time;
      await evaluationCollection.save(updateContentContribution);
    }

    return Response.ok(body);
  }
}
