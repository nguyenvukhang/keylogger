import Cocoa
import ObjCWacom

var lastFlags: CGEventFlags = .init()
var lastUsedTablet: Int32 = 0

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
            setPrecisionMode()
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
    lastUsedTablet = Int32(event.getIntegerValueField(.tabletProximityEventSystemTabletID))

    print(isEntering ? "TABLET ENTER" : "TABLET EXIT")
}

/** Make the tablet cover the area around the cursor's current location. */
func setPrecisionMode() {
    let frame = NSScreen.current().frame
    let area = frame.precisionModeFrame(
        at: NSEvent.mouseLocation,
        scale: 0.5,
        aspectRatio: 16 / 10)
    setTabletMapArea(to: area)
    // moveOverlay(to: area)
}

/** Sends a WacomTabletDriver API call to override tablet map area. */
func setTabletMapArea(to rect: NSRect) {
    ObjCWacom.setScreenMapArea(rect, tabletId: lastUsedTablet)
}

let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault,
                                                  eventTap,
                                                  0)
CFRunLoopAddSource(CFRunLoopGetCurrent(),
                   runLoopSource,
                   .commonModes)
CGEvent.tapEnable(tap: eventTap, enable: true)
CFRunLoopRun()

// print(NSScreen.current())
// var rect = NSScreen.current().frame
// rect.size.width /= 2
// rect.size.height /= 2
// ObjCWacom.setScreenMapArea(rect, tabletId: 0)
