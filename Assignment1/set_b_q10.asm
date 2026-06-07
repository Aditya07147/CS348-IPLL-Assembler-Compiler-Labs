extern printf
extern scanf

section .data
	int_input db '%d',0
    f_input db '%lf',0
	fmt_n_input db 'Enter n: ',0
	fmt_k_input db 'Enter k: ',0
	fmt_arr_input db 'Enter number: ',0
	fmt_ans db 'kth largest number is : %lf ',10,0


section .bss
	n resd 1
	k resd 1
	arr resq 100
	temp resq 1


section .text
	global main


main:
	; Prologue
	push ebp
	mov ebp,esp

	; Read n
	; scanf("Enter n: %d",&n)
	push fmt_n_input
	call printf
	add esp,4
	push n
	push int_input
	call scanf
	add esp,8

    ; scanf("Enter k: %d",&k)
	push fmt_k_input
	call printf
	add esp,4
	push k
	push int_input
	call scanf
	add esp,8

	push 0
i_loopa:
	mov eax,[ebp-4]
	mov ebx,[n]
	cmp eax,ebx
	jge end_i_loopa
	;Printf("Enter number: ")
	push eax
	
	push fmt_arr_input
	call printf
	add esp,4

	pop eax

	;scanf("%f",&arr[i])
	imul eax,eax,8
	add eax,arr
	push eax
	push f_input
	call scanf
	add esp,8

	mov eax,[ebp-4]
	inc eax
	mov [ebp-4],eax
	jmp i_loopa

end_i_loopa:
	add esp,4

	push 1
	push 1
i_loop:
	mov eax,[ebp-4]
	cmp eax,[n]
	jge end_i_loop
	mov [ebp-8],eax
j_loop:
	mov ebx,[ebp-8]
	cmp ebx,0
	jle inc_i_loop


	fld qword [arr+ebx*8]
	dec ebx
	fld qword [arr+ebx*8]
	fcomi st0,st1
	jbe bef_j_loop

	fstp qword [temp]
	fstp qword [arr+ebx*8]
	fld qword [temp]
	inc ebx
	fstp qword [arr+ebx*8]
	jmp dec_j_loop


bef_j_loop:
	fstp qword [temp]
	fstp qword [temp]
	jmp dec_j_loop
	
dec_j_loop:
	mov eax,[ebp-8]
	dec eax
	mov [ebp-8],eax
	jmp j_loop

inc_i_loop:
	mov eax,[ebp-4]
	inc eax
	mov [ebp-4],eax
	jmp i_loop

end_i_loop:
	pop eax
	pop eax
	
	;printf("kth largest number is:  %lf\n",arr[n-k])
	mov eax,[n]
	mov ebx,[k]
	sub eax,ebx
	imul eax,eax,8
	push dword [arr+eax+4]
	push dword [arr+eax]
	push fmt_ans
	call printf
	add esp,12

	
	;Epilogue
	mov esp,ebp
	pop ebp
	xor eax,eax
	ret
	
