/* 
   Test file for nanoC Lexer 
   Testing multi-line comments
*/

// Testing single line comments
int main() {
    int myVar = 10;
    _Bool flag = 1;
    
    float pi = 3.14;
    double half = .5;
    
    char letter = 'A';
    char newline = '\n';
    printf("Hello, World!\n");

    if (myVar >= 5 && pi <= 4.0) {
        myVar++;
        myVar += 2;
    } else {
        myVar--;
    }
    @
    return 0;
}
