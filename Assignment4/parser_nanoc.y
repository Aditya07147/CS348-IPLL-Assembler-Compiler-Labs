%{
	#include<stdio.h>
	#include<stdlib.h>
	int yylex(void);
	void yyerror(char* s);

%}

%token BREAK CASE CHAR CONTINUE DEFAULT DO DOUBLE ELSE FLOAT FOR IF INT LONG
%token RETURN SHORT SIGNED STATIC UNSIGNED VOID WHILE BOOL

%token IDENTIFIER
%token CONSTANT
%token STRING_LITERAL

%token PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN SUB_ASSIGN
%token LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN XOR_ASSIGN OR_ASSIGN
%token ELLIPSIS


%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%start program


%%
/* GRAMMAR RULES  */

program
    : translation_unit
    ;

translation_unit
    : external_declaration
    | translation_unit external_declaration
    ;

external_declaration
    : function_definition
    | declaration
    ;

function_definition
    : declaration_specifiers declarator compound_statement
    ;


/* 1. Expressions */

primary_expression
    : IDENTIFIER
    | CONSTANT
    | STRING_LITERAL
    | '(' expression ')'
    ;

postfix_expression
    : primary_expression
    | postfix_expression '[' expression ']'
    | postfix_expression '(' argument_expression_list_opt ')'
    | postfix_expression INC_OP
    | postfix_expression DEC_OP
    ;

argument_expression_list_opt
    : argument_expression_list
    | /* empty */
    ;

argument_expression_list
    : assignment_expression
    | argument_expression_list ',' assignment_expression
    ;

unary_expression
    : postfix_expression
    | INC_OP unary_expression
    | DEC_OP unary_expression
    | unary_operator cast_expression
    ;

unary_operator
    : '&' | '*' | '+' | '-' | '~' | '!'
    ;

cast_expression
    : unary_expression
    ;

multiplicative_expression
    : cast_expression
    | multiplicative_expression '*' cast_expression
    | multiplicative_expression '/' cast_expression
    | multiplicative_expression '%' cast_expression
    ;

additive_expression
    : multiplicative_expression
    | additive_expression '+' multiplicative_expression
    | additive_expression '-' multiplicative_expression
    ;

shift_expression
    : additive_expression
    | shift_expression LEFT_OP additive_expression
    | shift_expression RIGHT_OP additive_expression
    ;

relational_expression
    : shift_expression
    | relational_expression '<' shift_expression
    | relational_expression '>' shift_expression
    | relational_expression LE_OP shift_expression
    | relational_expression GE_OP shift_expression
    ;

equality_expression
    : relational_expression
    | equality_expression EQ_OP relational_expression
    | equality_expression NE_OP relational_expression
    ;

AND_expression
    : equality_expression
    | AND_expression '&' equality_expression
    ;

exclusive_OR_expression
    : AND_expression
    | exclusive_OR_expression '^' AND_expression
    ;

inclusive_OR_expression
    : exclusive_OR_expression
    | inclusive_OR_expression '|' exclusive_OR_expression
    ;

logical_AND_expression
    : inclusive_OR_expression
    | logical_AND_expression AND_OP inclusive_OR_expression
    ;

logical_OR_expression
    : logical_AND_expression
    | logical_OR_expression OR_OP logical_AND_expression
    ;

conditional_expression
    : logical_OR_expression
    | logical_OR_expression '?' expression ':' conditional_expression
    ;

assignment_expression
    : conditional_expression
    | unary_expression assignment_operator assignment_expression
    ;

assignment_operator
    : '=' | MUL_ASSIGN | DIV_ASSIGN | MOD_ASSIGN | ADD_ASSIGN
    | SUB_ASSIGN | LEFT_ASSIGN | RIGHT_ASSIGN | AND_ASSIGN
    | XOR_ASSIGN | OR_ASSIGN
    ;

