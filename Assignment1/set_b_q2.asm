section .data
    adj dd 0,1,0,0
        dd 1,0,1,0
        dd 0,1,0,1
        dd 0,0,1,0

    vis dd 0,0,0,0
    check dd 0
    i dd 0
    j dd 0

    cyclemsg db 'Cycle detected',10,0
    cyclemsglen equ $-cyclemsg
    nocyclemsg db 'No Cycle detected',10,0
    nocyclemsglen equ $-cyclemsg
        
section .bss


section .text
    global _start


dfs:
; Prologue
push ebp
mov ebp,esp
push dword 0

; Actual Function
mov eax,1
mov ebx,[ebp+8]
mov [vis+4*ebx],eax

j_loop:
mov eax,[ebp-4]
cmp eax,4
jge end_j_loop
mov ebx,[ebp+8]
imul ebx,ebx,16
add ebx,adj
mov ecx,[ebx+eax*4]
cmp ecx,1
jne inc_j_loop
mov eax,[ebp-4]
mov ebx,[ebp+12]
cmp eax,ebx
je inc_j_loop
mov ebx,[vis+eax*4]
cmp ebx,0
jne make_check_true

; Call dfs
mov ebx,[ebp+8]

push check
push ebx
push eax
call dfs
pop eax
pop eax
pop eax

jmp inc_j_loop


make_check_true:
mov eax,[ebp+16]
mov dword [eax],1

inc_j_loop:
mov eax,[ebp-4]
inc eax
mov [ebp-4],eax
jmp j_loop

end_j_loop:
mov eax,2
mov ebx,[ebp+8]
mov [vis+ebx*4],eax
; Epilogue
mov esp,ebp
pop ebp
ret



_start:
mov dword [i],0

i_loop:
mov eax,[i]
cmp eax,4
jge end_i_loop
mov ebx,[i]
mov eax,[vis+ebx*4]
cmp eax,0
jne skip_call

; Call dfs
push check
push dword -1
push dword [i]
call dfs
pop eax
pop eax
pop eax

skip_call:
mov eax,[i]
inc eax
mov [i],eax
jmp i_loop

end_i_loop:
mov ecx,nocyclemsg
mov edx,nocyclemsglen
mov eax,[check]
cmp eax,1
jne end_program
mov ecx,cyclemsg
mov edx,cyclemsglen
end_program:
mov eax,4
mov ebx,1
int 0x80
mov eax,1
mov ebx,0
int 0x80
