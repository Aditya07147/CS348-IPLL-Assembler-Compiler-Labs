%option yylineno
%option noyywrap

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


FILE *token_file;
FILE *st_file;


struct Node {
    char *name;
    struct Node *next;
};
struct Node *head = NULL;

void insert_st(const char *name) {
    struct Node *temp = head;
    /* Check if idenitifier already there */
    while (temp != NULL) {
        if (strcmp(temp->name, name) == 0) return; 
        temp = temp->next;
    }
    struct Node *new_node = (struct Node *)malloc(sizeof(struct Node));
    new_node->name = strdup(name);
    new_node->next = head;
    head = new_node;
}

void print_st() {
    struct Node *temp = head;
    while (temp != NULL) {
        fprintf(st_file, "%s\n", temp->name);
        temp = temp->next;
    }
}
%}

digit               [0-9]
nonzero_digit       [1-9]
identifier_nondigit [a-zA-Z_]

identifier          {identifier_nondigit}({identifier_nondigit}|{digit})*

integer_constant    {nonzero_digit}{digit}*|0

digit_sequence      {digit}+
fractional_constant ({digit_sequence})?"."{digit_sequence}|{digit_sequence}"."
floating_constant   {fractional_constant}

escape_sequence     \\[\'\"\?\\abfnrtv]

c_char              [^'\\\n]|{escape_sequence}
c_char_sequence     {c_char}+
character_constant  '{c_char_sequence}'

s_char              [^\"\\\n]|{escape_sequence}
s_char_sequence     {s_char}+
string_literal      \"({s_char_sequence})?\"

%%

 /* 1. Comments */
"/*"([^*]|\*+[^*/])*\*+"/"    { /* Ignore multi-line comments */ }

"//".*                  { /* Ignore single line comments */ }

 /* 2. Whitespace */
[ \t\r\n]+              { /* Ignore*/ }

 /* 3. Keywords */
"break"|"default"|"return"|"void"|"case"|"float"|"short"|"double"|"char"|"for"|"signed"|"while"|"else"|"unsigned"|"long"|"_Bool"|"continue"|"if"|"static"|"do"|"int"  { fprintf(token_file, "Line %d: <KEYWORD, %s>\n", yylineno, yytext); }

 /* 4. Identifiers */
{identifier}            { fprintf(token_file, "Line %d: <IDENTIFIER, %s>\n", yylineno, yytext); insert_st(yytext); }

 /* 5. Constants & Strings */
{integer_constant}      { fprintf(token_file, "Line %d: <INTEGER_CONSTANT, %s>\n", yylineno, yytext); }
{floating_constant}     { fprintf(token_file, "Line %d: <FLOATING_CONSTANT, %s>\n", yylineno, yytext); }
{character_constant}    { fprintf(token_file, "Line %d: <CHARACTER_CONSTANT, %s>\n", yylineno, yytext); }
{string_literal}        { fprintf(token_file, "Line %d: <STRING_LITERAL, %s>\n", yylineno, yytext); }

 /* 6. punctuators */
"["|"]"|"("|")"|"{"|"}"|"."|"->"|"++"|"--"|"&"|"*"|"+"|"-"|"~"|"!"|"/"|"%"|"<<"|">>"|"<"|">"|"<="|">="|"=="|"!="|"^"|"|"|"&&"|"||"|"?"|":"|";"|"..."|"="|"*="|"/="|"%="|"+="|"-="|"<<="|">>="|"&="|"^="|"|="|","|"#" { fprintf(token_file, "Line %d: <PUNCTUATOR, %s>\n", yylineno, yytext); }

 /* 7. Handle errors */
.                       { fprintf(token_file, "Line %d: ERROR: Unknown token '%s'\n", yylineno, yytext); }

%%

int main(int argc, char **argv) {
    if (argc < 2) {
        printf("Usage: ./a.out <input_file>\n");
        return 1;
    }

    FILE *input_file = fopen(argv[1], "r");
    if (!input_file) {
        printf("Error opening input file %s\n", argv[1]);
        return 1;
    }

    /* open out files */
    token_file = fopen("tokens.txt", "w");
    st_file = fopen("symbol_table.txt", "w");

    if (!token_file || !st_file) {
        printf("Error creating output files.\n");
        return 1;
    }

    yyin = input_file;
    yylex();

    print_st();

    fclose(input_file);
    fclose(token_file);
    fclose(st_file);

    printf("Lexical analysis complete. Check tokens.txt and symbol_table.txt.\n");
    return 0;
}
