import 'package:flutter/material.dart';
import 'package:tenji/TxtToSpeech.dart';

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

          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: FloatingActionButton(
                    child: Icon(Icons.arrow_circle_up),
                    onPressed: () async => await tts.speak(Direction_EN.up)),
                flex: 2,
                fit: FlexFit.tight,
              ),
              Flexible(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FloatingActionButton(
                          child: Icon(Icons.arrow_right_rounded),
                          onPressed: () async =>
                              await tts.speak(Direction_EN.right)),
                      FloatingActionButton(
                          child: Icon(Icons.arrow_left_rounded),
                          onPressed: () async =>
                              await tts.speak(Direction_EN.left))
                    ],
                  ),
                ),
                flex: 2,
                fit: FlexFit.tight,
              ),
              Flexible(
                child: FloatingActionButton(
                    child: Icon(Icons.arrow_left_rounded),
                    onPressed: () async => await tts.speak(Direction_EN.down)),
                flex: 2,
                fit: FlexFit.tight,
              ),
            ],
          )),
    );
  }
}
