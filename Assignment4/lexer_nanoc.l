%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"  
%}

%option yylineno
%x MULTI_COMMENT

/*  DEFINITIONS  */
digit               [0-9]
nonzero_digit       [1-9]
identifier_nondigit [a-zA-Z_]

identifier          {identifier_nondigit}({identifier_nondigit}|{digit})*
integer_constant    {nonzero_digit}{digit}*|0

digit_sequence      {digit}+
fractional_constant ({digit_sequence}?"."{digit_sequence})|({digit_sequence}".")
floating_constant   {fractional_constant}

escape_sequence     \\[\'\"\?\\abfnrtv]
c_char [^'\\\n]|{escape_sequence}
c_char_sequence     {c_char}+
character_constant  '{c_char_sequence}'

s_char              [^\"\\\n]|{escape_sequence}
s_char_sequence     {s_char}+
string_literal      \"{s_char_sequence}?\"

%%
    /*  COMMENTS */
"//".*                  { /* Ignore single-line comments */ }
"/*"                    { BEGIN(MULTI_COMMENT); }
<MULTI_COMMENT>"*/"     { BEGIN(INITIAL); }
<MULTI_COMMENT>.        { /* Ignore */ }
<MULTI_COMMENT>\n       { /* Ignore */ }

    /*  KEYWORDS  */
"break"     { return BREAK; }
"case"      { return CASE; }
"char"      { return CHAR; }
"continue"  { return CONTINUE; }
"default"   { return DEFAULT; }
"do"        { return DO; }
"double"    { return DOUBLE; }
"else"      { return ELSE; }
"float"     { return FLOAT; }
"for"       { return FOR; }
"if"        { return IF; }
"int"       { return INT; }
"long"      { return LONG; }
"return"    { return RETURN; }
"short"     { return SHORT; }
"signed"    { return SIGNED; }
"static"    { return STATIC; }
"unsigned"  { return UNSIGNED; }
"void"      { return VOID; }
"while"     { return WHILE; }
"_Bool"     { return BOOL; }

    /* IDENTIFIERS AND CONSTANTS  */
{identifier}         { return IDENTIFIER; }
{integer_constant}   { return CONSTANT; }
{floating_constant}  { return CONSTANT; }
{character_constant} { return CONSTANT; }
{string_literal}     { return STRING_LITERAL; }

    /* MULTI-CHARACTER PUNCTUATORS  */
"->"        { return PTR_OP; }
"++"        { return INC_OP; }
"--"        { return DEC_OP; }
"<<"        { return LEFT_OP; }
">>"        { return RIGHT_OP; }
"<="        { return LE_OP; }
">="        { return GE_OP; }
"=="        { return EQ_OP; }
"!="        { return NE_OP; }
"&&"        { return AND_OP; }
"||"        { return OR_OP; }
"*="        { return MUL_ASSIGN; }
"/="        { return DIV_ASSIGN; }
"%="        { return MOD_ASSIGN; }
"+="        { return ADD_ASSIGN; }
"-="        { return SUB_ASSIGN; }
"<<="       { return LEFT_ASSIGN; }
">>="       { return RIGHT_ASSIGN; }
"&="        { return AND_ASSIGN; }
"^="        { return XOR_ASSIGN; }
"|="        { return OR_ASSIGN; }
"..."       { return ELLIPSIS; }

    /*  SINGLE-CHARACTER PUNCTUATORS  */
[;{}(),\[\]=+\-*/%<>!&|^?:.~]  { return yytext[0]; }

    /*  WHITESPACE  */
[ \t\n]+    { /* Ignore whitespace */ }

    /*  CATCH-ALL  */
.           { printf("Lexical Error at line %d: Unknown character %s\n", yylineno, yytext); return 1; }

%%

int yywrap() {
    return 1;
}
