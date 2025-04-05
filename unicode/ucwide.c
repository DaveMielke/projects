#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <unicode/uchar.h>

static int
showWideRanges (void) {
  UChar32 first = 0;

  for (UChar32 character=0; character<=UCHAR_MAX_VALUE; character+=1) {
    UEastAsianWidth width = u_getIntPropertyValue(character, UCHAR_EAST_ASIAN_WIDTH);

    if ((width == U_EA_WIDE) || (width == U_EA_FULLWIDTH)) {
      if (!first) first = character;
    } else if (first) {
      UChar32 last = character - 1;
      printf("{ 0x%04X, 0x%04X },\n", first, last);
      first = 0;
    }
  }

  return 1;
}

int
main (int argc, char **argv) {
  if (!showWideRanges()) return 1;
  return 0;
}
