import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped, paused, continued }
enum Direction_EN { upward, downward, right, left }

class TxtToSpeech {
  FlutterTts flutterTts;
  dynamic languages;
  String language = "en-US";
  double volume = 1.0;
  double pitch = 1.0;
  double rate = 1.0;

  String _newVoiceText;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  get isPaused => ttsState == TtsState.paused;

  get isContinued => ttsState == TtsState.continued;

  TxtToSpeech() {
    initTts();
  }

  initTts() {
    flutterTts = FlutterTts();

    //_getLanguages();
    setLang();

    _getEngines();

    flutterTts.setStartHandler(() {
      print("Playing");
      ttsState = TtsState.playing;
    });

    flutterTts.setCompletionHandler(() {
      print("Complete");
      ttsState = TtsState.stopped;
    });

    flutterTts.setCancelHandler(() {
      print("Cancel");
      ttsState = TtsState.stopped;
    });

    if (kIsWeb || Platform.isIOS) {
      flutterTts.setPauseHandler(() {
        print("Paused");
        ttsState = TtsState.paused;
      });

      flutterTts.setContinueHandler(() {
        print("Continued");
        ttsState = TtsState.continued;
      });
    }

    flutterTts.setErrorHandler((msg) {
      print("error: $msg");
      ttsState = TtsState.stopped;
    });
  }

  setLang() async {
    await flutterTts.setLanguage("en-US");
  }

  Future _getLanguages() async {
    if (languages != null) {
      languages = flutterTts.getLanguages;
    }
  }

  Future _getEngines() async {
    var engines = await flutterTts.getEngines;
    if (engines != null) {
      for (dynamic engine in engines) {
        print(engine);
      }
    }
  }

  Future speak(String s) async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (_newVoiceText != null) {
      if (_newVoiceText.isNotEmpty) {
        await flutterTts.awaitSpeakCompletion(true);
        await flutterTts.speak(s.toString());
      }
    }
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) {
      ttsState = TtsState.stopped;
    }
  }

  Future _pause() async {
    var result = await flutterTts.pause();
    if (result == 1) {
      ttsState = TtsState.paused;
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
  }

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems() {
    var items = List<DropdownMenuItem<String>>();
    for (dynamic type in languages) {
      items.add(
          DropdownMenuItem(value: type as String, child: Text(type as String)));
    }
    return items;
  }

  void changedLanguageDropDownItem(String selectedType) {
    language = selectedType;
    flutterTts.setLanguage(language);
  }

  void _onChange(String text) {
    _newVoiceText = text;
  }

  // Widget _inputSection() => Container(
  //     alignment: Alignment.topCenter,
  //     padding: EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
  //     child: TextField(
  //       onChanged: (String value) {
  //         _onChange(value);
  //       },
  //     ));

  // Widget _btnSection() {
  //   if (!kIsWeb && Platform.isAndroid) {
  //     return Container(
  //         padding: EdgeInsets.only(top: 50.0),
  //         child:
  //             Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
  //           _buildButtonColumn(Colors.green, Colors.greenAccent,
  //               Icons.play_arrow, 'PLAY', _speak),
  //           _buildButtonColumn(
  //               Colors.red, Colors.redAccent, Icons.stop, 'STOP', _stop),
  //         ]));
  //   } else {
  //     return Container(
  //         padding: EdgeInsets.only(top: 50.0),
  //         child:
  //             Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
  //           _buildButtonColumn(Colors.green, Colors.greenAccent,
  //               Icons.play_arrow, 'PLAY', _speak),
  //           _buildButtonColumn(
  //               Colors.red, Colors.redAccent, Icons.stop, 'STOP', _stop),
  //           _buildButtonColumn(
  //               Colors.blue, Colors.blueAccent, Icons.pause, 'PAUSE', _pause),
  //         ]));
  //   }
  // }

  Widget languageDropDownSection() {
    return Container(
        padding: EdgeInsets.only(top: 50.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          DropdownButton(
            value: language,
            items: getLanguageDropDownMenuItems(),
            onChanged: changedLanguageDropDownItem,
          )
        ]));
  }
  // Column _buildButtonColumn(Color color, Color splashColor, IconData icon,
  //     String label, Function func) {
  //   return Column(
  //       mainAxisSize: MainAxisSize.min,
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         IconButton(
  //             icon: Icon(icon),
  //             color: color,
  //             splashColor: splashColor,
  //             onPressed: () => func()),
  //         Container(
  //             margin: const EdgeInsets.only(top: 8.0),
  //             child: Text(label,
  //                 style: TextStyle(
  //                     fontSize: 12.0,
  //                     fontWeight: FontWeight.w400,
  //                     color: color)))
  //       ]);
  // }

  // Widget _buildSliders() {
  //   return Column(
  //     children: [_volume(), _pitch(), _rate()],
  //   );
  // }

  // Widget _volume() {
  //   return Slider(
  //       value: volume,
  //       onChanged: (newVolume) {
  //         setState(() => volume = newVolume);
  //       },
  //       min: 0.0,
  //       max: 1.0,
  //       divisions: 10,
  //       label: "Volume: $volume");
  // }

  // Widget _pitch() {
  //   return Slider(
  //     value: pitch,
  //     onChanged: (newPitch) {
  //       setState(() => pitch = newPitch);
  //     },
  //     min: 0.5,
  //     max: 2.0,
  //     divisions: 15,
  //     label: "Pitch: $pitch",
  //     activeColor: Colors.red,
  //   );
  // }

  // Widget _rate() {
  //   return Slider(
  //     value: rate,
  //     onChanged: (newRate) {
  //       setState(() => rate = newRate);
  //     },
  //     min: 0.0,
  //     max: 1.0,
  //     divisions: 10,
  //     label: "Rate: $rate",
  //     activeColor: Colors.green,
  //   );
  // }
}
