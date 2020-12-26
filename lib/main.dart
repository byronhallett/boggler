import 'dart:async';
import 'dart:math';

import 'package:boggler/constants.dart';
import 'package:boggler/word_drawer.dart';
import 'package:boggler/grid.dart';
import 'package:boggler/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

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

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum Result { none, fail, pass, duplicate, short }

class _MyHomePageState extends State<MyHomePage> {
  List<String> _faces;
  List<int> _selections = List.empty(growable: true);
  List<bool> _enabledIndices;
  PlatformAssetBundle _bundle;
  List<String> _dict;
  Result _lastResult = Result.none;
  List<String> _foundWords = List.empty(growable: true);
  int _lastScore = 0;
  bool _lockInteraction = false;

  @override
  void initState() {
    super.initState();
    // lock orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _faces =
        List.generate(pow(widget.gridSize, 2), (index) => index.toString());
    _enabledIndices = List.filled(pow(widget.gridSize, 2), true);
    _boggle();
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  List<String> randomFaces() {
    return cubes.map((e) => e[widget.rand.nextInt(6)]).toList();
  }

  void _shuffleTapped() {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text(
                "Start a new game?",
                style: TextStyle(fontSize: 24),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "No...",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _multiBoggle();
                  },
                  child: Text(
                    "Yes!",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ));
  }

  void _multiBoggle() {
    // disable interaction
    setState(() {
      _lockInteraction = true;
    });
    int elapsed = 0;
    int period = 100;
    int total = 1500;
    Timer.periodic(Duration(milliseconds: period), (timer) {
      if (elapsed >= total) {
        // break the timer loop
        timer.cancel();
        setState(() {
          _lockInteraction = false;
        });
        return;
      }
      _boggle();
      elapsed += period;
    });
  }

  void _boggle() {
    setState(() {
      _faces = randomFaces();
      _faces.shuffle(widget.rand);
      _selections.clear();
      _lastResult = Result.none;
      _foundWords.clear();
      _setAllowedButtons();
    });
  }

  void _letterTapped(int selection) {
    if (_lockInteraction) return;
    // undo logic
    int oldIndex = _selections.indexOf(selection);
    bool undo = oldIndex >= 0;
    if (undo) _selections.removeRange(oldIndex, _selections.length);
    // select logic
    setState(() {
      _lastResult = Result.none;
      if (!undo) _selections.add(selection);
      _setAllowedButtons();
    });
  }

  void _submit() {
    String current = _currentWord;
    bool short = current.length < 3;
    bool found = _dict.contains(current);
    bool duplicate = _foundWords.contains(current);
    // if not in found, add
    if (found && !duplicate && !short) {
      _foundWords.add(current);
      _foundWords.sort();
    }
    setState(() {
      _lastScore = scoreArray[current.length];
      _lastResult = found
          ? duplicate
              ? Result.duplicate
              : short
                  ? Result.short
                  : Result.pass
          : Result.fail;
      _selections.clear();
      _setAllowedButtons();
    });
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
    }
    // set all selections true
    _selections.forEach((element) {
      _enabledIndices[element] = true;
    });
  }

  void _loadDictionary(BuildContext context) async {
    if (_bundle != null) return;
    _bundle = DefaultAssetBundle.of(context);
    String dictString =
        await _bundle.loadString('assets/collins.txt', cache: true);
    _dict = dictString.split("\n");
    _dict = _dict.map((e) => e.trim()).toList();
  }

  int get _currentScore {
    // return 1;
    return _foundWords
        .map((word) => word.length > scoreArray.length
            ? scoreArray.last
            : scoreArray[word.length])
        .fold(0, (agg, score) => agg + score);
  }

  String get _currentWord {
    return _selections.map((e) => _faces[e]).join("");
  }

  @override
  Widget build(BuildContext context) {
    _loadDictionary(context);
    print(_lockInteraction);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      endDrawer: WordDrawer(
        foundWords: _foundWords,
        fontSize: widget.fontSize,
      ),
      body: Grid(
        enabledIndices: _enabledIndices,
        faces: _faces,
        fontSize: widget.fontSize,
        gridSize: widget.gridSize,
        letterTapped: _lockInteraction ? null : _letterTapped,
        selections: _selections,
        score: _currentScore,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _lockInteraction ? null : _shuffleTapped,
        tooltip: 'Boggle',
        child: Icon(Icons.shuffle),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      bottomNavigationBar: BottomBar(
        currentWord: _currentWord,
        fontSize: widget.fontSize,
        result: _lastResult,
        submit: _submit,
        lastScore: _lastScore,
      ),
    );
  }
}
