import Cocoa

func eventCallback(_: CGEventTapProxy,
                   type: CGEventType,
                   event: CGEvent,
                   _: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    switch type {
    case .tabletProximity: handleProximityEvent(event)
    case .keyDown: handleKeyDownEvent(event)
    default: ()
    }
    // return nil to consume the event.
    return nil
}

/// Start running the keystroke monitor. Note that this means the program will
/// stay alive and will run forever.
func startKeystrokeMonitor() {
    let eventMask =
        (1 << CGEventType.keyDown.rawValue) |
        (1 << CGEventType.tabletProximity.rawValue)
    guard let eventTap = CGEvent.tapCreate(tap: .cghidEventTap, place: .headInsertEventTap, options: .defaultTap, eventsOfInterest: CGEventMask(eventMask), callback: eventCallback, userInfo: nil) else {
        print("Failed to create event tap")
        exit(1)
    }
    let rlSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
    CFRunLoopAddSource(CFRunLoopGetCurrent(), rlSource, .commonModes)
    CGEvent.tapEnable(tap: eventTap, enable: true)
    CFRunLoopRun()
}
