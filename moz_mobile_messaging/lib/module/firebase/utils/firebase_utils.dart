import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';


FirebaseUtils firebaseUtil = FirebaseUtils();

late FirebaseApp firebaseApp;

class FirebaseUtils {
  Future<void> initialize() async {
    await _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  }
}
  