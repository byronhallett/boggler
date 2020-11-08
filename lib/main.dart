import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shake/shake.dart';

void main() {
  runApp(MyApp());
}

const cubes = [
  ["A", "A", "E", "E", "G", "N"],
  ["A", "B", "B", "J", "O", "O"],
  ["A", "C", "H", "O", "P", "S"],
  ["A", "F", "F", "K", "P", "S"],
  ["A", "O", "O", "T", "T", "W"],
  ["C", "I", "M", "O", "T", "U"],
  ["D", "E", "I", "L", "R", "X"],
  ["D", "E", "L", "R", "V", "Y"],
  ["D", "I", "S", "T", "T", "Y"],
  ["E", "E", "G", "H", "N", "W"],
  ["E", "E", "I", "N", "S", "U"],
  ["E", "H", "R", "T", "V", "W"],
  ["E", "I", "O", "S", "S", "T"],
  ["E", "L", "R", "T", "T", "Y"],
  ["H", "I", "M", "N", "U", "Qu"],
  ["H", "L", "N", "N", "R", "Z"],
];

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boggler',
      theme: ThemeData(
        // This is the theme of your application.
        primarySwatch: Colors.deepPurple,
      ),
      home: MyHomePage(title: 'Boggler'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  final Random rand = Random();
  final int gridSize = 4;
  final double fontSize = 32;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _faces;
  ShakeDetector _detector;

  @override
  void initState() {
    super.initState();
    _faces = List.generate(16, (index) => index.toString());
    _detector = ShakeDetector.autoStart(
        onPhoneShake: () {
          _boggle();
        },
        shakeThresholdGravity: 5.0);
  }

  @override
  void dispose() {
    _detector.stopListening();
    super.dispose();
  }

  List<String> randomFaces() {
    return cubes.map((e) => e[widget.rand.nextInt(6)]).toList();
  }

  void _boggle() {
    setState(() {
      // triggers widget build
      _faces = randomFaces();
      _faces.shuffle(widget.rand);
    });
  }

  @override
  Widget build(BuildContext context) {
    // post setState
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            widget.gridSize,
            (outer) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                widget.gridSize,
                (inner) => Text(
                  _faces[outer * widget.gridSize + inner],
                  style: TextStyle(fontSize: widget.fontSize),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _boggle,
        tooltip: 'Boggle',
        child: Icon(Icons.shuffle),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
