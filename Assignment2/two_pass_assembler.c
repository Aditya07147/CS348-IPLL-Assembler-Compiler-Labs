#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAX_SYMBOLS 100
#define MAX_OPCODES 50

typedef struct
{
    char label[20];
    int address;
} Symbol;

typedef struct
{
    char mnemonic[20];
    int code;
} Opcode;

// Global variables
Symbol SYMTAB[MAX_SYMBOLS];
Opcode OPTAB[MAX_OPCODES];
int sym_count = 0, optab_count = 0;
int starting_address = 0, program_length = 0;
char program_name[20];

// Helper function define

int search_symtab(char *label)
{
    for (int i = 0; i < sym_count; i++)
    {
        if (strcmp(SYMTAB[i].label, label) == 0)
            return SYMTAB[i].address;
    }
    return -1;
}

int search_optab(char *mnemonic)
{
    for (int i = 0; i < optab_count; i++)
    {
        if (strcmp(mnemonic, OPTAB[i].mnemonic) == 0)
            return OPTAB[i].code;
    }
    return -1;
}

void insert_symtab(char *label, int locctr)
{
    if (search_symtab(label) != -1)
    {
        printf("Error: Duplicate Label '%s'\n", label);
        exit(1);
    }
    strcpy(SYMTAB[sym_count].label, label);
    SYMTAB[sym_count].address = locctr;
    sym_count++;
}

// Loads opcodes 
void load_optab()
{
    FILE *fptr = fopen("opcodes.txt", "r");
    if (!fptr)
    {
        printf("Error: opcodes.txt not found\n");
        exit(1);
    }
    while (fscanf(fptr, "%s %x", OPTAB[optab_count].mnemonic, &OPTAB[optab_count].code) != EOF)
    {
        optab_count++;
    }
    fclose(fptr);
}

void parse_line(char *line, char *label, char *mnemonic, char *operand)
{
    label[0] = mnemonic[0] = operand[0] = '\0';
    if (line[0] == '.')
        return; // Ignore comments

    int count = sscanf(line, "%s %s %s", label, mnemonic, operand);
    if (count == 2)
    { 
        strcpy(operand, mnemonic);
        strcpy(mnemonic, label);
        label[0] = '\0';
    }
    else if (count == 1)
    { 
        strcpy(mnemonic, label);
        label[0] = '\0';
        operand[0] = '\0';
    }
}

// Pass 1

void pass1()
{
    FILE *input = fopen("input.txt", "r");
    FILE *output = fopen("intermediate.txt", "w");
    char line[100], label[20], mnemonic[20], operand[20];
    int locctr = 0;

    if (fgets(line, sizeof(line), input))
    {
        parse_line(line, label, mnemonic, operand);
        if (strcmp(mnemonic, "START") == 0)
        {
            starting_address = (int)strtol(operand, NULL, 16);
            locctr = starting_address;
            strcpy(program_name, label);
            fprintf(output, "%04X %s", locctr, line);
        }
    }

    while (fgets(line, sizeof(line), input))
    {
        if (line[0] == '.')
        {
            fprintf(output, "     %s", line);
            continue;
        }
        parse_line(line, label, mnemonic, operand);
        if (strcmp(mnemonic, "END") == 0)
        {
            fprintf(output, "%04X %s", locctr, line);
            break;
        }

        fprintf(output, "%04X %s", locctr, line);
        if (label[0] != '\0')
            insert_symtab(label, locctr);
        if (search_optab(mnemonic) != -1)
            locctr += 3;
        else if (strcmp(mnemonic, "WORD") == 0)
            locctr += 3;
        else if (strcmp(mnemonic, "RESW") == 0)
            locctr += 3 * atoi(operand);
        else if (strcmp(mnemonic, "RESB") == 0)
            locctr += atoi(operand);
        else if (strcmp(mnemonic, "BYTE") == 0)
        {
            if (operand[0] == 'C')
                locctr += strlen(operand) - 3; // C'EOF'
            else if (operand[0] == 'X')
                locctr += (strlen(operand) - 3) / 2; // X'F1'
        }
    }
    program_length = locctr - starting_address;
    fclose(input);
    fclose(output);
}

