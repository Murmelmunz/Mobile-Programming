import 'package:mongo_dart/mongo_dart.dart';

class DBManagement {
  void createConnection() async {
    Db db = new Db("mongodb://localhost:27017/test");
    await db.open();
    print(db.state);
    var coll = db.collection('user');
    
    //test with test data
    await coll.insertAll([
      {'login': 'jdoe', 'name': 'John Doe', 'email': 'john@doe.com'},
      {'login': 'lsmith', 'name': 'Lucy Smith', 'email': 'lucy@smith.com'},
      {'login': 'a', 'name': 'a a', 'email': 'a@a.com'}
    ]);
    db.close();
  }

  DBManagement() {
    this.createConnection();
  }
}
