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

import 'package:image_picker_application/common/functions.dart';
import 'package:image_picker_application/main.dart';

class FaceDetectionPage extends StatefulWidget {
  const FaceDetectionPage({super.key, required this.title});
  final String title;

  @override
  State<FaceDetectionPage> createState() => _FaceDetectionPageState();
}

class _FaceDetectionPageState extends State<FaceDetectionPage> {
  late CameraController _cameraController;
  late ImageLabeler _imageLabeler;
  late BarcodeScanner _barcodeScanner;
  late String _result = "";
  bool _isBusy = false;
  CameraDescription _cameraDescription = cameras[1];
  CameraLensDirection _cameraLensDirection = CameraLensDirection.back;
  dynamic _scanResults;
  late FaceDetector _faceDetector;
  late List<Face> faces;

  @override
  void initState() {
    String _result = "";
    FaceDetectorOptions faceDetectorOptions = FaceDetectorOptions(
      minFaceSize: 0.3,
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
      enableTracking: true,
      performanceMode: FaceDetectorMode.fast,
    );
    _faceDetector = FaceDetector(options: faceDetectorOptions);
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
            _doFaceDetection(image);
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

  _doFaceDetection(CameraImage image) async {
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

    faces = await _faceDetector.processImage(inputImage);
    print("Number of faces ${faces.length}");

    setState(() {
      _scanResults = faces;
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
            "Live face detector",
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

    CustomPainter painter = FacePainter(
        facesList: _scanResults,
        imageSize: imageSize,
        cameraLensDirection: _cameraLensDirection);
    return CustomPaint(
      painter: painter,
      // size: imageSize,
    );
  }
}

class FacePainter extends CustomPainter {
  List<Face> facesList;
  Size imageSize;
  CameraLensDirection cameraLensDirection;
  FacePainter({
    required this.facesList,
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
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // canvas.drawCircle(Offset(10, 10), pi, paint);
    for (Face face in facesList) {
      print("Printing faces");
      canvas.drawRect(
          Rect.fromLTRB(
            cameraLensDirection == CameraLensDirection.back
                ? (imageSize.width - face.boundingBox.right) * scaleX
                : face.boundingBox.left * scaleX,
            face.boundingBox.top * scaleY,
            cameraLensDirection == CameraLensDirection.back
                ? (imageSize.width - face.boundingBox.left) * scaleX
                : face.boundingBox.right * scaleX,
            face.boundingBox.bottom * scaleY,
          ),
          paint);
    }

    Paint paint2 = Paint();
    paint2
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    for (Face face in facesList) {
      Map<FaceContourType, FaceContour?> contours = face.contours;
      List<Offset> offsetPoints = <Offset>[];
      contours.forEach((key, value) {
        if (value != null) {
          List<Point<int>>? points = value.points;
          for (Point point in points) {
            Offset offset = Offset(
                (cameraLensDirection == CameraLensDirection.back
                    ? (imageSize.width - point.x.toDouble()) * scaleX
                    : point.x.toDouble() * scaleX),
                point.y.toDouble() * scaleY);
            offsetPoints.add(offset);
          }
          canvas.drawPoints(PointMode.points, offsetPoints, paint);
        }
      });
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
