import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';

class UserProfileDetails {
  final String username;
  final String course;
  final String emergencyContact;
  final String email;
  final String role;
  final String timeCreated;

  UserProfileDetails({
    required this.username,
    required this.course,
    required this.emergencyContact,
    required this.email,
    this.role = 'user',
    required this.timeCreated,
  });
}

Future<UserProfileDetails> fetchUserInfo(String uid) async {
  try {
    debugPrint("Fetching user info for UID: $uid");
    final doc = await firestoreDb
        .collection('users')
        .doc(uid)
        .get();

    if (doc.exists) {
      final data = doc.data() ?? {};
      final rawCreatedAt = data['createdAt'];
      final String formattedDate = rawCreatedAt is Timestamp
          ? rawCreatedAt.toDate().toString()
          : (rawCreatedAt?.toString() ?? '');

      return UserProfileDetails(
        username: data['name'] ?? '',
        course: data['course'] ?? '',
        emergencyContact: data['emergency_contact'] ?? '',
        email: data['email'] ?? '',
        role: data['role'] ?? 'user',
        timeCreated: formattedDate,
      );
    }
  } catch (e) {
    debugPrint("Error fetching user info: $e");
  }
  return UserProfileDetails(
    username: '',
    course: '',
    emergencyContact: '',
    email: '',
    timeCreated: '',
  );
}