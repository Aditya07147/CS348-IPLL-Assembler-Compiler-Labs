# SIC Assembler Project  
# Author: Aditya Shukla
### Roll No: 230101115

This project implements both:

- One-Pass Assembler  
- Two-Pass Assembler  
for the **SIC (Simplified Instructional Computer)** architecture.

## 1. Project Overview

The assembler converts SIC assembly language programs into object programs containing:

- Header Record (H)
- Text Records (T)
- End Record (E)

## 2. Project Files

### Source Files

| File Name             | Description                       |
| --------------------- | --------------------------------- |
| one_pass_assembler.c  | One-pass assembler implementation |
| two_pass_assembler.c  | Two-pass assembler implementation |
| opcodes.txt           | Opcode table                      |
| input.txt             | Input assembly program            |
| Makefile              | Build automation                  |
| README.md             | Documentation                     |

### Generated Files

| File Name                     | Description                  |
| ----------------------------- | ---------------------------- |
| output_one_pass.txt           | Object file (One-pass)       |
| output_two_pass.txt           | Object file (Two-pass)       |
| intermediate.txt              | Intermediate file (Two-pass) |


## 3. How to Compile
Use: make
This runs:
- one_pass assembler code
- two_pass assembler code

## 4. How to Run
Run One-Pass Assembler:
make run_one

Run Two-Pass Assembler:
make run_two

## 5. Clean Generated Files
make clean

## 6. SIC Architecture Assumptions

- Instruction size = 3 bytes
- 1 byte opcode + 2 byte address
- Indexed addressing supported
- Maximum text record size = 30 bytes
- Memory simulated = 32 KB


## 7. Conclusion
Both assembler implementations successfully generate valid SIC object programs.
The One-Pass assembler demonstrates dynamic symbol resolution and backpatching.
The Two-Pass assembler demonstrates structured processing using intermediate file generation and final object code production.
