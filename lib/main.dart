import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as imageLib;
// import 'package:tflite/tflite.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'RectPainter.dart';

void main() => runApp(TenjiApp());

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
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                                  CustomPaint(painter: RectPainter(_savedRect))
                                ]),
                          )))
                  : Container(),
            ],
          )),
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
    setState(() {
      _savedRect = results[0];
    });
    _isDetecting = false;
  }

  static imageLib.Image _convertCameraImage(CameraImage image) {
    int width = image.width;
    int height = image.height;
    // imglib -> Image package from https://pub.dartlang.org/packages/image
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
    var request = new http.MultipartRequest("POST", _url)
      ..files.add(http.MultipartFile.fromBytes(
          'cameraFeedSingleFrame', _convertCameraImage(image).getBytes(),
          contentType: MediaType.parse('multipart/form-data')));

    // request.headers.update('Content-Type', (value) => 'multipart/form-data');

    // This function is entered but there is no rectangle displayed.
    var response = await _client.send(request);
    print((await http.Response.fromStream(response)).body);
    // Tflite.runModelOnFrame(
    //   bytesList: image.planes.map((plane) {
    //     return plane.bytes;
    //   }).toList(),
    // numResults: 4,
    // model: "SBB_MOBILE",
    // TODO: Check whether necessary to resize image like in the SBB example in python.
    // imageHeight: image.height,
    // imageWidth: image.width,
    // imageMean: 127.5,
    // imageStd: 127.5,
    // threshold: 0.2,
    // TODO: Check other parameters necessary
    // );

    // List<String> possibleDog = ['dog', 'cat', 'bear', 'teddy bear', 'sheep'];
    List<String> possibleLabels = [
      'Door',
      'Open door',
      'Door handle',
      'Door button'
    ];

    // TODO:  FIND AN ALTERNATIVE TO RETURNING THE BIGGEST MATCH SHOULD RETURN DOOR OR BUTTON
    // Map biggestRect;
    // double rectSize, rectMax = 0.0;
    // for (int i = 0; i < resultList.length; i++) {
    //   if (possibleLabels.contains(resultList[i]["detectedClass"])) {
    //     // if (possibleLabels.contains(resultList[i]["label"])) {
    //     Map aRect = resultList[i]["rect"];
    //     rectSize = aRect["w"] * aRect["h"];
    //     if (rectSize > rectMax) {
    //       rectMax = rectSize;
    //       biggestRect = aRect;
    //     }
    //   }
    // }
    // return biggestRect;
  }
}
