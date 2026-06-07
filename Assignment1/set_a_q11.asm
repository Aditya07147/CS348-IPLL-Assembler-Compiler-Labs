section .data
count times 256 dd 0
inputfile db "inputa.txt",0
spacechar db " "
newline db 10

section .bss
buffer resb 128
inputfilefd resd 1
printascii resb 1
countascii resd 1
number resb 1

section .text                                                                                                                                                    
global _start




; File cant be opened
open_file_error:
mov ebx,1
mov eax,1
int 0x80
;Sys_EXIT done.
;Returned 





print_num_in_eax:
;Prologue
push ebp
mov ebp,esp


; Actual function
mov ecx,0

eax_loop:
cmp eax,0
jle end_eax
mov edx,0
mov ebx,10
div ebx
add edx,'0'
push edx
inc ecx
jmp eax_loop


end_eax:
mov edx,0

end_eax_loop:
cmp edx,ecx
jge end_end_eax_loop
mov eax,0
pop eax
inc edx
mov [number],al

push eax
push ebx
push ecx
push edx
mov eax,4
mov ebx,1
mov ecx,number
mov edx,1
int 0x80
pop edx
pop ecx
pop ebx
pop eax
jmp end_eax_loop

end_end_eax_loop:
;Epilogue
mov esp,ebp
pop ebp
ret




; PROGRAM STARTS HERE
_start:
; Open file and acquire the fd
mov eax,5
mov ebx,inputfile
mov ecx,0
int 0x80
cmp eax,0
jl open_file_error
mov [inputfilefd],eax



; Lets read 128 Bytes by bytes

read_loop:
mov eax,3
mov ebx,[inputfilefd]
mov ecx,buffer
mov edx,128
int 0x80
; Read 128 bytes from a file


cmp eax,0
jle close_file

mov esi,0

increment_loop:
cmp esi,eax
jge end_increment_loop

mov ebx,0
mov bl,[buffer+esi]
mov ecx,[count+ebx*4]
inc ecx
mov [count+ebx*4],ecx
inc esi
jmp increment_loop

end_increment_loop:
jmp read_loop



close_file:
mov eax,6
mov ebx,[inputfilefd]
int 0x80
; File closed

; console_output
mov esi,0

console_output_loop:
cmp esi,256
jge end_console_output_loop

mov eax,[count+esi*4]
cmp eax,0
jle increase_esi
; print esi in ASCII only


mov ebx,esi
mov [printascii],bl
mov [countascii],eax
mov eax,4
mov ebx,1
mov ecx,printascii
mov edx,1
int 0x80

mov eax,4
mov ebx,1
mov ecx,spacechar
mov edx,1
int 0x80

mov eax,[countascii]
call print_num_in_eax

; prine newline
mov eax,4
mov ebx,1
mov ecx,newline
mov edx,1
int 0x80


increase_esi:
inc esi
jmp console_output_loop



end_console_output_loop:
mov eax,1
mov ebx,0
int 0x80