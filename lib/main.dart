// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import 'sudoku_generator.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                const Center(
                  child: Text(
                    "Sudoku",
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: SudokuGame(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Sudoku extends StatefulWidget {
  Sudoku({
    super.key,
  }) {}

  @override
  State<Sudoku> createState() => _SudokuState();
}

class _SudokuState extends State<Sudoku> {
  late List<List<int>> grid = SudokuGenerator().generateSudoku();
  late List<List<int>> holedGrid =
      _generateHoledGrid(grid, (9 * 9 * .3).toInt());

  // _SudokuState() {
  //   grid = SudokuGenerator().generateSudoku();
  //   _prettyGrid(grid);

  //   holedGrid = _SudokuState._generateHoledGrid(grid, (9 * 9 * .3).toInt());
  //   _prettyGrid(holedGrid);
  // }

  static void _prettyGrid(List<List<int>> g) {
    print('------------Pretty------------');
    for (var row in g) {
      print(row);
    }
    print('------------Pretty------------');
  }

  static List<List<int>> _generateHoledGrid(List<List<int>> grid, int amount) {
    var holed = [
      for (var sub in grid) [...sub]
    ];

    var random = Random();

    print(amount);
    int maxRow = 9;
    int maxCol = 9;

    for (var i = 0; i < amount; i++) {
      while (true) {
        int x = random.nextInt(maxCol);
        int y = random.nextInt(maxRow);

        print('balls');

        if (holed[y][x] == 0) continue;

        // replace with 0
        holed[y][x] = 0;

        break;
      }
    }

    return holed;
  }

  void checkComplete() {
    // find all 0 in holed Grid
    var amount = 0;
    for (var i = 0; i < holedGrid.length; i++) {
      for (var j = 0; j < holedGrid[i].length; j++) {
        if (holedGrid[i][j] == 0) amount++;
      }
    }

    if (amount != 0) {
      return;
    }

    // complete
    showDialog(
      context: _context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('WIN!! WOO'),
          content: Text('Won...'),
          actions: [
            TextButton(
                onPressed: () {
                  setState(() {
                    grid = SudokuGenerator().generateSudoku();
                    holedGrid = _generateHoledGrid(grid, (9 * 9 * .3).toInt());
                    this.row = null;
                    this.col = null;
                  });
                  Navigator.of(context).pop();
                },
                child: Text("Restart")),
            TextButton(
                onPressed: () {
                  exit(0);
                },
                child: Text('QUIT'))
          ],
        );
      },
    );
  }

  void Function()? handleAnswerTap(int number) {
    return () {
      if (row != null && col != null) {
        // check if same
        if (number == grid[row as int][col as int]) {
          // answer is correct
          setState(() {
            holedGrid[row as int][col as int] = number;
            print('Correct!');
            row = null;
            col = null;
            checkComplete();
          });
        } else {
          showDialog(
            context: _context,
            builder: (context) {
              return AlertDialog(
                title: Text('Wong'),
                content: Text('Wong answer'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Oh no!'),
                  )
                ],
              );
            },
          );
        }
      }
    };
  }

  late BuildContext _context;

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Column(
      children: [
        Column(
          children: [
            for (var row = 0; row < grid.length; row++)
              Center(
                child: Row(
                  children: [
                    for (var col = 0; col < grid[0].length; col++)
                      GestureDetector(
                        onTap: handleOnTap(row, col),
                        child: Container(
                          padding: EdgeInsets.all(20.0),
                          // color: this.row == row && this.col == col
                          //     ? Colors.blue
                          //     : Colors.transparent,
                          decoration: BoxDecoration(
                            color: this.row == row && this.col == col
                                ? Colors.blue
                                : Colors.transparent,
                            border: Border.all(
                                color: Colors.black,
                                style: BorderStyle.solid,
                                width: 1),
                          ),
                          child: Text(holedGrid[row][col].toString(),
                              style: TextStyle(
                                color: holedGrid[row][col] == 0
                                    ? Colors.transparent
                                    : Colors.black87,
                              )),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
        Row(
          children: [
            for (var i in List.generate(9, (index) => index + 1))
              ElevatedButton(
                onPressed: handleAnswerTap(i),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateColor.resolveWith((states) => Colors.blue),
                ),
                child: Text(
                  i.toString(),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  int? row;

  int? col;

  void Function()? handleOnTap(int row, int col) {
    return () {
      setState(() {
        this.row = row;
        this.col = col;
      });
      print("Row $row, Col: $col");
    };
  }
}

class Cell extends StatelessWidget {
  const Cell({super.key, required this.value, required this.isUserInput});

  final int value;
  final bool isUserInput;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Text(value.toString());
  }
}

 // static List<List<int>> _generateGrid() {
  //   int rows = 9;
  //   int cols = 9;

  //   Random random = Random();

  //   List<List<int>> grid =
  //       List.generate(rows, (index) => List.generate(cols, (cindex) => 0));

  //   print(grid);
  //   const gsize = 3;

  //   _fillDiagonalGroup(grid, rows, cols, gsize);

  //   for (var gy = 0; gy < rows ~/ gsize; gy++) {
  //     for (var gx = 0; gx < cols ~/ gsize; gx++) {
  //       for (var i = 0; i < gsize * gsize; i++) {
  //         var y = i ~/ gsize + gy * gsize;
  //         var x = i % gsize + gx * gsize;

  //         if (grid[y][x] != 0) continue;

  //         // get group taken values
  //         var gtaken = _checkGroupTaken(grid, x, y, gsize);
  //         // var rtaken = List<int>.generate(rows, (index) => grid[y][index]);

  //         // check col
  //         var ctaken = List<int>.generate(cols, (index) => grid[index][x]);

  //         // pick random number
  //         // check if number exists on same row
  //         // check if number exists on same group

  //         var rtaken = List<int>.generate(rows, (index) => grid[y][index]);

  //         var all = List.generate(rows, (index) => index + 1);

  //         while (true) {
  //           var filtered = all
  //               .where((el) => !([...rtaken, ...ctaken].contains(el)))
  //               .toList();

  //           _prettyGrid(grid);
  //           var rr = filtered[random.nextInt(filtered.length)];

  //           // check rows taken

  //           // if (gtaken.contains(rr) || rtaken.contains(rr)) {
  //           //   print('taken...');
  //           //   continue;
  //           // }

  //           grid[y][x] = rr;

  //           // print(filtered);
  //           break;
  //         }
  //       }
  //     }
  //   }
  //   _prettyGrid(grid);
  //   // for (int i = 0; i < rows; i++) {
  //   //   // print(i);

  //   //   for (int j = 0; j < cols; j++) {
  //   //     if (grid[i][j] != 0) {
  //   //       continue;
  //   //     }

  //   //     // generate random number
  //   //     int r = random.nextInt(9);

  //   //     // check group
  //   //     var gtaken = _checkGroupTaken(grid, j, i, gsize);

  //   //     // check row
  //   //     var rtaken = List<int>.generate(rows, (index) => grid[i][index]);

  //   //     // check col
  //   //     var ctaken = List<int>.generate(cols, (index) => grid[index][j]);

  //   //     // merge all taken
  //   //     var taken = Set<int>.from([
  //   //       // ...gtaken,
  //   //       ...rtaken,
  //   //       ...ctaken,
  //   //     ]).toList();

  //   //     // generate all possible values
  //   //     var all = List<int>.generate(9, (index) => index + 1);

  //   //     // filter out taken values
  //   //     var filtered =
  //   //         List<int>.from(all).where((i) => !taken.contains(i)).toList();
  //   //     print(filtered);
  //   //     while (true) {
  //   //       // select random value from filtered
  //   //       print("i: $i, j: $j");

  //   //       var rr = filtered[random.nextInt(filtered.length)];

  //   //       // if (rtaken.contains(rr)) {
  //   //       //   filtered.remove(rr);
  //   //       //   continue;
  //   //       // }

  //   //       // insert rr to current cursor
  //   //       grid[i][j] = rr;
  //   //       _prettyGrid(grid);
  //   //       // print(filtered);
  //   //       break;
  //   //     }
  //   //   }
  //   // }

  //   // _prettyGrid(grid);

  //   return grid;
  // }

  // static void _fillDiagonalGroup(
  //   List<List<int>> grid,
  //   int rows,
  //   int cols,
  //   int gsize,
  // ) {
  //   Random random = Random();
  //   for (var gy = 0; gy < rows ~/ gsize; gy++) {
  //     for (var i = 0; i < gsize * gsize; i++) {
  //       var y = i ~/ gsize + gy * gsize;
  //       var x = i % gsize + gy * gsize;
  //       var gtaken = _checkGroupTaken(grid, x, y, gsize);
  //       var values = List.generate(gsize * gsize, (index) => index + 1)
  //           .where((element) => !gtaken.contains(element))
  //           .toList();
  //       var rr = values[random.nextInt(values.length)];
  //       grid[y][x] = rr;
  //     }
  //   }
  // }
  
  // static List<int> _checkGroupTaken(
  //     List<List<int>> grid, int x, int y, int size) {
  //   var group = _getGroup(x, y, size);
  //   var row_g = group[1]; // get which group the current cursor belongs to
  //   var col_g = group[0];
  //   ;

  //   // check all number in current group
  //   var taken = List<int>.empty(growable: true);
  //   for (int at_y = size * row_g; at_y < size * row_g + size; at_y++) {
  //     // print(grid);
  //     for (var at_x = size * col_g; at_x < size * col_g + size; at_x++) {
  //       // print(grid[gy][gx]);
  //       taken.add(grid[at_y][at_x]);
  //     }
  //   }

  //   return taken;
  // }

  // static List<int> _getGroup(int x, int y, int size) {
  //   return [x ~/ size, y ~/ size];
  // }

  // static bool _placeNumber(List<List<int>> grid, int number) {
  //   // check for groups
  //   // check for current row
  //   // check for current col
  //   const size = 3;

  //   return false;
  // }