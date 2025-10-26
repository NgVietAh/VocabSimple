import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static Future<void> init() async {
    FirebaseDatabase.instance.setPersistenceEnabled(true);
  }
}
