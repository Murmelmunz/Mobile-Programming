import 'package:mongo_dart/mongo_dart.dart';

class DBConnection {
  startDb() {
    print("--------------");
    Db db = new Db("mongodb://localhost:27017/test");
    db.open();
  }

  DBConnection() {
    print("asdasdasd");
    this.startDb();
  }
}
