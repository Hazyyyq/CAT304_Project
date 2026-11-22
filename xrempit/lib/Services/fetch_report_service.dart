import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';

class ReportDetails {
  final String docId;
  final String reportId;
  final String description;
  final String location;
  final String status;
  final String type;
  final DateTime timestamp;
  final GeoPoint? geoPoint;
  final String userId;
  final String username;

  ReportDetails({
    required this.docId,
    required this.reportId,
    required this.description,
    required this.location,
    required this.status,
    required this.type,
    required this.timestamp,
    this.geoPoint,
    this.userId = '',
    this.username = '',
  });

  factory ReportDetails.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ReportDetails(
      docId: doc.id,
      reportId: data['ID'] ?? '',
      description: data['Details'] ?? '',
      location: data['Location'] ?? '',
      status: data['Status'] ?? '',
      type: data['Type'] ?? '',
      timestamp: (data['Time'] as Timestamp?)?.toDate() ?? DateTime.now(),
      geoPoint: data['GeoPoint'] as GeoPoint?,
      userId: data['UserID'] ?? '',
      username: data['Username'] ?? '',
    );
  }
}

Future<List<ReportDetails>> fetchReports() async {
  List<ReportDetails> reports = [];

  try {
    final snapshot = await firestoreDb
        .collection('reports')
        .orderBy('Time', descending: true)
        .get();

    debugPrint("Fetched ${snapshot.docs.length} reports");

    for (var doc in snapshot.docs) {
      debugPrint("Raw Firestore data: ${doc.data()}");
      reports.add(ReportDetails.fromFirestore(doc));
    }
  } catch (e) {
    debugPrint("Error fetching reports: $e");
  }

  return reports;
}