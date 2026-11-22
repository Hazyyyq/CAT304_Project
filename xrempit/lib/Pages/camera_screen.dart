import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraService extends StatefulWidget {
  const CameraService({super.key});

  @override
  State<CameraService> createState() => _CameraServiceState();
}

class _CameraServiceState extends State<CameraService>
    with WidgetsBindingObserver {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupCameraController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (cameraController == null ||
        cameraController?.value.isInitialized == false) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _setupCameraController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    if (cameraController == null ||
        cameraController?.value.isInitialized == false) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return SafeArea(
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.30,
              width: MediaQuery.sizeOf(context).width * 0.80,
              child: CameraPreview(
                cameraController!,
              ),
            ),
            IconButton(
              onPressed: () async {
                final XFile picture = await cameraController!.takePicture();
                final Uint8List bytes = await picture.readAsBytes();
                if (!mounted) return;
                Navigator.pop(context, (bytes: bytes, name: picture.name));
              },
              iconSize: 100,
              icon: const Icon(
                Icons.camera,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setupCameraController() async {
    final List<CameraDescription> detectedCameras = await availableCameras();
    if (detectedCameras.isNotEmpty) {
      setState(() {
        cameras = detectedCameras;
        cameraController = CameraController(
          detectedCameras.first,
          ResolutionPreset.high,
        );
      });
      cameraController?.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      }).catchError(
        (Object e) {
          debugPrint(e.toString());
        },
      );
    }
  }
}