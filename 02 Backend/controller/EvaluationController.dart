import 'dart:io';
import 'dart:async';
import 'package:aqueduct/aqueduct.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:math';
import 'dart:core';

class EvaluationController extends ResourceController {
  DbCollection evaluationCollection;

  EvaluationController(evaluationCollection) {
    this.evaluationCollection = evaluationCollection;
  }

  @Operation.get()
  Future<Response> getAll() async {
    List evaluationCollectionContent = [];

    await evaluationCollection
        .find()
        .forEach((v) => {evaluationCollectionContent.add(v)});

    return Response.ok(evaluationCollectionContent);
  }

  @Operation.post('contributionId')
  Future<Response> create(
      @Bind.path('contributionId') int contributionId) async {
    Map<String, dynamic> body = request.body.as();

    Map updateContentContribution =
        await evaluationCollection.findOne({"contributionId": contributionId});

    print(updateContentContribution);

    int timeStop = null;
    int timeStart;

    await body.forEach((a, b) async {
      if (a == "timeStop") {
        timeStop = b;
      } else if (a == "timeStart") {
        timeStart = b;
        updateContentContribution["timeStart"] = timeStart;
        await evaluationCollection.save(updateContentContribution);
      }
    });

    await updateContentContribution.forEach((a, b) {
      if(a == "timeStart") {
        timeStart = b;
      }
    });

    if (timeStop != null) {
      int time = timeStop - timeStart;
      updateContentContribution["timeStop"] = timeStop;
      updateContentContribution["time"] = time;
      await evaluationCollection.save(updateContentContribution);
    }
    

    return Response.ok(body);
  }
}
