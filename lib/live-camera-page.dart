import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker_application/common/functions.dart';

import 'package:image_picker_application/main.dart';

class LiveCamera extends StatefulWidget {
  const LiveCamera({super.key, required this.title});
  final String title;

  @override
  State<LiveCamera> createState() => _LiveCameraState();
}

class _LiveCameraState extends State<LiveCamera> {
  late CameraController _cameraController;
  late ImageLabeler _imageLabeler;
  bool _isBusy = false;
  String _result = "";

  @override
  void initState() {
    ImageLabelerOptions imageLabelerOptions =
        ImageLabelerOptions(confidenceThreshold: 0.9);
    _imageLabeler = ImageLabeler(options: imageLabelerOptions);
    // TODO: implement initState
    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.max,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21 // for Android
          : ImageFormatGroup.bgra8888,
    );
    _cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _cameraController.startImageStream(
        (image) {
          if (!_isBusy) {
            print(
                "Controller Image Group format is ${_cameraController.imageFormatGroup}");
            print("Processing frame images...");
            _isBusy = true;
            _doImageLabeling(image);
          }
          print("${image.width} ${image.height}");
        },
      );
      setState(() {
        _isBusy;
      });
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

  _doImageLabeling(CameraImage image) async {
    _result = "";
    InputImage? inputImage =
        inputImageFromCameraImage(image, _cameraController, cameras[0]);
    print("Input image is $inputImage");

    if (inputImage == null) {
      setState(() {
        _isBusy = false;
      });
      return;
    }

    print("Input image is not null");
    List<ImageLabel> labels = await _imageLabeler.processImage(inputImage);
    print("Image label size is ${labels.length}");
    for (ImageLabel label in labels) {
      String text = label.label;
      int index = label.index;
      double confidence = label.confidence;
      _result += "label :$text, confidence : $confidence\n";
    }
    setState(() {
      _result;
      _isBusy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(
            "Image Viewer",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                (_cameraController.value.isInitialized)
                    ? Container(
                        margin: EdgeInsets.all(10),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                  height:
                                      MediaQuery.of(context).size.height - 300,
                                  color: Colors.blue,
                                  child: AspectRatio(
                                      aspectRatio:
                                          _cameraController.value.aspectRatio,
                                      child: CameraPreview(_cameraController))),
                            ),
                            Image.asset(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height - 300,
                              'assets/images/edges.png',
                              fit: BoxFit.fill,
                            )
                          ],
                        ),
                      )
                    : Container(),
                Card(
                    child: Container(
                        padding: EdgeInsets.all(20),
                        width: double.infinity,
                        height: 150,
                        child: Text("Information are $_result")))
              ],
            ),
          ),
        ));
  }
}
