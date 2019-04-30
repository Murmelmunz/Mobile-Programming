import '/Users/Foobai/Desktop/MOP/Mobile-Programming/02 Backend/DBManagement.dart';
import 'CreateServer.dart';

  void main() async {
    DBManagement db = new DBManagement();
    var coll = db.createConnection();
    print(db.coll);
    CreateServer cs = new CreateServer();
  }

