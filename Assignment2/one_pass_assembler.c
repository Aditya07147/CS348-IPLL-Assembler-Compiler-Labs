#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAX_SYMBOLS 100
#define MAX_OPCODES 50

unsigned char memory[32768];
int is_used[32768];
int length_at[32768];

int starting_address = 0;
int program_length = 0;

char program_name[20];
char end_operand[20];

typedef struct Node
{
    int address_to_patch; // where address byte to fill later
    struct Node *next;
} Node;


typedef struct
{
    char label[20];
    int address;
    Node *pending;
} Symbol;


typedef struct
{
    char mnemonic[20];
    int code;
} Opcode;

Symbol SYMTAB[MAX_SYMBOLS];
Opcode OPTAB[MAX_OPCODES];

int sym_count = 0;
int optab_count = 0;

int search_symtab(char *label)
{
    for (int i = 0; i < sym_count; i++)
    {
        if (strcmp(SYMTAB[i].label, label) == 0)
            return i;
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

void load_optab()
{
    FILE *fptr = fopen("opcodes.txt", "r");
    if (!fptr)
    {
        printf("Error: opcodes.txt not found\n");
        exit(1);
    }

    while (fscanf(fptr, "%s %x",
                  OPTAB[optab_count].mnemonic,
                  &OPTAB[optab_count].code) != EOF)
    {
        optab_count++;
    }

    fclose(fptr);
}


void parse_line(char *line, char *label, char *mnemonic, char *operand)
{

    label[0] = mnemonic[0] = operand[0] = '\0';

    if (line[0] == '.') // comment line
        return;

    int count = sscanf(line, "%s %s %s",
                       label, mnemonic, operand);

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



//   If symbol is not yet defined,
//   store the address where we must later patch it.

void add_pending_reference(char *label, int address_to_patch)
{

    Node *newNode = (Node *)malloc(sizeof(Node));
    newNode->address_to_patch = address_to_patch;
    newNode->next = NULL;

    int i = search_symtab(label);

    if (i == -1)
    {
        // first time symbol dikha
        strcpy(SYMTAB[sym_count].label, label);
        SYMTAB[sym_count].address = -1;
        SYMTAB[sym_count].pending = newNode;
        sym_count++;
    }
    else
    {
        Node *curr = SYMTAB[i].pending;

        if (!curr)
            SYMTAB[i].pending = newNode;
        else
        {
            while (curr->next)
                curr = curr->next;
            curr->next = newNode;
        }
    }
}

void define_symbol(char *label, int locctr)
{

    int i = search_symtab(label);

    if (i == -1)
    {
        // new symbol
        strcpy(SYMTAB[sym_count].label, label);
        SYMTAB[sym_count].address = locctr;
        SYMTAB[sym_count].pending = NULL;
        sym_count++;
    }
    else if (SYMTAB[i].address != -1)
    {
        printf("Error: Duplicate Symbol %s\n", label);
        exit(1);
    }
    else
    {
        // do back-patching !!!
        SYMTAB[i].address = locctr;

        Node *curr = SYMTAB[i].pending;
        while (curr)
        {
            memory[curr->address_to_patch] = (locctr >> 8) & 0xFF;
            memory[curr->address_to_patch + 1] = locctr & 0xFF;

            Node *temp = curr->next;
            free(curr);
            curr = temp;
        }
        SYMTAB[i].pending = NULL;
    }
}


void assemble_instruction(char *mnemonic, char *operand, int locctr)
{

    int opcode = search_optab(mnemonic);

    memory[locctr] = (unsigned char)opcode;
    is_used[locctr] = 1;
    length_at[locctr] = 3; // SIC instruction size

    int target_addr = 0;

    if (operand[0] != '\0')
    {

        int x_bit = 0;

        // Handle indexed addressing (Label,X)
        char *comma = strchr(operand, ',');
        if (comma)
        {
            *comma = '\0';
            x_bit = 0x8000;
        }

        int i = search_symtab(operand);

        if (i != -1 && SYMTAB[i].address != -1)
        {
            target_addr = SYMTAB[i].address + x_bit;
        }
        else
        {
            // forward reference
            add_pending_reference(operand, locctr + 1);
            target_addr = x_bit;
        }
    }

    memory[locctr + 1] = (target_addr >> 8) & 0xFF;
    memory[locctr + 2] = target_addr & 0xFF;

    is_used[locctr + 1] = 1;
    is_used[locctr + 2] = 1;
}

//ONE PASS Assembly
void one_pass()
{

    FILE *input = fopen("input.txt", "r");

    char line[100], label[20], mnemonic[20], operand[20];
    int locctr = 0;

    // Handle start
    if (fgets(line, sizeof(line), input))
    {
        parse_line(line, label, mnemonic, operand);

        if (strcmp(mnemonic, "START") == 0)
        {
            starting_address = (int)strtol(operand, NULL, 16);
            locctr = starting_address;
            strcpy(program_name, label);
        }
    }

    // Main loop
    while (fgets(line, sizeof(line), input))
    {

        if (line[0] == '.')
            continue;

        parse_line(line, label, mnemonic, operand);

        if (strcmp(mnemonic, "END") == 0)
        {
            strcpy(end_operand, operand);
            break;
        }

        if (label[0] != '\0')
            define_symbol(label, locctr);

        if (search_optab(mnemonic) != -1)
        {

            assemble_instruction(mnemonic, operand, locctr);
            locctr += 3;
        }
        else if (strcmp(mnemonic, "WORD") == 0)
        {

            int val = atoi(operand);

            memory[locctr] = (val >> 16) & 0xFF;
            memory[locctr + 1] = (val >> 8) & 0xFF;
            memory[locctr + 2] = val & 0xFF;

            is_used[locctr] = is_used[locctr + 1] = is_used[locctr + 2] = 1;
            length_at[locctr] = 3;

            locctr += 3;
        }
        else if (strcmp(mnemonic, "BYTE") == 0)
        {

            int start_loc = locctr;

            if (operand[0] == 'C')
            {

                int len = strlen(operand) - 3;
                length_at[start_loc] = len;

                for (int i = 2; i < (int)strlen(operand) - 1; i++)
                {
                    memory[locctr] = operand[i];
                    is_used[locctr++] = 1;
                }
            }
            else if (operand[0] == 'X')
            {

                int len = (strlen(operand) - 3) / 2;
                length_at[start_loc] = len;

                for (int i = 2; i < (int)strlen(operand) - 1; i += 2)
                {

                    char hex[3] = {operand[i], operand[i + 1], '\0'};
                    memory[locctr] = (unsigned char)strtol(hex, NULL, 16);
                    is_used[locctr++] = 1;
                }
            }
        }
        else if (strcmp(mnemonic, "RESW") == 0)
        {
            locctr += 3 * atoi(operand);
        }
        else if (strcmp(mnemonic, "RESB") == 0)
        {
            locctr += atoi(operand);
        }
    }

    program_length = locctr - starting_address;
    fclose(input);
}

//Generate object file
void generate_output_file()
{

    FILE *output = fopen("output_one_pass.txt", "w");

    // Header Record
    fprintf(output, "H%-6s%06X%06X\n",
            program_name,
            starting_address,
            program_length);

    int i = starting_address;

    while (i < starting_address + program_length)
    {

        if (is_used[i])
        {

            int record_start = i;
            char buffer[61] = "";
            int bytes_in_record = 0;

            while (i < starting_address + program_length && is_used[i])
            {

                int item_len = length_at[i];

                if (bytes_in_record + item_len > 30)
                    break;

                for (int k = 0; k < item_len; k++)
                {

                    char hex[3];
                    sprintf(hex, "%02X", memory[i++]);
                    strcat(buffer, hex);
                    bytes_in_record++;
                }
            }

            fprintf(output, "T%06X%02X%s\n",
                    record_start,
                    bytes_in_record,
                    buffer);
        }
        else
        {
            i++; // skip reserved mem
        }
    }

    // End record
    int exec_addr = starting_address;

    if (end_operand[0] != '\0')
    {
        int idx = search_symtab(end_operand);
        if (idx != -1)
            exec_addr = SYMTAB[idx].address;
    }

    fprintf(output, "E%06X\n", exec_addr);

    fclose(output);
}


int main()
{

    load_optab();           // prepare OPTAB
    one_pass();             // assemble
    generate_output_file(); // write object program
    printf("One-pass assembly complete. Output is in output_one_pass.txt\n");

    return 0;
}
