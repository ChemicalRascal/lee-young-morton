CC  	= g++
CFLAGS	= -Wall
LFLAGS	= -lsdsl -ldivsufsort -ldivsufsort64
RM	= rm
RMFLAGS	= -f
MKDIR	= mkdir
MDFLAGS	= -p

AVX2FLAG= -mavx2 -mbmi2

PROG	= qtree_testbench
PROGOBJ = bin/qtree_testbench.obj
DEPS	= src/bitseq.hpp src/qsi.hpp src/leeyang.hpp src/read_csv.h \
	  src/bit_qtree.hpp src/offset_qtree.hpp
HDEPS	= src/k2_range.hpp src/offset_finkel_bentley.hpp
OBJ	= bin/bitseq.obj bin/qsi.obj bin/leeyang.obj bin/read_csv.o \
	  bin/bit_qtree.obj
CFILES	= src/bitseq.cpp src/qsi.cpp src/leeyang.cpp src/read_csv.c \
	  src/qtree_testbench.cpp src/bit_qtree.cpp
BINDIR	= bin/

PROG2	= gen_queries
CFILES2	= src/gen_queries.cpp

PROG3	= gen_queries_percent
CFILES3	= src/gen_queries_percent.cpp

PROG4	= chazelle_reduce
CFILES4	= src/chazelle_reduce.cpp

PROG5	= check_qsi
CFILES5	= src/check_qsi.cpp

VGRIND	= valgrind
VGFLAG	= --leak-check=full -v
VGCFLAG = -g -O0

DBG	= gdb
DBGFLAG	= -q

.PHONY: default
default: $(PROG)

.PHONY: all
all: $(PROG) $(PROG2) $(PROG3) $(PROG4)

.PHONY: avx2
avx2: clean avx2_set all

$(BINDIR):
	$(MKDIR) $(MDFLAGS) $(BINDIR)

bin/%.o: src/%.c $(DEPS) | $(BINDIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(PROGOBJ): src/qtree_testbench.cpp $(DEPS) $(HDEPS) | $(BINDIR)
	$(CC) $(CFLAGS) -c $< -o $@

bin/%.obj: src/%.cpp $(DEPS) | $(BINDIR)
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: val_set
val_set:
	$(eval CFLAGS += $(VGCFLAG))

.PHONY: avx2_set
avx2_set:
	$(eval CFLAGS += $(AVX2FLAG))

.PHONY: val_build
val_build: clean val_set $(PROG)

.PHONY: val
val:	val_build
	$(VGRIND) $(VGFLAG) ./$(PROG)

.PHONY: gdb
gdb:	val_build
	$(DBG) $(DBGFLAG) ./$(PROG)

$(PROG): $(OBJ) $(PROGOBJ) $(HDEPS)
	$(CC) $(CFLAGS) $^ -o $@ $(LFLAGS)

$(PROG2): $(CFILES2) $(OBJ)
	$(CC) $(CFLAGS) $^ -o $@ $(LFLAGS)

$(PROG3): $(CFILES3) $(OBJ)
	$(CC) $(CFLAGS) $^ -o $@ $(LFLAGS)

$(PROG4): $(CFILES4) $(OBJ)
	$(CC) $(CFLAGS) $^ -o $@ $(LFLAGS)

$(PROG5): $(CFILES5) $(OBJ)
	$(CC) $(CFLAGS) $^ -o $@ $(LFLAGS)

mwe: src/mwe.cpp
	$(CC) $(CFLAGS) $^ -o $@ $(LFLAGS)

.PHONY: clean
clean:
	$(RM) $(RMFLAGS) $(PROG) $(OBJ) $(PROGOBJ) vgcore.* $(PROG2) $(PROG3)

.PHONY: clean_progobj
clean_progobj:
	$(RM) $(RMFLAGS) $(PROGOBJ)
