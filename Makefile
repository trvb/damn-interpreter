CC = gcc
CFLAGS =-std=c99 -g
INC=~/flex/libfl.a

all : interpreter
lex.yy.c : interpreter.l
	~/flex/flex interpreter.l
rule.tab.c : rule.y
	~/bison/bin/bison -d -v rule.y
interpreter : lex.yy.c rule.tab.c
	$(CC) $(CFLAGS) lex.yy.c rule.tab.c -o interpreter $(INC)
clean:
	rm -rf interpreter lex.yy.c rule.tab.c *.o
test:
	./interpreter < test.ass

