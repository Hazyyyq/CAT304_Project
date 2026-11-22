import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';

Future<void> submitComment(
  String reportId,
  String commentText, {
  String imageURL = '',
}) async {
  final docRef = firestoreDb
      .collection('comments_reports')
      .doc(reportId);

  final newComment = {
    'imageURL': imageURL,
    'text': commentText,
    'timestamp': Timestamp.now(),
  };

  await firestoreDb.runTransaction((transaction) async {
    final snapshot = await transaction.get(docRef);
    final data = snapshot.data();

    // Safely handle existing documents even if 'Comments' was previously a single Map
    if (snapshot.exists && data?['Comments'] is List) {
      transaction.update(docRef, {
        'Comments': FieldValue.arrayUnion([newComment]),
      });
    } else if (snapshot.exists && data?['Comments'] is Map) {
      transaction.update(docRef, {
        'Comments': [data!['Comments'], newComment],
      });
    } else {
      transaction.set(
        docRef,
        {
          'Comments': [newComment],
        },
        SetOptions(merge: true),
      );
    }
  });
}