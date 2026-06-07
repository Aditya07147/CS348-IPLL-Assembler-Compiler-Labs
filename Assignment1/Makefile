# Author: Aditya Shukla

ASM = nasm
ASMFLAGS = -f elf32

# File names
Q10 = set_b_q10
Q1  = set_a_q11
Q2  = set_b_q2

all: $(Q10) $(Q1) $(Q2)


# Q10: nasm + gcc -m32
$(Q10): $(Q10).o
	gcc -m32 $(Q10).o -o $(Q10)

$(Q10).o: $(Q10).asm
	$(ASM) $(ASMFLAGS) $(Q10).asm -o $(Q10).o

# Other files: nasm + ld
$(Q1): $(Q1).o
	ld -m elf_i386 $(Q1).o -o $(Q1)

$(Q1).o: $(Q1).asm
	$(ASM) $(ASMFLAGS) $(Q1).asm -o $(Q1).o

$(Q2): $(Q2).o
	ld -m elf_i386 $(Q2).o -o $(Q2)

$(Q2).o: $(Q2).asm
	$(ASM) $(ASMFLAGS) $(Q2).asm -o $(Q2).o
# Cleanup
clean:
	rm -f *.o $(Q10) $(Q1) $(Q2)
