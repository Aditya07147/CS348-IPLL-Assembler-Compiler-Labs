# nanoC Syntax Analyzer (Parser)

**Course:** CS348: Implementation of Programming Languages Lab  
**Name:** Aditya Shukla 
**Roll Number:** 230101115

## Overview

A complete Lexical and Syntactic Analyzer for the nanoC language (a subset of ISO/IEC 9899:1999 C standard), built with Flex and Bison. Validates syntax of source files and reports errors with specific line numbers and lexemes.

## Files

- `lexer_nanoc.l` - Flex lexical specification
- `parser_nanoc.y` - Bison parser specification
- `Makefile` - Build automation
- `test.nc` - Test file with valid nanoC code
- `README.md` - Documentation

## Grammar & Lexical Modifications

To ensure a robust and functional compiler front-end that mirrors standard C behavior, the following technical modifications were implemented:

1. **Top-Level Root Rule:** Implemented a recursive `translation_unit` and `function_definition` rule chain. This allows the parser to accept a complete source file.
2. **Dangling Else Resolution:** Resolved the inherent Shift/Reduce conflict of nested `if-else` statements. By using `%nonassoc` precedence levels (`LOWER_THAN_ELSE` and `ELSE`) and the `%prec` directive, the parser is forced to follow the standard C convention of attaching an `else` to the nearest preceding `if`.
3. **Lexical Support for Zero:** Modified the `integer_constant` regular expression to include `0`. This ensures the lexer recognizes zero as a valid constant.
4. **Ellipsis Token:** Introduced a dedicated `ELLIPSIS` token in the Lexer to match `...`. This was integrated into the grammar rules.
5. **Advanced Error Reporting:** Integrated Flex's `%option yylineno` with the Bison `yyerror()` function.

## Build & Run

Compile:
make

Run tests:
./a.out < test.nc

Clean:
make clean

