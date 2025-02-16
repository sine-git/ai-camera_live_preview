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
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'package:image_picker_application/common/functions.dart';
import 'package:image_picker_application/main.dart';

class TextRecognizerPage extends StatefulWidget {
  const TextRecognizerPage({super.key, required this.title});
  final String title;

  @override
  State<TextRecognizerPage> createState() => _TextRecognizerPageState();
}

class _TextRecognizerPageState extends State<TextRecognizerPage> {
  late CameraController _cameraController;
  late String _result = "";
  bool _isBusy = false;
  CameraDescription _cameraDescription = cameras[1];
  CameraLensDirection _cameraLensDirection = CameraLensDirection.back;
  dynamic _scanResults;
  late TextRecognizer _textRecognizer;
  late RecognizedText? recognizedTexts;

  @override
  void initState() {
    String _result = "";
    ObjectDetectorOptions objectDetectorOptions = ObjectDetectorOptions(
        mode: DetectionMode.stream,
        classifyObjects: true,
        multipleObjects: true);
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
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
            _doTextRecognition(image);
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

  _doTextRecognition(CameraImage image) async {
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
    recognizedTexts = await _textRecognizer.processImage(inputImage);
    print("${recognizedTexts!.text}");

    setState(() {
      _scanResults = recognizedTexts;
      recognizedTexts;
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
            "Text recognizer",
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

    CustomPainter painter = ObjectPainter(
        recognizedText: _scanResults,
        imageSize: imageSize,
        cameraLensDirection: _cameraLensDirection);
    return CustomPaint(
      painter: painter,
      // size: imageSize,
    );
  }
}

class ObjectPainter extends CustomPainter {
  RecognizedText recognizedText;
  Size imageSize;
  CameraLensDirection cameraLensDirection;
  ObjectPainter({
    required this.recognizedText,
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
    for (TextBlock block in recognizedText.blocks) {
      Rect rect = block.boundingBox;
      List<Point<int>> cornerPoints = block.cornerPoints;
      String text = block.text;
      final List<String> languages = block.recognizedLanguages;

      for (TextLine line in block.lines) {
        canvas.drawRect(
            Rect.fromLTRB(
                block.boundingBox.left * scaleX,
                block.boundingBox.top * scaleY,
                block.boundingBox.right * scaleX,
                block.boundingBox.bottom * scaleY),
            paint);

        TextSpan textSpan = TextSpan(
            text: line.text,
            style: TextStyle(color: Colors.white, fontSize: 16));
        TextPainter textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
        );
        textPainter.layout();
        textPainter.paint(
            canvas,
            Offset(line.boundingBox.left.toDouble() * scaleX,
                line.boundingBox.top.toDouble() * scaleY));
        for (TextElement element in line.elements) {}
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
