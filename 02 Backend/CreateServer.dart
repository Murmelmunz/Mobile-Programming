import 'dart:async';
import 'dart:io';
import 'package:aqueduct/aqueduct.dart';
import 'channel.dart';

class CreateServer {
  Future main() async {
    final app = Application<Channel>()
      ..options.configurationFilePath = "config.yaml"
      ..options.port = 3000;

    final count = 1;
    await app.start(numberOfInstances: count > 0 ? count : 1);

    print("Application started on port: ${app.options.port}.");

  }

  CreateServer() {
    this.main();
  }
}
