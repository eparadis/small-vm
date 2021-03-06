#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LINE_MAX 1023
#define LABELS_MAX 100

char *labels[LABELS_MAX];
int locs[LABELS_MAX];
int storedLabels = 0;
void addLabel( char *label, int loc) {
  labels[storedLabels] = malloc(strlen(label)+1);
  strcpy(labels[storedLabels], label);
  labels[storedLabels][0] = '@'; // make it easier do search later
  locs[storedLabels] = loc;
  printf("# label %s is %d\n", label, loc);
  storedLabels++;
  if( storedLabels > LABELS_MAX) {
    printf("too many labels");
    exit(-1);
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
  fprintf( stderr, "label %s not found\nknown labels:\n", label );
  for(i=0; i<storedLabels; i++) {
    fprintf( stderr, "-->%s<--\n", labels[i]);
  }
  printf("# unfound label: %s\n", label);
  exit(-1);
  return -999;
}

int firstPass(char * line, int location) {
  char *whitespace = " \t\r\n";
  char *token = strtok(line, whitespace);
  while( token != NULL && strcmp(token, "#")) {
    if( strncmp(token, ":", 1) == 0) {
      // label
      printf("# found label: %s \n", token);
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
  return location;
}

int secondPass( char *line, int location) {
  char *whitespace = " \t\r\n";
  char *words[] = {
    "halt", "get", "emit", "fakesbn",
    "store", "read", "sub", "add",
    "jgz", "push", "pip"
  };
  int numWords = 11;
  int i;
  char *token = strtok(line, whitespace);
  // ignore anything after a #
  while( token != NULL && strcmp(token, "#")) {
    if( strncmp( token, "@", 1) == 0) {
      // address reference
      // printf("address: %s ", token);
      printf("%d\n", getAddress(token));
      location += 1;
    } else if( strpbrk( token, "-0123456789") == token) {
      // the first character is a digit or negative sign
      printf("%s\n", token);
      location += 1;
    } else if ( strcmp( token, "push") == 0) {
      // currently the only multibyte opcode
      printf("09 ");
      location += 1;
    } else {
      //printf("word: %s ", token);
      // the position in the array is the value of the opcode
      for( i=0; i<numWords; i+=1) {
        if( strcmp(token, words[i]) == 0) {
          // i should never equal 9 because push is special cased above
          printf("%d\n", i);
          i=9999;
        }
      }
    }
    token = strtok(NULL, whitespace);
  }
  return location;
}

void parseFile(char *filename) {
  FILE *fp;
  char line[LINE_MAX];
  int location;

  fp = fopen(filename, "r");
  if( fp == NULL) {
    perror("Error opening file");
    return;
  }

  printf("# first pass\n");
  location = 0;
  while( fgets( line, LINE_MAX, fp) != NULL) {
    location = firstPass(line, location);
  }

  printf("# second pass\n");
  rewind(fp);
  location = 0;
  while( fgets( line, LINE_MAX, fp) != NULL) {
    location = secondPass(line, location);
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
