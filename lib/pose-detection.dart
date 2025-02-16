// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'package:image_picker_application/common/functions.dart';
import 'package:image_picker_application/main.dart';

class PoseDetectionPage extends StatefulWidget {
  const PoseDetectionPage({
    super.key,
  });

  @override
  State<PoseDetectionPage> createState() => _PoseDetectionPageState();
}

class _PoseDetectionPageState extends State<PoseDetectionPage> {
  late CameraController _cameraController;
  late String _result = "";
  bool _isBusy = false;
  CameraDescription _cameraDescription = cameras[1];
  CameraLensDirection _cameraLensDirection = CameraLensDirection.back;
  dynamic _scanResults;
  late PoseDetector _poseDetector;
  late List<Pose> _posesList;

  @override
  void initState() {
    String _result = "";
    _poseDetector = PoseDetector(
        options: PoseDetectorOptions(
            mode: PoseDetectionMode.stream,
            model: PoseDetectionModel.accurate));
    _initialiseCamera();
    // TODO: implement initState

    super.initState();
  }

  _toggleCameraDescription() async {
    setState(() {
      _cameraDescription =
          (_cameraDescription == cameras[0]) ? cameras[1] : cameras[0];
      _cameraLensDirection = (_cameraDescription == cameras[0])
          ? CameraLensDirection.front
          : CameraLensDirection.back;
    });
    await _cameraController.stopImageStream();
    _initialiseCamera();
  }

  _initialiseCamera() {
    _cameraController = CameraController(
      _cameraDescription,
      ResolutionPreset.high,
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
            _doPoseDetection(image);
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
  }

  _doPoseDetection(CameraImage image) async {
    _result = "";
    InputImage? inputImage =
        inputImageFromCameraImage(image, _cameraController, _cameraDescription);
    print("Input image is $inputImage");

    if (inputImage == null) {
      setState(() {
        _isBusy = false;
      });
      return;
    }

    _posesList = await _poseDetector.processImage(inputImage);
    for (Pose pose in _posesList) {
      pose.landmarks.forEach(
        (key, landMark) {
          final type = landMark.type;
          final x = landMark.x;
          final y = landMark.y;
          //results += "${type.name} ${x.toString()} ${y.toString()}";
          print("Pose detected ${type.name} ${x.toString()} ${y.toString()}");
        },
      );
      final landMark = pose.landmarks[PoseLandmarkType.nose];
    }
    setState(() {
      _scanResults = _posesList;
      _result;
      _isBusy = false;
    });
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(
            "Pose detection",
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
                        alignment: Alignment.center,
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height - 150,
                        margin: EdgeInsets.all(10),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                  width: double.infinity,
                                  height:
                                      MediaQuery.of(context).size.height - 150,
                                  color: Colors.blue,
                                  child: AspectRatio(
                                      aspectRatio:
                                          _cameraController.value.aspectRatio,
                                      child: CameraPreview(_cameraController))),
                            ),
                            Container(
                                width: double.infinity,
                                height:
                                    MediaQuery.of(context).size.height - 150,
                                child: buildResult()),
                            Image.asset(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height - 150,
                              'assets/images/edges.png',
                              fit: BoxFit.fill,
                            ),
                          ],
                        ),
                      )
                    : Container(),
                IconButton(
                  onPressed: _toggleCameraDescription,
                  color: Colors.white,
                  icon: Icon(
                    Icons.autorenew,
                  ),
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.blue)),
                ),
                Card(
                    child: Container(
                        padding: EdgeInsets.all(20),
                        width: double.infinity,
                        height: 80,
                        child: Text(_result))),
              ],
            ),
          ),
        ));
  }

  Widget buildResult() {
    if (_scanResults == null ||
        !_cameraController.value.isInitialized ||
        _cameraController.value.previewSize == null) {
      return SizedBox.shrink();
    }

    double widthSize = _cameraController.value.previewSize!.height;
    double heightSize = _cameraController.value.previewSize!.width;
    final Size imageSize = Size(widthSize, heightSize);
    print("...Camera preview image width : $widthSize height : $heightSize");
    print("...Taken image width : $widthSize height : $heightSize");
    //final Size imageSize = Size(100, 100);

    CustomPainter painter = PosePainter(
        posesList: _scanResults,
        imageSize: imageSize,
        cameraLensDirection: _cameraLensDirection);
    return CustomPaint(
      painter: painter,
      // size: imageSize,
    );
  }
}

class PosePainter extends CustomPainter {
  late List<Pose> posesList;
  Size imageSize;
  CameraLensDirection cameraLensDirection;
  PosePainter({
    required this.posesList,
    required this.imageSize,
    required this.cameraLensDirection,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;
    print("...Size informations are ${size.width} ${size.height}");
    Paint paint = Paint();
    paint
      ..color = Colors.purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    for (Pose pose in posesList) {
      List<Offset> offsetPoints = <Offset>[];

      void paintLine(
          PoseLandmarkType type1, PoseLandmarkType type2, Pose pose) {
        final PoseLandmark joint1 = pose.landmarks[type1]!;
        final PoseLandmark joint2 = pose.landmarks[type2]!;
        canvas.drawLine(Offset(joint1.x * scaleX, joint1.y * scaleY),
            Offset(joint2.x * scaleX, joint2.y * scaleY), paint);
      }

      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, pose);
      paintLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, pose);
      paintLine(
          PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, pose);
      paintLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, pose);
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, pose);
      paintLine(
          PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, pose);
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, pose);
      paintLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, pose);

      paintLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, pose);
      paintLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, pose);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
