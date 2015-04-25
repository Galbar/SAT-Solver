#! /bin/sh

make
./solveSudokuWithSAT
cat sudokuRes | python sudokuChecker.py