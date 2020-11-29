import 'dart:convert';
// import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tenji/TxtToSpeech.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as imageLib;
// import 'package:tflite/tflite.dart';
import 'package:http/http.dart' as http;

import 'RectPainter.dart';

enum labels { door, openDoor, doorHandle, doorButton }

void main() => runApp(TenjiApp());

enum Direction_EN { up, down, right, left }

class TenjiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TenjiHomePage(),
    );
  }
}

class TenjiHomePage extends StatefulWidget {
  TenjiHomePage({Key key}) : super(key: key);

  @override
  _TenjiHomePageState createState() => _TenjiHomePageState();
}

class _TenjiHomePageState extends State<TenjiHomePage> {
  TxtToSpeech tts;
  CameraController _controller;
  bool _cameraInitialized = false;
  String _topText = '';

  bool _isDetecting = false;

  // Not necessary could also use http.post directly but client allows us to keep a persisten connection open.
  http.Client _client = http.Client();
  Uri _url = Uri.parse("https://tenji-backend.herokuapp.com/image");

  var _savedRect;

  @override
  void initState() {
    super.initState();
    tts = new TxtToSpeech();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _initializeCamera();
  }

  void _initializeCamera() async {
    _topText = 'Waiting for camera initialization\n';
    // await Tflite.loadModel(
    //     // model: "assets/model.tflite", labels: "assets/labels.txt");
    //     model: "assets/model_not16.tflite",
    //     labels: "assets/labels.txt");
    // model: "assets/ssd_mobilenet.tflite",
    // labels: "assets/ssd_mobilenet.txt");

    List<CameraDescription> cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    _controller.initialize().then((_) async {
      _cameraInitialized = true;
      await _controller
          .startImageStream((CameraImage image) => _processCameraImage(image));
      _topText = 'Camera Initialization complete\n';
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    // Tflite.close();
    _client.close();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
          onTap: () {
            tts.repeat();
          },
          child: AbsorbPointer(
              child: Container(
                  color: Colors.black,
                  child: Column(
                    children: <Widget>[
                      Text(
                        _topText,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      _cameraInitialized
                          ? Expanded(
                              child: OverflowBox(
                                  maxWidth: double.infinity,
                                  child: AspectRatio(
                                    aspectRatio: _controller.value.aspectRatio,
                                    child: Stack(
                                        fit: StackFit.expand,
                                        children: <Widget>[
                                          CameraPreview(_controller),
                                          CustomPaint(
                                              painter: RectPainter(_savedRect)),
                                        ]),
                                  )))
                          : Container(),
                    ],
                  )))),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: print("not yet implemented"),
      //   backgroundColor: Colors.white,
      // ),
    );
  }

  void _processCameraImage(CameraImage image) async {
    if (_isDetecting) return;
    _isDetecting = true;
    Future findObjectFuture = _findObject(image);
    List results = await Future.wait([
      findObjectFuture,
      Future.delayed(Duration(milliseconds: 700)),
    ]);
    // Detecting object is done here.
    tts.speak(_directionFinder(results[0], image.width, image.height));
    setState(() {
      _savedRect = results[0];
    });
    _isDetecting = false;
  }

  static imageLib.Image _convertCameraImage(CameraImage image) {
    int width = image.width;
    int height = image.height;
    // imageLib -> Image package from https://pub.dartlang.org/packages/image
    var img = imageLib.Image(width, height); // Create Image buffer
    const int hexFF = 0xFF000000;
    final int uvyButtonStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel;
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex =
            uvPixelStride * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
        final int index = y * width + x;
        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        // Calculate pixel color
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        img.data[index] = hexFF | (b << 16) | (g << 8) | r;
      }
    }
    // Rotate 90 degrees to upright
    var img1 = imageLib.copyRotate(img, 90);
    return img1;
  }

  Future<Map> _findObject(CameraImage image) async {
    var img = imageLib.encodeJpg(_convertCameraImage(image));

    var response = _client.post(_url, body: img);
    var res = jsonDecode((await response).body);
    print(res);
    var resultList = res["predictions"] as List;

    // List<String> possibleLabels = [
    //   'Door',
    //   'Open door',
    //   'Door handle',
    //   'Door button'
    // ];

    // TODO:  FIND AN ALTERNATIVE TO RETURNING THE BIGGEST MATCH SHOULD RETURN DOOR OR BUTTON
    Map biggestRect;
    // double rectSize, rectMax = 0.0;
    // for (int i = 0; i < resultList.length; i++) {
    // if (possibleLabels.contains(resultList[i]["detectedClass"])) {
    // if (possibleLabels.contains(resultList[i]["label"])) {

    // Map aRect = resultList[i]["rect"];
    // rectSize = aRect["w"] * aRect["h"];
    // if (rectSize > rectMax) {
    //   rectMax = rectSize;
    //   biggestRect = aRect;
    // }
    // }
    // if (biggestRect == null) {}
    // }
    // return biggestRect;

    if (resultList.isNotEmpty) {
      biggestRect = resultList[0]["boundingBox"];
    }

    return biggestRect;
  }

  Direction_EN _directionFinder(Map rect, int width, int height) {
    // double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;

    double x, y, w, h, screenCenterX, screenCenterY, rectCenterX, rectCenterY;
    x = rect["left"] * width;
    y = rect["top"] * height;
    w = rect["width"] * width;
    h = rect["height"] * height;
    screenCenterX = width / 2;
    screenCenterY = height / 2;
    rectCenterX = x + w / 2;
    rectCenterY = y + h / 2;

    // TODO: Add Error Margin
    // Check first horizontal
    if (rectCenterX > screenCenterX) {
      return Direction_EN.right;
    } else if (rectCenterX < screenCenterX) {
      return Direction_EN.left;
    }

    //Then only check vertical
  }
}
