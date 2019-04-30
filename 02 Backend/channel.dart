import 'dart:async';
import 'dart:io';
import 'package:aqueduct/aqueduct.dart';
import 'controller/TestController.dart';


class Channel extends ApplicationChannel {
  
  @override
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  @override
  Controller get entryPoint {
    final router = Router();

    router.route("/").linkFunction((request) async {
      return new Response.ok('Hello world')..contentType = ContentType.TEXT;
    });

    router.route("/test/[:id]").link(() => TestController());

    return router;
  }
}
