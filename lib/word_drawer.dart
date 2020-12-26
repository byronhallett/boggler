import 'package:flutter/material.dart';
import 'main.dart';

class WordDrawer extends StatelessWidget {
  final List<String> foundWords;
  final double fontSize;

  const WordDrawer({Key key, this.foundWords, this.fontSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.all(0),
        children: [
          Container(
            height: 95,
            child: DrawerHeader(
              child: Center(
                child: Text(
                  'Found Words',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
            ),
          ),
          ...foundWords
              .map(
                (e) => Center(
                  child: Text(
                    e,
                    style: TextStyle(fontSize: 26, height: 1.3),
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
