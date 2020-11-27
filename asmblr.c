#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LINE_MAX 255

void addLabel( char *label, int loc) {
}

void addAddress( char *label, int loc) {
}

void parseFile() {
  FILE *fp;
  char line[LINE_MAX];
  int line_number = 1;
  char *whitespace = " \t\r\n";
  char *token;
  char *words[] = {
    "halt", "get", "print", "fakesbn",
    "store", "read", "sub", "add",
    "jlz"
  };
  int i;
  int location;

  fp = fopen("asm.txt", "r");
  if( fp == NULL) {
    perror("Error opening file");
    return;
  }

  location = 0;
  while( fgets( line, LINE_MAX, fp) != NULL) {
    // printf("%d: ", line_number);
    
    token = strtok(line, whitespace);

    // ignore anything after a #
    while( token != NULL && strcmp(token, "#")) {
      if( strncmp(token, ":", 1) == 0) {
        // label
        // printf("label: %s ", token);
        addLabel( token, location);
      } else if( strncmp( token, "@", 1) == 0) {
        // address reference
        // printf("address: %s ", token);
        addAddress(token, location);
        location += 1;
      } else if( strpbrk( token, "-0123456789") == token) {
        // the first character is a digit or negative sign
        printf("%s ", token);
        location += 1;
      } else if ( strcmp( token, "push") == 0) {
        // currently the only multibyte opcode
        printf("09 ");
        location += 1;
      } else {
        //printf("word: %s ", token);
        // the position in the array is the value of the opcode
        for( i=0; i<9; i+=1) {
          if( strcmp(token, words[i]) == 0) {
            printf("%d ", i);
            i=9999;
          }
        }
        location += 1;
      }
      token = strtok(NULL, whitespace);
    }
  
    line_number += 1;
  }

  printf("\n");
  fclose(fp);
}

int main( int argc, char *argv[]) {
  parseFile();
  return 0;
}
