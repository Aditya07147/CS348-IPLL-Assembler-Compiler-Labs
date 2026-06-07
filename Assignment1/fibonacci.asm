;Run the program using the following commands
;nasm -f elf32 T1_230101115.asm -o prog.o
;gcc -m32 prog.o -o prog
;./prog


;Declaring printf and scanf to use it for console input and output.
extern printf
extern scanf


;Initialising global variables
section .data
    x dd 1 ;1st Fibonacci number
    y dd 1 ;2nd Fibonacci number
    nextnum dd 0
    fmt_int db '%lld',10,0
    fmt_start db 'Fibonacci Numbers:',10,0
    fmt_end db 'Unsigned addition carry overflow occurred,carry flag was set.',10,0
    fmt_loop db 'Fibonacci number index %d :',0

section .bss


section .text
    global main

main:
;Prologue
    push ebp
    mov ebp,esp

;using it for index of fibonacci number
    mov esi,1

    push fmt_start
    call printf
    add esp,4

    ;printf("Fibonacci number index %d",value)
    push esi
    push fmt_loop
    call printf
    add esp,8
    inc esi

    mov eax,[x]
    ;printf("%lld\n",eax)
    push eax
    push fmt_int
    call printf
    add esp,8


    ;printf("Fibonacci number index %d",value)
    push esi
    push fmt_loop
    call printf
    add esp,8
    inc esi

    mov ebx,[y]
    ;printf("%lld\n",ebx)
    push ebx
    push fmt_int
    call printf
    add esp,8

   ;Next num=x+y
    mov eax,[x]
    mov ebx,[y]
    add eax,ebx
    mov [nextnum],eax

loop:
    ;if(carry flag set) jmp end_program
    jc end_program

    ;printf("Fibonacci number index %d",value)
    push esi
    push fmt_loop
    call printf
    add esp,8
    inc esi

    mov eax,[nextnum]
    ;printf("%lld\n",eax)
    push eax
    push fmt_int
    call printf
    add esp,8

    ;x=y
    ;y=nextnum
    ;nextnum=x+y
    mov eax,[y]
    mov [x],eax
    mov eax,[nextnum]
    mov [y],eax
    mov eax,[x]
    mov ebx,[y]
    add eax,ebx
    mov [nextnum],eax
    jmp loop

end_program:
    push fmt_end
    call printf
    add esp,4

    mov ebx,0
    mov eax,1
    int 0x80


; epilogue:
    mov esp,ebp
    pop ebp
    ret
