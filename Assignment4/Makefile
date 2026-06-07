# Makefile for nanoC Parser
all: a.out

a.out: lex.yy.c y.tab.c
	gcc lex.yy.c y.tab.c -lfl

lex.yy.c: lexer_nanoc.l y.tab.h
	flex lexer_nanoc.l

y.tab.c y.tab.h: parser_nanoc.y
	yacc -d parser_nanoc.y

# Clean up generated files
clean:
	rm -f lex.yy.c y.tab.c y.tab.h a.out
