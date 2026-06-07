CC = gcc
CFLAGS = -Wall -g
ONEPASS = one_pass
TWOPASS = two_pass

# Default target
all: $(ONEPASS) $(TWOPASS)


$(ONEPASS): one_pass_assembler.c
	$(CC) $(CFLAGS) one_pass_assembler.c -o $(ONEPASS)


$(TWOPASS): two_pass_assembler.c
	$(CC) $(CFLAGS) two_pass_assembler.c -o $(TWOPASS)

clean:
	rm -f $(ONEPASS) $(TWOPASS) \
	output_one_pass.txt \
	output_two_pass.txt \
	intermediate.txt
run_one:
	./$(ONEPASS)

run_two:
	./$(TWOPASS)
