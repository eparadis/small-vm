#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LINE_MAX 255

char *labels[10];
int locs[10];
int storedLabels = 0;
void addLabel( char *label, int loc) {
  labels[storedLabels] = malloc(strlen(label));
  strcpy(labels[storedLabels], label);
  labels[storedLabels][0] = '@'; // make it easier do search later
  locs[storedLabels] = loc - 1; // VM quirk means subtract one
  storedLabels++;
  if( storedLabels > 10) {
    perror("too many labels");
    // exit() or something
  }
}

int getAddress( char *label) {
  int i = 0;
  while( i<storedLabels) {
    if( strcmp(label, labels[i]) == 0) {
      return locs[i];
    }
    i += 1;
  }
  perror("label not found");
  printf("label: %s\n", label);
  return -999;
}

void parseFile(char *filename) {
  FILE *fp;
  char line[LINE_MAX];
  char *whitespace = " \t\r\n";
  char *token;
  char *words[] = {
    "halt", "get", "print", "fakesbn",
    "store", "read", "sub", "add",
    "jlz"
  };
  int i;
  int location;

  fp = fopen(filename, "r");
  if( fp == NULL) {
    perror("Error opening file");
    return;
  }

  printf("first pass\n");
  location = 0;
  while( fgets( line, LINE_MAX, fp) != NULL) {
    token = strtok(line, whitespace);
    while( token != NULL && strcmp(token, "#")) {
      if( strncmp(token, ":", 1) == 0) {
        // label
        printf("found label: %s \n", token);
        addLabel( token, location);
      } else {
        // opcode, number, or some unknown thing
        location += 1;
      }
      // other things we could find and note:
      // - math expressoins to evalutate
      // - macros to expand
      // - potential optimizations
      // - locations that we use address references
      token = strtok(NULL, whitespace);
    }
  }

  printf("second pass\n");
  rewind(fp);
  location = 0;
  while( fgets( line, LINE_MAX, fp) != NULL) {
    // printf("%d: ", line_number);
    
    token = strtok(line, whitespace);

    // ignore anything after a #
    while( token != NULL && strcmp(token, "#")) {
      if( strncmp( token, "@", 1) == 0) {
        // address reference
        // printf("address: %s ", token);
        printf("%d ", getAddress(token));
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
      }
      token = strtok(NULL, whitespace);
    }
  }

  printf("\n");
  fclose(fp);
}

int main( int argc, char *argv[]) {
  if( argc < 2) {
    printf("usage:\n%s filename\n", argv[0]);
  }
  parseFile(argv[1]);
  return 0;
}
