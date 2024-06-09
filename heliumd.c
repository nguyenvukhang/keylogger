#include "heliumd.h"

CGEventFlags lastFlags = 0;
char ALPHA_NUMERIC_CGKEYCODE[93];

int main(int argc, const char *argv[]) {
  // Create an event tap to retrieve keypresses.
  CGEventMask eventMask =
      CGEventMaskBit(kCGEventKeyDown) | CGEventMaskBit(kCGEventFlagsChanged);
  CFMachPortRef eventTap =
      CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, 0, eventMask,
                       CGEventCallback, NULL);

  // Exit the program if unable to create the event tap.
  if (!eventTap) {
    fprintf(stderr, "ERROR: Unable to create event tap.\n");
    exit(1);
  }

  // Create a run loop source and add enable the event tap.
  CFRunLoopSourceRef runLoopSource =
      CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
  CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource,
                     kCFRunLoopCommonModes);
  CGEventTapEnable(eventTap, true);

  // Clear the logfile if clear argument used or log to specific file if given.
  if (argc == 2) {
    if (strcmp(argv[1], "clear") == 0) {
      fopen(logfileLocation, "w");
      printf("%s cleared.\n", logfileLocation);
      fflush(stdout);
      exit(1);
    } else {
      logfileLocation = argv[1];
    }
  }

  // Get the current time and open the logfile.
  time_t result = time(NULL);
  logfile = fopen(logfileLocation, "a");

  if (!logfile) {
    fprintf(stderr,
            "ERROR: Unable to open log file. Ensure that you have the "
            "proper permissions.\n");
    exit(1);
  }

  // Output to logfile.
  fprintf(logfile, "\n\nKeylogging has begun.\n%s\n",
          asctime(localtime(&result)));
  fflush(logfile);

  // Display the location of the logfile and start the loop.
  printf("Logging to: %s\n", logfileLocation);
  fflush(stdout);
  CFRunLoopRun();

  return 0;
}

bool isKeyDown(CGEventType type, CGEventFlags flags, CGKeyCode keyCode) {
  if (type == kCGEventKeyDown) return true;
  if (type == kCGEventFlagsChanged) {
    switch (keyCode) {
      case 54:  // [right-cmd]
      case 55:  // [left-cmd]
        return (flags & kCGEventFlagMaskCommand) &&
               !(lastFlags & kCGEventFlagMaskCommand);
      case 56:  // [left-shift]
      case 60:  // [right-shift]
        return (flags & kCGEventFlagMaskShift) &&
               !(lastFlags & kCGEventFlagMaskShift);
      case 58:  // [left-option]
      case 61:  // [right-option]
        return (flags & kCGEventFlagMaskAlternate) &&
               !(lastFlags & kCGEventFlagMaskAlternate);
      case 59:  // [left-ctrl]
      case 62:  // [right-ctrl]
        return (flags & kCGEventFlagMaskControl) &&
               !(lastFlags & kCGEventFlagMaskControl);
      case 57:  // [caps]
        return (flags & kCGEventFlagMaskAlphaShift) &&
               !(lastFlags & kCGEventFlagMaskAlphaShift);
    }
  }
  return false;
}

// The following callback method is invoked on every keypress.
CGEventRef CGEventCallback(CGEventTapProxy proxy, CGEventType type,
                           CGEventRef event, void *refcon) {
  if (type != kCGEventKeyDown && type != kCGEventFlagsChanged) return event;
  CGEventFlags flags = CGEventGetFlags(event);
  CGKeyCode keyCode =
      CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);

  bool down = isKeyDown(type, flags, keyCode);
  lastFlags = flags;
  if (!down) return event;

  if ((flags & kCGEventFlagMaskControl) &&
      (flags & kCGEventFlagMaskAlternate) &&
      (flags & kCGEventFlagMaskCommand) && keyCode == 17) {
    if (flags & kCGEventFlagMaskShift) {
      fprintf(stderr, "FullScreen Mode\n");
    } else {
      fprintf(stderr, "Precision Mode\n");
    }
    return event;
  }

  return event;
}