expression
    : assignment_expression
    | expression ',' assignment_expression
    ;

constant_expression
    : conditional_expression
    ;


/*2. DECLARATIONS */

declaration
    : declaration_specifiers init_declarator_list_opt ';'
    ;

declaration_specifiers
    : storage_class_specifier declaration_specifiers_opt
    | type_specifier declaration_specifiers_opt
    ;

init_declarator_list_opt
    : init_declarator_list
    | /* empty */
    ;

declaration_specifiers_opt
    : declaration_specifiers
    | /* empty */
    ;

assignment_expression_opt
    : assignment_expression
    | /* empty */
    ;

identifier_list_opt
    : identifier_list
    | /* empty */
    ;

designation_opt
    : designation
    | /* empty */
    ;

init_declarator_list
    : init_declarator
    | init_declarator_list ',' init_declarator
    ;

init_declarator
    : declarator
    | declarator '=' initializer
    ;

storage_class_specifier
    : STATIC
    ;

type_specifier
    : VOID | CHAR | SHORT | INT | LONG | FLOAT | DOUBLE | SIGNED | UNSIGNED | BOOL
    ;

declarator
    : direct_declarator
    ;

direct_declarator
    : IDENTIFIER
    | '(' declarator ')'
    | direct_declarator '[' assignment_expression_opt ']'
    | direct_declarator '(' parameter_type_list ')'
    | direct_declarator '(' identifier_list_opt ')'
    ;

parameter_type_list
    : parameter_list
    | parameter_list ',' ELLIPSIS
    ;

parameter_list
    : parameter_declaration
    | parameter_list ',' parameter_declaration
    ;

parameter_declaration
    : declaration_specifiers declarator
    | declaration_specifiers
    ;

identifier_list
    : IDENTIFIER
    | identifier_list ',' IDENTIFIER
    ;

initializer
    : assignment_expression
    | '{' initializer_list '}'
    | '{' initializer_list ',' '}'
    ;

initializer_list
    : designation_opt initializer
    | initializer_list ',' designation_opt initializer
    ;

designation
    : designator_list '='
    ;

designator_list
    : designator
    | designator_list designator
    ;

designator
    : '[' constant_expression ']'
    ;

/* 3. STATEMENTS  */

statement
    : labeled_statement
    | compound_statement
    | expression_statement
    | selection_statement
    | iteration_statement
    | jump_statement
    ;

labeled_statement
    : IDENTIFIER ':' statement
    | CASE constant_expression ':' statement
    | DEFAULT ':' statement
    ;

compound_statement
    : '{' block_item_list_opt '}'
    ;

block_item_list_opt
    : block_item_list
    | /* empty */
    ;

expression_opt
    : expression
    | /* empty */
    ;

block_item_list
    : block_item
    | block_item_list block_item
    ;

block_item
    : declaration
    | statement
    ;

expression_statement
    : expression_opt ';'
    ;

selection_statement
    : IF '(' expression ')' statement %prec LOWER_THAN_ELSE
    | IF '(' expression ')' statement ELSE statement
    ;

iteration_statement
    : WHILE '(' expression ')' statement
    | DO statement WHILE '(' expression ')' ';'
    | FOR '(' expression_opt ';' expression_opt ';' expression_opt ')' statement
    | FOR '(' declaration expression_opt ';' expression_opt ')' statement
    ;

jump_statement
    : CONTINUE ';'
    | BREAK ';'
    | RETURN expression_opt ';'
    ;

%%

extern int yylineno;
extern char* yytext;


void yyerror(char *s) {
    fprintf(stderr, "Line %d: %s near '%s'\n", yylineno, s, yytext);
}


int main(void) {
    printf("Starting nanoC Parser...\n");
    
    if (yyparse() == 0) {
        printf("SUCCESS: The code is valid nanoC!\n");
    } else {
        printf("FAILURE: The code contains errors.\n");
    }
    
    return 0;
}



