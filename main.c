#include <stdio.h>
#include <stdlib.h>
#include <termios.h>
#include <unistd.h>

#define MAXRAM 300

int stack[100];
unsigned int SP = 0; 
unsigned int IP = 0;
int ram[MAXRAM];
struct termios oldtio, newtio;

int pop() {
  if( SP == 0 ) {
    // TODO handle this error somehow
    perror("stack underflow!");
    return 0;
  }
  int tos = stack[SP];
  SP = SP - 1;
  return tos;
}

void push( int x) {
  if( SP >= 100) {
    // TODO handle this error somehow
    perror("stack overflow!");
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

void loadRamFromFile() {
  // from: https://www.tutorialspoint.com/c_standard_library/c_function_fgets.htm
  FILE *fp;
  char str[60];
  int index;

  fp = fopen("file.txt", "r");
  if( fp == NULL) {
    // TODO do something with this error
    perror("Error opening file");
    return;
  }

  index = 0;
  while( index < MAXRAM ) {
    if( fgets( str, 60, fp) != NULL) {
      ram[index] = atoi( str);
    }
    index += 1;
  }

  fclose(fp);
}

void setupTerminal() {
  // largely from pforth pf_io_posix.c
  tcgetattr(STDIN_FILENO, &oldtio);
  tcgetattr(STDIN_FILENO, &newtio);
  newtio.c_lflag &= ~( ECHO | ECHONL | ECHOCTL | ICANON );
  newtio.c_cc[VTIME] = 0;
  newtio.c_cc[VMIN] = 1;
  if( tcsetattr(STDIN_FILENO, TCSANOW, &newtio) < 0 ) {
    perror("error setting terminal");
  }
}

void resetTerminal() {
  tcsetattr(STDIN_FILENO, TCSANOW, &oldtio);
}

int main( int argc, char *argv[]) {
  unsigned int cmd;
  unsigned int retCode;
  char ch;
  int a, b, c;
  IP = -1;
  loadRamFromFile();
  setupTerminal();
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
        push(ch);
        break;
      case 0x02:
        // pop char from stack and put into output
        ch = pop();
        putchar(ch);
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
      case 0x04:
        // store a value in memory
        a = pop(); // location
        b = pop(); // value
        ram[a] = b;
        break;
      case 0x05:
        // read value from memory
        a = pop(); // location
        push( ram[a]);
        break;
      case 0x06:
        // subtract
        a = pop();
        b = pop();
        push( a-b);
        break;
      case 0x07:
        // add
        a = pop();
        b = pop();
        push( a+b);
        break;
      case 0x08:
        // if TOS is negative, set IP to the next value in the stack
        a = pop(); // condition
        b = pop(); // location
        if( a < 0) {
          IP = b;
        }
        break;
      case 0x09:
        // immediate value - push the location after where IP is pointing on to the stack
        IP += 1; // so this is a two-location operand
        push( ram[IP]);
        break;
      default:
        printf("unrecognized opcode %d\n", cmd);
        retCode = -1;
        cmd = 0;
    }
  } while( cmd != 0x00);

  resetTerminal();
  return retCode;
}
