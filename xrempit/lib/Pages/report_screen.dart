import 'dart:typed_data';

import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../Components/text_file_mng.dart';
import '../Services/fetch_location_service.dart';
import '../Services/type_report_counter_service.dart';
import '../Services/firestore_service.dart';
import '../Services/media_upload_service.dart';
import 'camera_screen.dart';

class ReportScreen extends StatefulWidget {

  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class UserInfo {
  final String username;

  UserInfo({
    required this.username, 

    });
}

class _ReportScreenState extends State<ReportScreen> {

  String category = "Illegal Racing";

  //final TextEditingController courseCtrl = TextEditingController();
  final TextEditingController detailsCtrl = TextEditingController();
  final TextEditingController idCtrl = TextEditingController();
  final TextEditingController locCtrl = TextEditingController();
  final TextEditingController locDetailsCtrl = TextEditingController();
  //final TextEditingController statusCtrl = TextEditingController();
  final TextEditingController typeCtrl = TextEditingController();
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  final MediaUploadService _mediaService = MediaUploadService();
  Uint8List? selectedImageBytes;
  String? selectedImageName;

  bool isLoading = false;

  Future<void> _pickFromGallery() async {
    final result = await _mediaService.pickImage(ImageSource.gallery);
    if (result != null) {
      setState(() {
        selectedImageBytes = result.bytes;
        selectedImageName = result.file.name;
      });
    }
  }

  Future<void> _openCamera() async {
    final result = await Navigator.push<({Uint8List bytes, String name})> (
      context,
      MaterialPageRoute(builder: (_) => const CameraService())
    );

    if (result != null && mounted) {
      setState(() {
        selectedImageBytes = result.bytes;
        selectedImageName = result.name;
      });
    }
  }

  @override
  void dispose() {
    //courseCtrl.dispose();
    detailsCtrl.dispose();
    idCtrl.dispose();
    locCtrl.dispose();
    locDetailsCtrl.dispose();
    //statusCtrl.dispose();
    typeCtrl.dispose();
    //nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Report Sightings')),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            DropdownButton<String>(
              value: category,
              itemHeight: 56,
              items: ["Illegal Racing", "Gathering", "Accident", "Other"].map((e) {
                return DropdownMenuItem(value: e, child: Text(e));
              }).toList(),
              onChanged: (val) {
                setState(() {
                  category = val!;
                });
              },
            ),

            SizedBox(height: 16),
            TextFieldMng(
              controller: detailsCtrl,
              obscureText: false,
              hintText: "Describe incident (Optional)",
            ),

            SizedBox(height: 16),
            TextFieldMng(
              controller: locCtrl,
              obscureText: false,
              hintText: "Location (Optional)",
            ),

            Spacer(),

            OutlinedButton.icon(
              onPressed: _openCamera,
              icon: const Icon(Icons.camera_alt),
              label: const Text ('Take Photo'),
            ),

            SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.folder_open),
              label: Text(selectedImageName ?? 'Choose Image from Folder'),
            ),

            if (selectedImageBytes != null) ...[
              SizedBox(height: 12),
              Image.memory(
                selectedImageBytes!,
                height: 120,
                cacheWidth: 400,
                fit: BoxFit.cover,
              ),
            ],

            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                submitReport(uid, category, detailsCtrl.text.trim(), locCtrl.text.trim());
              },

              child: Text('Submit Report'),
            ),

          ],
        ),
      ),
    );
  }

  Future<UserInfo> fetchUserInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await firestoreDb
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data();
          return UserInfo(
            username: data?['name'] ?? '',
          );

          }
        }
      }
       catch (e) {
      debugPrint("Error fetching user name: $e");
    }
  return UserInfo(username: '');

  }


  Future <void> addReport(String userName, String userId, String type, String details, String location, String reportId ) async {
   
   try {
    final locDetails = await getCurrentLocation();
    debugPrint("Location fetched: $locDetails");

    GeoPoint geoPoint = locDetails != null
        ? GeoPoint(locDetails.latitude, locDetails.longitude)
        : GeoPoint(0, 0);

    await firestoreDb.collection("reports").add({
      "Details": details,
      "ID": reportId,
      "Location": location,
      "GeoPoint": geoPoint,
      "Status": "Pending",
      "Time": FieldValue.serverTimestamp(),
      "Type": type,
      "Username": userName,
      "UserID": userId,
    });

    debugPrint("Report submitted successfully.");
  } catch (e) {
    debugPrint("Error submitting report: $e");
  } //nanti kene refine lagi
}


    void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text('Report Submitted!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // go back to login
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

    void submitReport( String userId, String category, String details, String location) async {
      setState(() => isLoading = true);

      
      final userInfo =  await fetchUserInfo();
      final reportId = await generateCustomReportId(category);

      await addReport(
        userInfo.username,
        userId, 
        category, 
        details, 
        location,
        reportId,
      );
      setState(() => isLoading = false);
      _showSuccessDialog();
    } 


}