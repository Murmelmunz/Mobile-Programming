import 'dart:io';
import 'dart:async';
import 'package:aqueduct/aqueduct.dart';
import 'package:mongo_dart/mongo_dart.dart';

List test = [
  {'a': 1, 'b': 2, 'c': 3},
  {'a': 4, 'b': 5, 'c': 6},
];

class TestController extends ResourceController {
  DbCollection testColl;
  List testContent = [];

  TestController(coll) {
    this.testColl = coll;
  }

  @Operation.get()
  Future<Response> getAll() async {
    await testColl
        .find()
        .forEach((v) => {
          testContent.add(v)
        });

    return Response.ok(testContent);
  }

  @Operation.get('id')
  Future<Response> getOne(@Bind.path('id') int id) async {
    if (id < 0 || id > test.length - 1) {
      return Response.notFound(body: 'item not exists');
    }

    return Response.ok(test[id]);
  }

  @Operation.post()
  Future<Response> create() async {
    Map<String, dynamic> body = request.body.as();
    test.add(body);
    print(body);

    return Response.ok('created item');
  }

  @Operation.put('id')
  Future<Response> update(@Bind.path('id') int id) async {
    if (id < 0 || id > test.length - 1) {
      return Response.notFound(body: 'item not exists');
    }

    test[id] = request.body.as();

    return Response.ok("item updated");
  }

  @Operation.delete('id')
  Future<Response> delete(@Bind.path('id') int id) async {
    if (id < 0 || id > test.length - 1) {
      return Response.notFound(body: 'item not exists');
    }

    test.removeAt(id);

    return Response.ok("item on pos $id removed");
  }
}
