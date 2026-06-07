/* 
 * test.nc
 */

static int x=53;

int main() {
    int a = 5;
    int b = 10;
    
    a = a + b;
    
    if (a > 1) {
        a = 2;
    } else {
        a = 3;
    }
    
    while (a > 1) {
        a = a - 1;
    }
    
    return 1;
}
