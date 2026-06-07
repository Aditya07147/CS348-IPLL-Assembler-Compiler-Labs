CC = gcc
FLEX = flex
ROLL = 230101115

all: lex.yy.c
	$(CC) lex.yy.c -o a.out -lfl

lex.yy.c: lexer_nanoc.l
	$(FLEX) lexer_nanoc.l

clean:
	rm -f lex.yy.c a.out tokens.txt symbol_table.txt
