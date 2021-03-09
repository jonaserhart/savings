
import 'package:firebase_auth/firebase_auth.dart';
import 'package:savings/FirebaseStorageProvider.dart';
import 'package:savings/LocalStorageProvider.dart';
import 'package:savings/StorageProvider.dart';

class Storage {
  static StorageProvider getProvider() {
    var auth = FirebaseAuth.instance;
    if (auth?.currentUser == null) {
      return LocalStorageProvider();
    }
    else return LocalStorageProvider();
  }
}