// Pass 2

void flush_text_record(FILE *output, int start, char *buffer, int length)
{
    if (length > 0)
    {
        fprintf(output, "T%06X%02X%s\n", start, length, buffer);
    }
}

void pass2()
{
    FILE *input = fopen("intermediate.txt", "r");
    FILE *output = fopen("output_two_pass.txt", "w");
    char line[100], label[20], mnemonic[20], operand[20];
    char textrecord[61] = "";
    int text_rec_len = 0, curr_start = -1;

    // 1. Write Header Record
    fgets(line, sizeof(line), input);
    fprintf(output, "H%-6s%06X%06X\n", program_name, starting_address, program_length);

    while (fgets(line, sizeof(line), input))
    {
        int locctr;
        char rest[100], currhex[40] = "";
        int curr_obj_len = 0;

        // Parse address and instruction from intermediate file
        if (sscanf(line, "%x %[^\n]", &locctr, rest) < 2)
        {
            parse_line(line + 5, label, mnemonic, operand);
            if (strcmp(mnemonic, "END") == 0)
                break;
            continue;
        }

        parse_line(rest, label, mnemonic, operand);
        int opcode = search_optab(mnemonic);

        if (opcode != -1)
        {
            int addr = 0;
            if (operand[0] != '\0')
            {
                // Handle Indexed Addressing 
                char *comma = strchr(operand, ',');
                if (comma != NULL)
                {
                    *comma = '\0';
                    addr = search_symtab(operand);
                    if (addr != -1)
                        addr += 0x8000; // Set index bit
                }
                else
                {
                    addr = search_symtab(operand);
                }
                if (addr == -1)
                    addr = 0;
            }
            sprintf(currhex, "%02X%04X", opcode, addr);
            curr_obj_len = 3;
        }
        else if (strcmp(mnemonic, "WORD") == 0)
        {
            sprintf(currhex, "%06X", atoi(operand));
            curr_obj_len = 3;
        }
        else if (strcmp(mnemonic, "BYTE") == 0)
        {
            if (operand[0] == 'C')
            { 
                for (int i = 2; i < strlen(operand) - 1; i++)
                {
                    char temp[3];
                    sprintf(temp, "%02X", operand[i]);
                    strcat(currhex, temp);
                }
                curr_obj_len = strlen(operand) - 3;
            }
            else if (operand[0] == 'X')
            { 
                strncpy(currhex, operand + 2, strlen(operand) - 3);
                currhex[strlen(operand) - 3] = '\0';
                curr_obj_len = (strlen(operand) - 3) / 2;
            }
        }
        else if (strcmp(mnemonic, "RESW") == 0 || strcmp(mnemonic, "RESB") == 0)
        {
            flush_text_record(output, curr_start, textrecord, text_rec_len);
            text_rec_len = 0;
            textrecord[0] = '\0';
            curr_start = -1;
            continue;
        }

        if (curr_obj_len > 0)
        {
            if (curr_start == -1)
                curr_start = locctr;
            if (text_rec_len + curr_obj_len > 30)
            {
                flush_text_record(output, curr_start, textrecord, text_rec_len);
                curr_start = locctr;
                text_rec_len = 0;
                textrecord[0] = '\0';
            }
            strcat(textrecord, currhex);
            text_rec_len += curr_obj_len;
        }
    }

    // final fflush
    flush_text_record(output, curr_start, textrecord, text_rec_len);

    // End logic, end record shud contain address of first executable instruction
    int execution_start = starting_address;
    if (strlen(operand) > 0)
    {
        int addr = search_symtab(operand);
        if (addr != -1)
            execution_start = addr;
    }
    fprintf(output, "E%06X\n", execution_start);

    fclose(input);
    fclose(output);
}

int main()
{
    load_optab();
    pass1();
    printf("Pass 1 completed of two pass assembler. Intermediate file is intermediate.txt\n");
    pass2();
    printf("Two pass Assembly Complete. Program length: %04X bytes.\t Output is in output_two_pass.txt\n ", program_length);
    return 0;
}