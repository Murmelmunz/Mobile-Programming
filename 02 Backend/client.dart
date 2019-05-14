import 'dart:async';
import 'dart:io';
import 'package:aqueduct/aqueduct.dart';
import 'controller/RoomController.dart';
import 'package:mongo_dart/mongo_dart.dart';

void main() async {
  var socket = await WebSocket.connect("ws://localhost:3000/connect");
  socket.add("Test");
  socket.listen((a) => {print(a)});

}
