file = solveSudokuWithSAT

$(file): $(file).pl
	swipl -O -g main --stand_alone=true -o $(file) -c $(file).pl

.PHONY: clean

run: $(file)
	./solveSudokuWithSAT

check: run
	cat sudokuRes | python sudokuChecker.py

clean:
	rm -f clauses header infile.cnf model solveSudokuWithSAT sudokuRes
