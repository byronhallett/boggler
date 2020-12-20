import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:shake/shake.dart';

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
  final int gridSize = 4; // need the static dice defined above
  final double fontSize = 32;
  final double footerSize = 80;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum Result { none, fail, pass }

class _MyHomePageState extends State<MyHomePage> {
  List<String> _faces;
  List<int> _selections = List.empty(growable: true);
  List<bool> _enabledIndices;
  // ShakeDetector _detector;
  PlatformAssetBundle _bundle;
  List<String> _dict;
  Result _lastResult = Result.none;

  @override
  void initState() {
    super.initState();

    _faces =
        List.generate(pow(widget.gridSize, 2), (index) => index.toString());
    _enabledIndices = List.filled(pow(widget.gridSize, 2), true);

    // _detector = ShakeDetector.autoStart(
    //     onPhoneShake: () {
    //       _boggle();
    //     },
    //     shakeThresholdGravity: 5.0);
  }

  @override
  void dispose() {
    // _detector.stopListening();
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
      _selections.clear();
      _setAllowedButtons();
      _lastResult = Result.none;
    });
  }

  void _letterTapped(int selection) {
    setState(() {
      _lastResult = Result.none;
      _selections.add(selection);
      _setAllowedButtons();
    });
  }

  void _submit() {
    print(_currentWord());
    bool found = _dict.contains(_currentWord());
    setState(() {
      _lastResult = found ? Result.pass : Result.fail;
      _selections.clear();
      _setAllowedButtons();
    });
  }

  String _currentWord() {
    return _selections.map((e) => _faces[e]).join("");
  }

  void _setAllowedButtons() {
    if (_selections.isEmpty) {
      // set all true
      _enabledIndices.fillRange(0, _enabledIndices.length, true);
    } else {
      // set all false
      _enabledIndices.fillRange(0, _enabledIndices.length, false);
      // set true all neighbour of last
      int last = _selections.last;
      int up = last - widget.gridSize;
      int down = last + widget.gridSize;
      [
        if (last % widget.gridSize != 0) up - 1,
        up,
        if ((last + 1) % widget.gridSize != 0) up + 1,
        if (last % widget.gridSize != 0) last - 1,
        if ((last + 1) % widget.gridSize != 0) last + 1,
        if (last % widget.gridSize != 0) down - 1,
        down,
        if ((last + 1) % widget.gridSize != 0) down + 1
      ].forEach((element) {
        if (element >= 0 && element < _enabledIndices.length)
          _enabledIndices[element] = true;
      });
      // set false those in the list
      _selections.forEach((element) {
        _enabledIndices[element] = false;
      });
    }
  }

  void _loadDictionary(BuildContext context) async {
    if (_bundle != null) return;
    _bundle = DefaultAssetBundle.of(context);
    String dictString = await _bundle.loadString('collins.txt', cache: true);
    _dict = dictString.split("\n");
    _dict = _dict.map((e) => e.trim()).toList();
  }

  @override
  Widget build(BuildContext context) {
    _loadDictionary(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.red,
            child: Column(
              children: List.generate(
                widget.gridSize,
                (rowId) => Flexible(
                  fit: FlexFit.tight,
                  child: Container(
                    color: Colors.orange,
                    child: Row(
                      children: List.generate(
                        widget.gridSize,
                        (cellId) {
                          int idx = rowId * widget.gridSize + cellId;
                          return Flexible(
                            fit: FlexFit.tight,
                            child: GestureDetector(
                              onTap: () => _enabledIndices[idx]
                                  ? _letterTapped(idx)
                                  : null,
                              child: Container(
                                margin: const EdgeInsets.all(8.0),
                                color: _selections.contains(idx)
                                    ? Colors.blue
                                    : _enabledIndices[idx]
                                        ? Colors.green
                                        : Colors.orange,
                                child: Center(
                                  child: Text(
                                    _faces[idx],
                                    style: TextStyle(
                                      fontSize: widget.fontSize,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      bottomNavigationBar: Container(
        height: widget.footerSize,
        color: _lastResult == Result.none
            ? Colors.blue
            : _lastResult == Result.fail
                ? Colors.red
                : Colors.green,
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _currentWord(),
                    style: TextStyle(fontSize: widget.fontSize),
                  ),
                ),
              ),
              if (_selections.isNotEmpty)
                FloatingActionButton(
                  onPressed: _submit,
                  tooltip: "submit",
                  child: Icon(Icons.check),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
