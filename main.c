#include <stdio.h>

#define MAXRAM 300

int stack[100];
unsigned int SP = 0; 
unsigned int IP = 0;
int ram[MAXRAM];

int pop() {
  if( SP == 0 ) {
    // TODO handle this error somehow
    printf("stack underflow!\n");
    return 0;
  }
  int tos = stack[SP];
  SP = SP - 1;
  return tos;
}

void push( int x) {
  if( SP >= 100) {
    // TODO handle this error somehow
    printf("stack overflow!\n");
    return;
  }
  SP = SP + 1;
  stack[SP] = x;
  return;
}

int getNextByte() {
  IP = (IP + 1) % MAXRAM; // we wrap
  return ram[IP];
}

void setIP( unsigned int x) {
  IP = x; // do we want to mod() here?
  return;
}


int main( int argc, char *argv) {
  unsigned int cmd;
  unsigned int retCode;
  char ch;
  int a, b, c;
  do {
    cmd = getNextByte();
    switch( cmd) {
      case 0x00:
        // halt naturally
        retCode = 0;
        break;
      case 0x01:
        // read char from input and put on stack
        ch = getchar();
        push(c);
        break;
      case 0x02:
        // pop char from stack and put into output
        ch = pop();
        putchar(c);
        break;
      case 0x03:
        // subtract and branch if negative. hey now we're turing complete right?
        // -- no, b/c this isn't how you impl SBN ;)
        a = pop();
        b = pop();
        c = pop();
        b = b - a;
        push(b);
        if( b < 0) {
          setIP(c);
        }
        break;
      default:
        printf("unrecognized opcode %d\n", cmd);
        retCode = -1;
        cmd = 0;
    }
  } while( cmd != 0x00);

  return retCode;
}
