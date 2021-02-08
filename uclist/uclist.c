#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <unicode/uchar.h>

static int
listCharacter (UChar32 character) {
  printf("%06X:", (unsigned int)character);

  {
    char name[0X100];
    UErrorCode error = U_ZERO_ERROR;

    u_charName(
      character, U_UNICODE_CHAR_NAME,
      name, sizeof(name),
      &error
    );

    if (U_SUCCESS(error)) {
      if (!name[0]) strcpy(name, "-");
      for (char *c=name; *c; c+=1) *c = tolower(*c);
      printf(" %s", name);
    }
  }

  printf(" |");

  for (UProperty property=UCHAR_BINARY_START; property<UCHAR_BINARY_LIMIT; property+=1) {
    if (u_hasBinaryProperty(character, property)) {
      const char *name = u_getPropertyName(property, U_LONG_PROPERTY_NAME);

      if (name) {
        printf(" %s", name);
      }
    }
  }

  printf("\n");
  return 1;
}

static int
listAllCharacters (void) {
  for (UChar32 character=0; character<=UCHAR_MAX_VALUE; character+=1) {
    if (!listCharacter(character)) return 0;
  }

  return 1;
}

int
main (int argc, char **argv) {
  if (!listAllCharacters()) return 1;
  return 0;
}
