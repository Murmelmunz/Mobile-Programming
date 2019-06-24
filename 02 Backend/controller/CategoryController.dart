import 'dart:io';
import 'dart:async';
import 'package:aqueduct/aqueduct.dart';
import 'package:mongo_dart/mongo_dart.dart';

class CategoryController extends ResourceController {
  DbCollection categoryCollection;
  DbCollection roomCollection;

  CategoryController(categoryCollection, roomCollection) {
    this.categoryCollection = categoryCollection;
    this.roomCollection = roomCollection;
  }

  @Operation.get()
  Future<Response> getAll() async {
    List categoryCollectionContent = [];

    await categoryCollection
        .find()
        .forEach((v) => {categoryCollectionContent.add(v)});

    return Response.ok(categoryCollectionContent);
  }

  @Operation.post()
  Future<Response> create() async {
    Map<String, dynamic> body = request.body.as();

    String categoryName;

    await body.forEach((k, v) {
      categoryName = k;
    });

    if (body.length == 1 && categoryName.contains('name')) {
      await categoryCollection.insert(body);

      return Response.ok(body);
    } else {
      return Response.forbidden(body: "Only name");
    }
  }

  @Operation.put('name')
  Future<Response> update(@Bind.path('name') String name) async {
    var contentCategory = await categoryCollection.findOne(where.eq("name", name));

    if (contentCategory == null) {
      return Response.notFound(
          body: 'category with the category name $name not exists');
    }

    Map<String, dynamic> body = request.body.as();

    var updateContentFromCategory = await categoryCollection.findOne({"name": name});

    await body.entries.forEach((f) => {updateContentFromCategory[f.key] = f.value});

    await categoryCollection.save(updateContentFromCategory);

    return Response.ok("category with the category name $name updated");
  }

  @Operation.delete('name')
  Future<Response> delete(@Bind.path('name') String name) async {
    var contentCategory = await categoryCollection.findOne(where.eq("name", name));

    if (contentCategory == null) {
      return Response.notFound(
          body: 'category with the category name $name not exists');
    }

    categoryCollection.remove(where.eq("name", name));

    return Response.ok("category with the category name $name removed");
  }
}
