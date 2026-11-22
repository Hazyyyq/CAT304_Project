import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore firestoreDb = FirebaseFirestore.instanceFor(
  app: Firebase.app(),
  databaseId: 'default',
);