import 'package:flutter/material.dart';

class Grid extends StatelessWidget {
  const Grid(
      {Key key,
      this.gridSize,
      this.enabledIndices,
      this.letterTapped,
      this.selections,
      this.faces,
      this.fontSize})
      : super(key: key);

  final int gridSize;
  final List<bool> enabledIndices;
  final List<int> selections;
  final void Function(int) letterTapped;
  final List<String> faces;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.red,
          child: Column(
            children: List.generate(
              gridSize,
              (rowId) => Flexible(
                fit: FlexFit.tight,
                child: Container(
                  color: Colors.orange,
                  child: Row(
                    children: List.generate(
                      gridSize,
                      (cellId) {
                        int idx = rowId * gridSize + cellId;
                        return Flexible(
                          fit: FlexFit.tight,
                          child: GestureDetector(
                            onTap: () =>
                                enabledIndices[idx] ? letterTapped(idx) : null,
                            child: Container(
                              margin: const EdgeInsets.all(8.0),
                              color: selections.contains(idx)
                                  ? Colors.blue
                                  : enabledIndices[idx]
                                      ? Colors.green
                                      : Colors.orange,
                              child: Center(
                                child: Text(
                                  faces[idx],
                                  style: TextStyle(
                                    fontSize: fontSize,
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
    );
  }
}
