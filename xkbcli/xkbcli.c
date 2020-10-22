#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>

#include <unistd.h>
#include <string.h>
#include <wchar.h>
#include <poll.h>
#include <errno.h>

#define NCURSES_WIDECHAR 1
#include <curses.h>

#include <X11/X.h>
#include <X11/Xlib.h>
#include <X11/XKBlib.h>
#include <X11/keysym.h>
#include <X11/extensions/XKB.h>
#include <X11/extensions/XTest.h>

typedef enum {
  PROG_EXIT_SUCCESS,
  PROG_EXIT_UNKNOWN,
  PROG_EXIT_SYNTAX,
  PROG_EXIT_SEMANTIC,
  PROG_EXIT_SYSTEM
} ProgramExitStatus;

static const char *programName;
static void (*putMessage) (const char *message);

static const char *displayName = NULL;
static int useCurses = 0;

static void
putProgramMessage (const char *message) {
  fprintf(stderr, "%s: %s\n", programName, message);
}

static void
putCursesMessage (const char *message) {
  printw("%s\n", message);
}

static void
logMessage (const char *format, ...) {
  char message[0X100];

  {
    va_list args;

    va_start(args, format);
    vsnprintf(message, sizeof(message), format, args);
    va_end(args);
  }

  putMessage(message);
}

static int
sendKey (Display *display, unsigned int modifiers, const KeyCode *codes) {
  if (!codes) {
    static const KeyCode noKeys[] = {0};
    codes = noKeys;
  }

  if (modifiers)
    if (!XkbLockModifiers(display, XkbUseCoreKbd, modifiers, modifiers))
      return 0;

  {
    const KeyCode *code = codes;

    while (*code)
      if (!XTestFakeKeyEvent(display, *code++, TRUE, CurrentTime))
        return 0;

    while (code > codes)
      if (!XTestFakeKeyEvent(display, *--code, FALSE, CurrentTime))
        return 0;
  }

  if (modifiers) {
    if (!XkbLockModifiers(display, XkbUseCoreKbd, modifiers, 0)) {
      return 0;
    }
  }

  if (!XFlush(display)) return 0;
  return 1;
}

static int
testKeyModifiers (Display *display, KeySym symbol, KeyCode code, unsigned int modifiers) {
  KeySym symRet;
  unsigned int unconsumedModifiers;

  if (!XkbLookupKeySym(display, code, modifiers, &unconsumedModifiers, &symRet)) return 0;
  if (symRet != symbol) return 0;
  return 1;
}

static unsigned int
getKeyModifiers (Display *display, KeySym symbol, KeyCode code, unsigned int *modifiers) {
  static const unsigned int modeMasks[] = {
    0, Mod1Mask, Mod2Mask, Mod3Mask, Mod4Mask, Mod5Mask, 0
  };
  const unsigned int *modeMask = modeMasks;

  do {
    *modifiers = *modeMask;
    if (testKeyModifiers(display, symbol, code, *modifiers)) return 1;

    *modifiers |= ShiftMask;
    if (testKeyModifiers(display, symbol, code, *modifiers)) return 1;
  } while (*++modeMask);

  return 0;
}

static int
getKeyCodeAndModifiers (Display *display, KeySym symbol, KeyCode *code, unsigned int *modifiers) {
  if (symbol != NoSymbol) {
    logMessage("symbol: 0X%X", symbol);

    {
      const char *name = XKeysymToString(symbol);
      if (name) logMessage("name: %s", name);
    }

    if ((*code = XKeysymToKeycode(display, symbol))) {
      logMessage("code: 0X%X", *code);

      if (getKeyModifiers(display, symbol, *code, modifiers)) {
        logMessage("modifiers: 0X%X", *modifiers);
        return 1;
      } else {
        logMessage("key not available");
      }
    } else {
      logMessage("key not supported");
    }
  } else {
    logMessage("key not defined");
  }

  return 0;
}

static KeySym
getCharacterKeySymbol (wint_t character) {
  if (character <= 0XFF) return character;
  if (character <= 0X10FFFF) return character | 0X01000000;
  return NoSymbol;
}

