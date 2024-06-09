import Cocoa
import ObjCWacom

extension NSScreen {
    /**
     * Gets the screen that contains the user's cursor.
     */
    static func current() -> NSScreen {
        NSScreen.screens.first { s in NSPointInRect(NSEvent.mouseLocation, s.frame) }!
    }
}

var lastFlags: CGEventFlags = .init()

func handleKeyDown() {}

func isKeyDown(_ type: CGEventType, _ event: CGEvent, _ keyCode: UInt16) -> Bool {
    if type == .keyDown {
        return true
    }
    if type == .flagsChanged {
        let flags = event.flags
        switch keyCode {
        case 54, 55: return flags.contains(.maskCommand) && !lastFlags.contains(.maskCommand)
        case 56, 60: return flags.contains(.maskShift) && !lastFlags.contains(.maskShift)
        case 58, 61: return flags.contains(.maskAlternate) && !lastFlags.contains(.maskAlternate)
        case 59, 62: return flags.contains(.maskControl) && !lastFlags.contains(.maskControl)
        default: return false
        }
    }
    return false
}

func eventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
    let down = isKeyDown(type, event, keyCode)
    lastFlags = event.flags
    if type == .tabletProximity {
        handleProximityEvent(event)
        return Unmanaged.passUnretained(event)
    }
    if !down { return Unmanaged.passUnretained(event) }

    // this is when keyCode == 't' in US ANSI
    if keyCode == 17, event.flags.contains([.maskControl, .maskAlternate, .maskCommand]) {
        if event.flags.contains(.maskShift) {
            print("Fullscreen Mode")
        } else {
            print("Precision Mode")
        }
    }
    if keyCode == 0x08, event.flags.contains(.maskControl) {
        exit(0)
    }
    return Unmanaged.passUnretained(event)
}

let eventMask = (1 << CGEventType.keyDown.rawValue)
    | (1 << CGEventType.flagsChanged.rawValue)
    | (1 << CGEventType.tabletProximity.rawValue)
guard let eventTap = CGEvent.tapCreate(tap: .cghidEventTap,
                                       place: .headInsertEventTap,
                                       options: .defaultTap,
                                       eventsOfInterest: CGEventMask(eventMask),
                                       callback: eventCallback,
                                       userInfo: nil) else {
    print("Failed to create event tap")
    exit(1)
}

func handleProximityEvent(_ event: CGEvent) {
    let isEntering = event.getIntegerValueField(.tabletProximityEventEnterProximity) != 0
    print(isEntering ? "TABLET ENTER" : "TABLET EXIT")
}

func runLoop() {
    let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault,
                                                      eventTap,
                                                      0)
    CFRunLoopAddSource(CFRunLoopGetCurrent(),
                       runLoopSource,
                       .commonModes)
    CGEvent.tapEnable(tap: eventTap, enable: true)
    CFRunLoopRun()
}

runLoop()

print(NSScreen.current())
var rect = NSScreen.current().frame
rect.size.width /= 2
rect.size.height /= 2
ObjCWacom.setScreenMapArea(rect, tabletId: 0)
