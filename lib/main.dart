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

class SudokuGame extends StatefulWidget {
  SudokuGame({super.key}) {}

  @override
  State<SudokuGame> createState() => _SudokuGameState();
}

class _SudokuGameState extends State<SudokuGame> {
  late List<List<int>> grid = SudokuGenerator().generateSudoku();
  late List<List<int>> holedGrid =
      _generateHoledGrid(grid, (9 * 9 * .3).toInt());
  late List<List<Cell>> cells = _generateCells();
  late Map<num, num> remainings = _getRemainings();

  Map<num, num> _getRemainings() {
    var r = <num, num>{};

    // check for all 0 in holedGrid
    for (var i = 0; i < holedGrid.length; i++) {
      for (var j = 0; j < holedGrid[i].length; j++) {
        if (holedGrid[i][j] == 0) {
          var value = grid[i][j];
          if (r.containsKey(value)) {
            r[value] = (r[value]! + 1);
          } else {
            r[value] = 1;
          }
        }
      }
    }
    return r;
  }

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
                    cells = _generateCells();
                    this.row = null;
                    this.col = null;
                    remainings = _getRemainings();
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
            Cell shownCell = Cell(
              value: grid[row as int][col as int],
              isUserInput: true,
            );
            shownCell.show = true;
            cells[row as int][col as int] = shownCell;
            if (remainings[number] != null) {
              remainings[number] = remainings[number]! - 1;
            }
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
        Expanded(
          child: LayoutBuilder(builder: (context, constraints) {
            var maxWidth = constraints.maxWidth;
            var maxHeight = constraints.maxHeight;

            var cellSize = min(maxWidth, maxHeight) / 9;

            return SizedBox(
              width: cellSize * 9,
              height: cellSize * 9,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var row = 0; row < grid.length; row++)
                    Center(
                      child: Row(
                        children: [
                          for (var col = 0; col < grid[0].length; col++)
                            GestureDetector(
                              onTap: handleOnTap(row, col),
                              child: Container(
                                // padding: EdgeInsets.all(20.0),
                                width: cellSize,
                                height: cellSize,
                                alignment: Alignment.center,
                                // color: this.row == row && this.col == col
                                //     ? Colors.blue
                                //     : Colors.transparent,
                                decoration: BoxDecoration(
                                  color: this.row == row && this.col == col
                                      ? Colors.blue
                                      : Colors.transparent,
                                  border: handleDisplayBorder(row, col, 3),
                                ),
                                child: cells[row][col],
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        Container(
          height: 100,
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            children: [
              LayoutBuilder(builder: (context, constraints) {
                var maxWidth = constraints.maxWidth;
                var maxHeight = constraints.maxHeight;

                var size = min(maxWidth, maxHeight) / 9;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i in List.generate(9, (index) => index + 1))
                      Container(
                        width: size,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: remainings[i] != null && remainings[i]! > 0
                            ? Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: handleAnswerTap(i),
                                    style: ButtonStyle(
                                        alignment: Alignment.center,
                                        // reset padding to avoid misalignment of text content
                                        padding:
                                            MaterialStateProperty.resolveWith(
                                                (states) =>
                                                    const EdgeInsets.all(0)),
                                        backgroundColor:
                                            MaterialStateColor.resolveWith(
                                                (states) => Colors.white),
                                        side: MaterialStateProperty.resolveWith(
                                            (states) => const BorderSide(
                                                color: Colors.black26,
                                                width: 1))),
                                    child: Text(
                                      i.toString(),
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 18),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      remainings[i].toString(),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Border handleDisplayBorder(int row, int col, int gsize) {
    var baseSide = const BorderSide(
      color: Colors.black54,
      style: BorderStyle.solid,
      width: 1,
    );
    BorderSide top, left, bottom, right;
    const double maxBorderWidth = 2;
    var targetBorder = baseSide.copyWith(width: maxBorderWidth);

    var gx = col ~/ gsize;
    var gy = row ~/ gsize;
    var rx = col % gsize;
    var ry = row % gsize;

    // check if border is at edge of group

    // check if cell is at left edge of group
    if (rx == 0) {
      left = targetBorder;
    } else {
      left = baseSide;
    }

    // check if cell is at right of the group
    if (rx == gsize - 1) {
      right = targetBorder;
    } else {
      right = baseSide;
    }

    // check if cell is at top
    if (ry == 0) {
      top = targetBorder;
    } else {
      top = baseSide;
    }

    // check if cell is bottom
    if (ry == gsize - 1) {
      bottom = targetBorder;
    } else {
      bottom = baseSide;
    }

    var border = Border(top: top, left: left, right: right, bottom: bottom);

    return border;
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

  List<List<Cell>> _generateCells() {
    var cells = List.generate(
        9,
        (row) => List.generate(
            9,
            (col) => Cell(
                value: holedGrid[row][col],
                isUserInput: holedGrid[row][col] == 0)));

    return cells;
  }
}

class Cell extends StatelessWidget {
  Cell({super.key, required this.value, required this.isUserInput});

  final int value;
  final bool isUserInput;
  bool show = false;

  @override
  Widget build(BuildContext context) {
    return Text(
      value.toString(),
      style: TextStyle(
        color: !isUserInput
            ? Colors.black87
            : show
                ? Colors.blue
                : Colors.transparent,
        fontWeight: isUserInput ? FontWeight.normal : FontWeight.bold,
        fontSize: 18,
        // color: holedGrid[row][col] == 0 ? Colors.transparent : Colors.black87,
      ),
    );
    ;
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