import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';

Future<String> generateCustomReportId(String category) async {
  final counterRef = firestoreDb
      .collection('reports_counters')
      .doc("Counter");

  try {
    return await firestoreDb.runTransaction((transaction) async {
      final snapshot = await transaction.get(counterRef);

      final String cleanCategory = category.trim();
      final String key = cleanCategory.isEmpty ? "General" : cleanCategory;

      final data = snapshot.data();
      final int currentCount = (data?[key] as num?)?.toInt() ?? 0;
      final int newCount = currentCount + 1;

      transaction.set(
        counterRef,
        {key: newCount},
        SetOptions(merge: true),
      );

      final String prefix = key
          .padRight(3, 'X')
          .substring(0, 3)
          .toUpperCase();
      final String formattedId = "$prefix${newCount.toString().padLeft(4, '0')}";

      return formattedId;
    });
  } catch (e) {
    debugPrint("Transaction failed: $e");
    throw Exception("Failed to generate report ID: $e");
  }
}