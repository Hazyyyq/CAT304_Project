import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
//import 'package:xrempit/comp_manager/FetchMng/FetchProfile.dart';
import '../Services/edit_profile_service.dart';

class ProfileBlock extends StatelessWidget {
  final String text;
  final String detailsText;
  final String typeDetails;
  final bool isEditable;

  const ProfileBlock({
    super.key,
    required this.text,
    required this.detailsText,
    required this.typeDetails,
    required this.isEditable,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          color: Colors.grey[200],
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
            child: Text(
              '$text: $detailsText',
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        if (isEditable) ...{
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              debugPrint("Edit button pressed for $text details: $typeDetails");

              showDialog(
                context: context,
                builder: (dialogContext) {
                  TextEditingController controller =
                      TextEditingController(text: detailsText);
                  final String uid = FirebaseAuth.instance.currentUser!.uid;

                  return AlertDialog(
                    title: Text('Edit $text'),
                    content: TextField(
                      controller: controller,
                      decoration: InputDecoration(hintText: 'Enter new $text'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final newText = controller.text.trim();
                          if (newText.isNotEmpty) {
                            final messenger =
                                ScaffoldMessenger.of(dialogContext);
                            final dialogNavigator =
                                Navigator.of(dialogContext);
                            final rootNavigator = Navigator.of(context);

                            final editDetails = EditProfileDetails(
                              profileType: typeDetails,
                              editText: newText,
                            );

                            // Update Firestore
                            await updateUserProfile(uid, editDetails);

                            // Show confirmation
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('$text updated successfully!'),
                                duration: const Duration(seconds: 2),
                              ),
                            );

                            dialogNavigator.pop(); // Close the AlertDialog
                            rootNavigator.pop(); // Navigate back to main menu
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        },
      ],
    );
  }
}