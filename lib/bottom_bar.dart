import 'package:flutter/material.dart';
import 'main.dart';

class BottomBar extends StatelessWidget {
  BottomBar(
      {Key key,
      this.result,
      this.currentWord,
      this.score,
      this.fontSize,
      this.submit})
      : super(key: key);

  final Result result;
  final String currentWord;
  final int score;
  final double fontSize;
  final VoidCallback submit;
  final double footerSize = 80;
  final double edgePadding = 20;

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
              currentWord.isEmpty ? "score: " + score.toString() : currentWord,
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
