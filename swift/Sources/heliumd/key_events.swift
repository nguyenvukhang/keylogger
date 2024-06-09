import Cocoa

func eventCallback(proxy _: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon _: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    switch type {
    case .tabletProximity: handleProximityEvent(event)
    case .keyDown: handleKeyDownEvent(event)
    default: ()
    }
    return Unmanaged.passUnretained(event)
}

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
