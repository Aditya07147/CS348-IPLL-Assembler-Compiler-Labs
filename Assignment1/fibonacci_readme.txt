Author: Aditya Shukla
Roll No: 230101115
Date: 3 Feb 2026

The program calculates and displays the fibonacci numbers, each on a separate line,until the carry flag is set.

I stored the initial fibonacci numbers x=1 and y=1 in memory.
Then ,they were added and stored in memory variable named nextnum.

loop:
If carry flag is set, I jump to end_the_program.
Else
print(nextnum)
x=y;
y=nextnum;
nextnum=x+y;
jmp to loop.

To run the program:
nasm -f elf32 T1_230101115.asm -o prog.o
gcc -m32 prog.o -o prog
./prog