static ProgramExitStatus
processKeyNames (Display *display, const char *names) {
  typedef struct {
    KeySym symbol;
    KeyCode code;
  } KeyEntry;

  size_t namesLength = strlen(names);
  KeyEntry keyTable[namesLength];
  unsigned int keyCount = 0;

  {
    char buffer[namesLength + 1];
    char *string = buffer;
    char *save;
    const char *keyName;
    int nameError = 0;

    strcpy(buffer, names);

    while ((keyName = strtok_r(string, " \r\n", &save))) {
      KeySym keySymbol = XStringToKeysym(keyName);

      if (keySymbol == NoSymbol) {
        logMessage("unknown key: %s", keyName);
        nameError = 1;
      } else {
        int found = 0;

        {
          unsigned int i;

          for (i=0; i<keyCount; i+=1) {
            if (keySymbol == keyTable[i].symbol) {
              found = 1;
              break;
            }
          }
        }

        if (found) {
          logMessage("key already specified: %s", keyName);
          nameError = 1;
        } else {
          KeyEntry *key = &keyTable[keyCount++];
          key->symbol = keySymbol;

          if (!(key->code = XKeysymToKeycode(display, keySymbol))) {
            logMessage("key not supported: %s", keyName);
            nameError = 1;
          }
        }
      }

      string = NULL;
    }

    if (nameError) return PROG_EXIT_SYNTAX;
  }

  {
    unsigned int i;

    for (i=0; i<keyCount; i+=1) {
      if (!XTestFakeKeyEvent(display, keyTable[i].code, True, CurrentTime)) {
        return PROG_EXIT_SYSTEM;
      }
    }
  }

  while (keyCount) {
    if (!XTestFakeKeyEvent(display, keyTable[--keyCount].code, False, CurrentTime)) {
      return PROG_EXIT_SYSTEM;
    }
  }

  if (!XFlush(display)) {
    return PROG_EXIT_SYSTEM;
  }

  return PROG_EXIT_SUCCESS;
}

static int
awaitStandardInput (Display *display) {
  while (1) {
    typedef enum {
      POLL_STANDARD_INPUT,
      POLL_X_EVENTS,

      POLL_TABLE_SIZE /* must be last */
    } PollIndex;

    struct pollfd pollTable[POLL_TABLE_SIZE] = {
      [POLL_STANDARD_INPUT] = {
        .fd = fileno(stdin),
        .events = POLLIN
      }
      ,
      [POLL_X_EVENTS] = {
        .fd = XConnectionNumber(display),
        .events = POLLIN
      }
    };

    if (poll(pollTable, POLL_TABLE_SIZE, -1) == -1) {
      logMessage("poll error: %s", strerror(errno));
      return 0;
    }

    if (pollTable[POLL_X_EVENTS].revents & POLLIN) {
      while (XPending(display)) {
        XEvent event;
        XNextEvent(display, &event);

        switch (event.type) {
          case MappingNotify:
            XRefreshKeyboardMapping(&event.xmapping);
            break;
        }
      }
    }

    if (pollTable[POLL_STANDARD_INPUT].revents & POLLIN) return 1;
  }
}

static ProgramExitStatus
processStandardInput (Display *display) {
  while (awaitStandardInput(display)) {
    char buffer[0X100];
    const char *line = fgets(buffer, sizeof(buffer), stdin);
    if (!line) return PROG_EXIT_SUCCESS;

    {
      ProgramExitStatus exitStatus = processKeyNames(display, line);

      if (exitStatus == PROG_EXIT_SYNTAX) continue;
      if (exitStatus != PROG_EXIT_SUCCESS) return exitStatus;
    }
  }

  return PROG_EXIT_SYSTEM;
}

typedef struct {
  int value;
  KeySym symbol;
} CursesKeyEntry;

static const CursesKeyEntry cursesKeyTable[] = {
  {KEY_ENTER, XK_Return},
  {KEY_BACKSPACE, XK_BackSpace},

  {KEY_LEFT, XK_Left},
  {KEY_RIGHT, XK_Right},
  {KEY_UP, XK_Up},
  {KEY_DOWN, XK_Down},
  {KEY_PPAGE, XK_Prior},
  {KEY_NPAGE, XK_Next},

  {KEY_HOME, XK_Home},
  {KEY_END, XK_End},
  {KEY_IC, XK_Insert},
  {KEY_DC, XK_Delete},

  {KEY_F(1), XK_F1},
  {KEY_F(2), XK_F2},
  {KEY_F(3), XK_F3},
  {KEY_F(4), XK_F4},
  {KEY_F(5), XK_F5},
  {KEY_F(6), XK_F6},
  {KEY_F(7), XK_F7},
  {KEY_F(8), XK_F8},
  {KEY_F(9), XK_F9},
  {KEY_F(10), XK_F10},
  {KEY_F(11), XK_F11},
  {KEY_F(12), XK_F12},

  /* CtrlH - BS  */ {0X08, XK_BackSpace},
  /* CtrlI - HT  */ {0X09, XK_Tab},
  /* CtrlJ - LF  */ {0X0A, XK_Return},
  /* CtrlM - CR  */ {0X0D, XK_Return},
  /* Ctrl[ - ESC */ {0X1B, XK_Escape},
  /* Ctrl? - DEL */ {0X7F, XK_BackSpace},

  /* end of table */
  {0, NoSymbol}
};

static int
compareCursesKeyValues (int key1, int key2) {
  if (key1 < key2) return -1;
  if (key1 > key2) return 1;
  return 0;
}

static int
sortCursesKeyEntries (const void *element1, const void *element2) {
  const CursesKeyEntry *const *key1 = element1;
  const CursesKeyEntry *const *key2 = element2;
  return compareCursesKeyValues((*key1)->value, (*key2)->value);
}

