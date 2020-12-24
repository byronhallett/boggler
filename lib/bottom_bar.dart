import 'package:flutter/material.dart';
import 'main.dart';

class BottomBar extends StatelessWidget {
  BottomBar(
      {Key key,
      this.result,
      this.currentWord,
      this.fontSize,
      this.submit,
      this.lastScore})
      : super(key: key);

  final Result result;
  final int lastScore;
  final String currentWord;
  final double fontSize;
  final VoidCallback submit;
  final double footerSize = 80;
  final double edgePadding = 20;

  String get _explaination {
    switch (result) {
      case Result.fail:
        return "Word not found";
      case Result.duplicate:
        return "Word already submitted";
      case Result.pass:
        return "Scored " + lastScore.toString() + " points";
      default:
        return "Tap letters above";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: footerSize,
      color: result == Result.none
          ? Colors.blue
          : result == Result.pass
              ? Colors.green
              : result == Result.duplicate
                  ? Colors.orange
                  : Colors.red,
      padding: EdgeInsets.fromLTRB(edgePadding, 0, edgePadding, 0),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              currentWord.isNotEmpty ? currentWord : _explaination,
              style: TextStyle(fontSize: fontSize),
            ),
            if (currentWord.isNotEmpty)
              FloatingActionButton(
                onPressed: submit,
                tooltip: "submit",
                child: Icon(Icons.check),
              ),
          ],
        ),
      ),
    );
  }
}
