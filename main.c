#include <stdio.h>
#include <stdlib.h>
#include <termios.h>
#include <unistd.h>
#include <string.h>

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
  char *p_str;
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
      p_str = str;
      ram[index] = atoi( strsep(&p_str, " \t\r\n"));
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
      case 0x00: // ( -- ) halt
        retCode = 0;
        break;
      case 0x01: // ( -- char ) read char from input and put on stack
        ch = getchar();
        push(ch);
        break;
      case 0x02: // ( char -- ) pop char and put into output
        ch = pop();
        putchar(ch);
        break;
      case 0x03: // ( c b a -- B ) B=b-a, IP=c if B<0
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
      case 0x04: // ( val loc -- ) store a value in memory
        a = pop(); // location
        b = pop(); // value
        ram[a] = b;
        //printf("store %d into %d\n", b, a); 
        break;
      case 0x05: // ( loc -- val ) read value from memory
        a = pop(); // location
        push( ram[a]);
        //printf("load %d\n", a);
        break;
      case 0x06: // ( b a -- c) c=b-a subtract
        a = pop();
        b = pop();
        push( b-a);
        //printf( "subtract %d - %d \n", b, a);
        break;
      case 0x07: // ( b a -- c) c=a+b add
        a = pop();
        b = pop();
        push( a+b);
        break;
      case 0x08: // ( loc cond -- ) IP=loc if cond>0
        // if TOS is positive, set IP to the next value in the stack
        a = pop(); // condition
        b = pop(); // location
        if( a > 0) {
          IP = b;
          //printf("%d is greater than 0; jumping to %d\n", a, b);
        } else {
          //printf("%d is <= 0", a);
        }
        break;
      case 0x09: // ( -- x ) immediate value - push the location after where IP is pointing on to the stack
        IP += 1; // so this is a two-location operand
        push( ram[IP]);
        break;
      default:
        printf("unrecognized opcode %d at %d\n", cmd, IP);
        retCode = -1;
        cmd = 0;
    }
  } while( cmd != 0x00);

  resetTerminal();
  return retCode;
}