static int
searchCursesKeyEntry (const void *target, const void *element) {
  const int *value = target;
  const CursesKeyEntry *const *key = element;
  return compareCursesKeyValues(*value, (*key)->value);
}

static KeySym
getCursesKeySymbol (int value) {
  static const CursesKeyEntry **sortedCursesKeyEntries = NULL;
  static unsigned int cursesKeyCount = 0;

  if (!sortedCursesKeyEntries) {
    {
      const CursesKeyEntry *key = cursesKeyTable;
      while (key->value) key += 1;
      cursesKeyCount = key - cursesKeyTable;
    }

    if (!(sortedCursesKeyEntries = malloc(cursesKeyCount * sizeof(*sortedCursesKeyEntries)))) {
      return NoSymbol;
    }

    {
      const CursesKeyEntry *source = cursesKeyTable;
      const CursesKeyEntry **target = sortedCursesKeyEntries;
      while (source->value) *target++ = source++;
    }

    qsort(sortedCursesKeyEntries, cursesKeyCount, sizeof(*sortedCursesKeyEntries), sortCursesKeyEntries);
  }

  {
    const CursesKeyEntry **key = bsearch(&value, sortedCursesKeyEntries, cursesKeyCount, sizeof(*sortedCursesKeyEntries), searchCursesKeyEntry);
    return key? (*key)->symbol: NoSymbol;
  }
}

static ProgramExitStatus
processCursesInput (Display *display) {
  ProgramExitStatus exitStatus = PROG_EXIT_SYSTEM;
  WINDOW *window;

  if ((window = initscr())) {
    putMessage = putCursesMessage;

    raw();
    noecho();
    typeahead(-1);

    intrflush(window, 0);
    keypad(window, 1);
    meta(window, 1);
    nodelay(window, 1);

    refresh();
    while (awaitStandardInput(display)) {
      int type;
      wint_t value;

      while ((type = get_wch(&value)) != ERR) {
        KeyCode code;
        unsigned int modifiers;

        erase();

        if (type == OK) {
          logMessage("character: U+%04X", value);
          if (!getKeyCodeAndModifiers(display, getCharacterKeySymbol(value), &code, &modifiers)) type = KEY_CODE_YES;
        }

        if (type == KEY_CODE_YES) {
          logMessage("key: 0X%X", value);

          if (!getKeyCodeAndModifiers(display, getCursesKeySymbol(value), &code, &modifiers)) {
            switch (value) {
              case 0X18: /* CtrlX - exit */
                exitStatus = PROG_EXIT_SUCCESS;
                goto done;

              default:
                beep();
                continue;
            }
          }
        }

        {
          const KeyCode codes[] = {code, 0};
          if (!sendKey(display, modifiers, codes)) break;
        }

        refresh();
      }
    }

  done:
    refresh();
    endwin();
    putMessage = putProgramMessage;
  }

  return exitStatus;
}

static void
setProgramName (const char *path) {
  programName = path;

  {
    const char *delimiter = strrchr(programName, '/');
    if (delimiter) programName = delimiter + 1;
  }
}

static int
processOptions (int *argc, char ***argv) {
  const char *options = ":cd:";
  int option;

  while ((option = getopt(*argc, *argv, options))  != -1) {
    switch (option) {
      case 'c':
        useCurses = 1;
        break;

      case 'd':
        displayName = optarg;
        break;

      case '?':
        logMessage("unknown option: -%c", optopt);
        return 0;

      case ':':
        logMessage("missing operand: -%c", optopt);
        return 0;

      default:
        logMessage("unimplemented option: -%c", option);
        return 0;
    }
  }

  *argv += optind, *argc -= optind;
  return 1;
}

int
main (int argc, char **argv) {
  ProgramExitStatus exitStatus = PROG_EXIT_UNKNOWN;

  setProgramName(argv[0]);
  putMessage = putProgramMessage;

  if (processOptions(&argc, &argv)) {
    if (!displayName) displayName = getenv("DISPLAY");

    if (displayName && *displayName) {
      Display *displayObject;

      if ((displayObject = XOpenDisplay(displayName))) {
        if (argc) {
          do {
            if ((exitStatus = processKeyNames(displayObject, *argv++)) != PROG_EXIT_SUCCESS) break;
          } while (--argc);
        } else if (useCurses) {
          exitStatus = processCursesInput(displayObject);
        } else {
          exitStatus = processStandardInput(displayObject);
        }

        XCloseDisplay(displayObject);
      } else {
        logMessage("cannot open display: %s", displayName);
        exitStatus = PROG_EXIT_SYSTEM;
      }
    } else {
      logMessage("display name not specified");
      exitStatus = PROG_EXIT_SEMANTIC;
    }
  } else {
    exitStatus = PROG_EXIT_SYNTAX;
  }

  return exitStatus;
}
