// ignore_for_file: avoid_print

import 'dart:math';

class SudokuGenerator {
  late List<List<int>> _grid;

  List<List<int>> generateSudoku() {
    _grid = List.generate(9, (_) => List<int>.filled(9, 0));

    _fillDiagonalBlocks();
    _fillRemaining(0, 3);

    return _grid;
  }

  void _fillDiagonalBlocks() {
    for (int i = 0; i < 9; i += 3) {
      _fillBlock(i, i);
    }
  }

  void _fillBlock(int rowStart, int colStart) {
    var numbers = _randomPermutation(1, 9);
    var index = 0;
    for (int i = rowStart; i < rowStart + 3; i++) {
      for (int j = colStart; j < colStart + 3; j++) {
        _grid[i][j] = numbers[index];
        index++;
      }
    }
  }

  bool _fillRemaining(int row, int col) {
    if (row == 9) {
      return true;
    }

    if (col == 9) {
      return _fillRemaining(row + 1, 0);
    }

    if (_grid[row][col] != 0) {
      return _fillRemaining(row, col + 1);
    }

    for (int num = 1; num <= 9; num++) {
      if (_isValid(row, col, num)) {
        _grid[row][col] = num;
        if (_fillRemaining(row, col + 1)) {
          return true;
        }
        _grid[row][col] = 0;
      }
    }

    return false;
  }

  bool _isValid(int row, int col, int num) {
    return (!_usedInRow(row, num) &&
        !_usedInColumn(col, num) &&
        !_usedInBlock(row - row % 3, col - col % 3, num));
  }

  bool _usedInRow(int row, int num) {
    return _grid[row].contains(num);
  }

  bool _usedInColumn(int col, int num) {
    for (int i = 0; i < 9; i++) {
      if (_grid[i][col] == num) {
        return true;
      }
    }
    return false;
  }

  bool _usedInBlock(int rowStart, int colStart, int num) {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (_grid[rowStart + i][colStart + j] == num) {
          return true;
        }
      }
    }
    return false;
  }

  List<int> _randomPermutation(int start, int end) {
    var numbers = List<int>.generate(end - start + 1, (index) => start + index);
    var random = Random();
    for (var i = end; i > start; i--) {
      var j = random.nextInt(i - start + 1) + start;
      var temp = numbers[i - start];
      numbers[i - start] = numbers[j - start];
      numbers[j - start] = temp;
    }
    return numbers;
  }
}
