import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:image_picker_application/main.dart';

class LiveCamera extends StatefulWidget {
  const LiveCamera({super.key, required this.title});
  final String title;

  @override
  State<LiveCamera> createState() => _LiveCameraState();
}

class _LiveCameraState extends State<LiveCamera> {
  late CameraController _cameraController;
  @override
  void initState() {
    // TODO: implement initState
    _cameraController = CameraController(cameras[0], ResolutionPreset.max);
    _cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _cameraController.startImageStream(
        (image) {
          print("${image.width} ${image.height}");
        },
      );
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              (_cameraController.value.isInitialized)
                  ? Container(
                      color: Colors.blue,
                      child: CameraPreview(_cameraController))
                  : Container(),
            ],
          ),
        ));
  }
}
