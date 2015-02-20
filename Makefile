CC        := g++

CFLAGS    := -std=c++11 -Wall -O3

SOURCES   := $(shell find ./ -name '*.cpp')
INCLUDES  := $(shell find ./ -name '*.h')

EXE       := SAT-Solver
OBJ       := $(addprefix ./,$(SOURCES:./%.cpp=%.o))

all: $(EXE)

$(EXE): $(OBJ)
	$(CC) -o $@ $< $(CFLAGS)

%.o: %.cpp
	$(CC) -c -o $@ $< $(CFLAGS)

.PHONY: clean check-all check-all-time

clean:
	rm -rf *~ *.o $(EXE)

check-all: all
	./filename-toolkit -d problems/ -m ".*\.cnf" -C './SAT-Solver < #@' -l

check-all-time: all
	./filename-toolkit -d problems/ -m ".*\.cnf" -C 'time ./SAT-Solver < #@' -l
