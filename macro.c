#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LINE_MAX 255
#define LABELS_MAX 100
#define MACROS_MAX 20

char *macro_names[MACROS_MAX];
char *macros[MACROS_MAX];
int storedMacros = 0;
int insideMacro = 0;

void addToMacro( char *token) {
  if( insideMacro == 0) {
    printf("# attempted to add to a macro when not inside a definition. Ignoring.\n");
    return;
  }
  printf("# adding '%s' to macro\n", token);
  // ref: https://www.stev.org/post/csomesimpleexamplesofusingstrcat
  char *tmp = malloc( strlen(macros[storedMacros - 1]) + strlen(" ") + strlen(token) + 1 * sizeof(*token));
  if( tmp == NULL) {
    perror("could not allocate memory to expand macro");
    exit(-1);
  }
  tmp[0] = '\0'; // null terminator
  strcat( tmp, macros[storedMacros - 1]);
  strcat( tmp, "\n");
  strcat( tmp, token);
  free(macros[storedMacros - 1]);
  macros[storedMacros - 1] = tmp;
}

int expandMacro( char *name, int startingLocation) {
  // printf("# expanding macro '%s'\n", name);
  int retval = 0;
  int count = 0;
  while( count < storedMacros) {
    if( strcmp( name, macro_names[count]) == 0) {
      printf("# macro: %s\n", name);
      printf("%s\n",  macros[count]);
      // tmp = malloc( strlen(macros[count]) + 1 * sizeof( char));
      // if( tmp == NULL) {
      //   perror( "could not malloc duplicate line to parse");
      //  exit(-1);
      //}
      // strcpy( tmp, macros[count]);
      // retval = secondPassProcess( tmp, startingLocation);
      // free(tmp);
      return retval; 
    }
    count ++;
  }
  return 0;
}

int isMacro( char *token) {
  int count = 0;
  while( count < storedMacros) {
    if( strcmp(token, macro_names[count]) == 0) {
      return 1;
    }
    count++;
  }
  return 0;
}

void createMacro( char *name) {
  if( isMacro(name) ) {
    printf("# attempt to redefine macro '%s'. Ignoring.", name);
    return;
  }
  printf("# start of macro definition '%s'\n", name);
  macro_names[storedMacros] = malloc(strlen(name));
  if( macro_names[storedMacros] == NULL) {
    perror("could not allocate space for new macro name");
    exit(-1);
  }
  strcpy(macro_names[storedMacros], name);
  macros[storedMacros] = malloc( strlen("") + 1);
  if( macros[storedMacros] == NULL) {
    perror("could not allocate space for new macro body");
    exit(-1);
  }
  strcpy(macros[storedMacros], "");
  storedMacros++;
  if( storedMacros > MACROS_MAX) {
    printf("too many macros");
    exit(-1);
  }
  insideMacro = 1;
}

void endMacro() {
  if( insideMacro == 0) {
    printf("# attempting to end a macro definition when we're not in one!\n");
    return;
  }
  printf("# end of macro definition\n\n");
  insideMacro = 0;
}

int insideMacroDef() {
  return insideMacro;
}

char *labels[LABELS_MAX];
int locs[LABELS_MAX];
int storedLabels = 0;
void addLabel( char *label, int loc) {
  labels[storedLabels] = malloc(strlen(label));
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
  fprintf( stderr, "label %s not found\n", label);
  printf("# unfound label: %s\n", label);
  exit(-1);
  return -999;
}

int firstPass( char *line, int startingLoc) {
  int location = startingLoc;
  char *whitespace = " \t\r\n";
  char *ctx;
  char *token = strtok_r(line, whitespace, &ctx);
  while( token != NULL && strcmp(token, "#")) {
    if( strncmp(token, ".endmacro", 9) == 0) {
      // assembler directive to end whatever macro definition we're inside
      endMacro();
    } else if( strncmp(token, ".addmacro", 9) == 0) {
      // assembler directive to begin defining a macro
      token = strtok_r(NULL, whitespace, &ctx);
      createMacro(token);
    } else if( insideMacroDef()) {
      addToMacro(token);
    } else {
      location += 1;
    }
    token = strtok_r(NULL, whitespace, &ctx);
  }
  return location;
}

int secondPass( char *line, int startingLoc, int *insideMacro) {
  int location = startingLoc;
  char *whitespace = " \t\r\n";
  char *ctx;
  char *token = strtok_r(line, whitespace, &ctx);
  // ignore anything after a #
  while( token != NULL && strcmp(token, "#")) {
    if( strncmp(token, ".endmacro", 9) == 0) {
      *insideMacro = 0;
      printf("\n# leaving macro\n");
    } else if( strncmp(token, ".addmacro", 9) == 0) {
      *insideMacro = 1;
      printf("\n# entering macro\n");
    } else if( *insideMacro == 0 && isMacro(token)) {
      location = expandMacro(token, location);
    } else if( *insideMacro == 0) {
      printf("%s\n", token);
      location += 1;
    }
    token = strtok_r(NULL, whitespace, &ctx);
  }
  return location;
}

void parseFile(char *filename) {
  FILE *fp;
  char line[LINE_MAX];
  int location;
  int insideMacro = 0;

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
    location = secondPass(line, location, &insideMacro);
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
