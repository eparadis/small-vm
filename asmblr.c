#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LINE_MAX 255

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

  fp = fopen("asm.txt", "r");
  if( fp == NULL) {
    perror("Error opening file");
    return;
  }

  while( fgets( line, LINE_MAX, fp) != NULL) {
    // printf("%d: ", line_number);
    
    token = strtok(line, whitespace);

    // ignore anything after a #
    while( token != NULL && strcmp(token, "#")) {
      if( strncmp(token, ":", 1) == 0) {
        // label
        printf("label: %s ", token);
      } else if( strncmp( token, "@", 1) == 0) {
        // address reference
        printf("address: %s ", token);
      } else if( strpbrk( token, "0123456789") == token) {
        // the first character is a digit
        printf("%s ", token);
      } else if ( strcmp( token, "push") == 0) {
        // currently the only multibyte opcode
        printf("09 ");
      } else {
        //printf("word: %s ", token);
        for( i=0; i<9; i+=1) {
          if( strcmp(token, words[i]) == 0) {
            printf("%d ", i);
            i=9999;
          }
        }
      }
      token = strtok(NULL, whitespace);
    }
  
    //printf("\n");
    line_number += 1;
  }

  fclose(fp);
}

int main( int argc, char *argv[]) {
  parseFile();
  return 0;
}
