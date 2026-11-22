import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';

class EditProfileDetails {
  final String profileType;
  final String editText;

  EditProfileDetails({
    required this.profileType,
    required this.editText,
  });
}

Future<void> updateUserProfile(String userId, EditProfileDetails details) async {
  try {
    final docRef = firestoreDb.collection('users').doc(userId);

    await docRef.set(
      {details.profileType: details.editText},
      SetOptions(merge: true),
    );

    debugPrint('Profile updated: ${details.profileType} -> ${details.editText}');
  } catch (e) {
    debugPrint('Failed to update profile: $e');
    rethrow;
  }
}