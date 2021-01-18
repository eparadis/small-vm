#include <stdio.h>
#include <stdlib.h>
#include <termios.h>
#include <unistd.h>
#include <string.h>

#define MAXRAM 300
#define LINE_MAX 1023 

int stack[100];
unsigned int SP = 0; 
unsigned int IP = 0;
int ram[MAXRAM];
struct termios oldtio, newtio;

int pop() {
  if( SP == 0 ) {
    // TODO handle this error somehow
    printf("stack underflow at IP=%d\n", IP);
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

void advanceIP() {
  IP = (IP + 1) % MAXRAM; // we wrap
}

int getNextByte() {
  return ram[IP];
}

void setIP( unsigned int x) {
  IP = x; // do we want to mod() here?
  return;
}

void loadRamFromFile(char *filename) {
  // from: https://www.tutorialspoint.com/c_standard_library/c_function_fgets.htm
  FILE *fp;
  char line[LINE_MAX];
  int index;
  char *token;
  char *whitespace = " \t\r\n";

  if( strcmp(filename, "-") == 0 ) {
    fp = stdin;
  } else {
    fp = fopen(filename, "r");
  }
  if( fp == NULL) {
    // TODO do something with this error
    perror("Error opening file");
    return;
  }

  index = 0;
  //while( index < MAXRAM ) {
  while( fgets( line, LINE_MAX, fp) != NULL) {
      token = strtok(line, whitespace);

      // ignore anything on a line after a #
      while( token != NULL && strcmp(token, "#")) {
        if( strpbrk( token, "-0123456789") == token) {
          // the first char is a digit or a negative sign
          ram[index] = atoi( token);
          index += 1;
        } else {
          printf("parse error\n");
        }
        if( index > MAXRAM) {
          printf("ram file too large to fit into VM ram\n");
          break;
        }
        token = strtok( NULL, whitespace);
      }
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
  //cfmakeraw(&newtio); // use this instead of the three lines above if you want the VM to be able to output CR and LF independently
  if( tcsetattr(STDIN_FILENO, TCSANOW, &newtio) < 0 ) {
    printf("error setting terminal");
  }
  // remove buffers from stdin & stdout 
  setvbuf(stdin, NULL, _IONBF, 0);
  setvbuf(stdout, NULL, _IONBF, 0);
}

void resetTerminal() {
  tcsetattr(STDIN_FILENO, TCSANOW, &oldtio);
}

int main( int argc, char *argv[]) {
  unsigned int cmd;
  unsigned int retCode;
  char ch;
  int a, b, c;
  if( argc < 2 ) {
    printf("usage:\n%s filename\n", argv[0]);
    return -1;
  }
  IP = -1;
  loadRamFromFile(argv[1]);
  if( strcmp(argv[1], "-") != 0) {
    setupTerminal();
  }
  advanceIP();
  do {
    cmd = getNextByte();
    switch( cmd) {
      case 0x00: // ( -- ) halt
        retCode = 0;
        advanceIP();
        break;
      case 0x01: // ( -- char ) read char from input and put on stack
        ch = getchar();
        push(ch);
        advanceIP();
        break;
      case 0x02: // ( char -- ) pop char and put into output
        ch = pop();
        putchar(ch);
        advanceIP();
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
        advanceIP();
        break;
      case 0x04: // ( val loc -- ) store a value in memory
        a = pop(); // location
        b = pop(); // value
        ram[a] = b;
        //printf("store %d into %d\n", b, a); 
        advanceIP();
        break;
      case 0x05: // ( loc -- val ) read value from memory
        a = pop(); // location
        if( a < 0 || a >= MAXRAM) {
          printf("cannot push illegal address of %d\n", a);
          retCode = -1;
          cmd = 0;
        } else {
          push( ram[a]);
        }
        //printf("load %d\n", a);
        advanceIP();
        break;
      case 0x06: // ( b a -- c) c=b-a subtract
        a = pop();
        b = pop();
        push( b-a);
        //printf( "subtract %d - %d \n", b, a);
        advanceIP();
        break;
      case 0x07: // ( b a -- c) c=a+b add
        a = pop();
        b = pop();
        push( a+b);
        advanceIP();
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
          advanceIP();
        }
        break;
      case 0x09: // ( -- x ) immediate value - push the location after where IP is pointing on to the stack
        advanceIP(); // so this is a two-location operand
        push( ram[IP]);
        advanceIP();
        break;
      case 0x0A: // ( -- ip ) push IP
        push( IP);
        advanceIP();
        break;
      default:
        printf("unrecognized opcode %d at %d\n", cmd, IP);
        retCode = -1;
        cmd = 0;
        advanceIP();
    }
  } while( cmd != 0x00);

  if( strcmp(argv[1], "-") != 0) {
    resetTerminal();
  }

  /* TODO add a flag to do this optionally
  for(i=0; i < MAXRAM; i++ ) {
    printf("%d ", ram[i]);
    if( i % 20 == 19) {
      printf("\n");
    }
  }
  */
  return retCode;
}
