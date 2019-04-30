import 'package:mongo_dart/mongo_dart.dart';

class DBManagement {

  DbCollection coll;
 
  Db db = new Db("mongodb://localhost:27017/test");

  dynamic createConnection() async {
    
    await db.open();

    coll = db.collection('user');
    
    /*
    coll.find().forEach((v) => print(v));
    */

    
    //test with test data
    await coll.insertAll([
      {'login': 'jdoe', 'name': 'John Doe', 'email': 'john@doe.com'},
      {'login': 'lsmith', 'name': 'Lucy Smith', 'email': 'lucy@smith.com'},
      {'login': 'a', 'name': 'a a', 'email': 'a@a.com'}
    ]);
    
    print(coll);
    return coll;
    //db.close();
  }

  getDB() {
    return this.db;
  }

  getColl() {
    //return this.coll;
  }

  DBManagement() {
    //this.createConnection();
  }
}
