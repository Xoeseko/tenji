import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as imageLib;
import 'package:tenji/TxtToSpeech.dart';
import 'package:tflite/tflite.dart';

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
  TxtToSpeech tts; 

  @override
  void initState() {
    super.initState();
    tts = new TxtToSpeech();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
          color: Colors.black,
          child: Row(
            children: <Widget>[
              tts.languages != null ? tts.languageDropDownSection() : Container(),
              FloatingActionButton(onPressed: () async => await tts.speak('upward')),

            ],
          )),
    );
  }
}
