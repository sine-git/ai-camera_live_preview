import 'dart:io';

//import 'package:camera/camera.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_application/barcode-scanner.dart';
import 'package:image_picker_application/face-detector.dart';
import 'package:image_picker_application/home-page.dart';
import 'package:image_picker_application/live-camera-page.dart';
import 'package:image_picker_application/object-detector.dart';

List<CameraDescription> cameras = <CameraDescription>[];
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ObjectDetectionPage(title: 'Object Detection'),
    );
  }
}
