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

  fp = fopen("asm.txt", "r");
  if( fp == NULL) {
    perror("Error opening file");
    return;
  }

  while( fgets( line, LINE_MAX, fp) != NULL) {
    printf("%d: ", line_number);
    
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
        printf("number: %s ", token);
      } else {
        printf("word: %s ", token);
      }
      token = strtok(NULL, whitespace);
    }
  
    printf("\n");
    line_number += 1;
  }

  fclose(fp);
}

int main( int argc, char *argv[]) {
  parseFile();
  return 0;
}
