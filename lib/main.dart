import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';

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

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _initializeCamera();
  }

  void _initializeCamera() async {
    _topText = 'Waiting for camera initialization\n';
    List<CameraDescription> cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.medium;
    _controller.initialize().then((_) {
      _cameraInitialized = true;
      _topText = 'Camera Initialization complete\n';
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
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
            _cameraInitialized ? Expanded( 
              child: OverflowBox(
                maxWidth: double.infinity,
                child: AspectRatio(aspectRatio: _controller.value.aspectRatio, child: CameraPreview(_controller),)
              )
            )
            : Container(),
          ],
        )
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: print("not yet implemented"),
      //   backgroundColor: Colors.white,
      // ),
    );
  }
}
