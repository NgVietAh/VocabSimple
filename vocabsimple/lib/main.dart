import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vocabsimple/src/components/user/PageLogin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Khởi tạo Firebase

  runApp(const MaterialApp(
    home: PageLogin(),
    debugShowCheckedModeBanner: false,
  ));
}
