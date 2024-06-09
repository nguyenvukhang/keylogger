import Cocoa
import ObjCWacom

let helium = Helium()
var lastUsedTablet: Int32 = 0
var scale = 0.5
var aspectRatio = 16.0 / 10.0
var lineWidth = 5.0
var lineColor = NSColor(red: 0.925, green: 0.282, blue: 0.600, alpha: 0.5)
var cornerLength = 50.0
var fullscreenKeepAspectRatio = false

func handleProximityEvent(_ event: CGEvent) {
    let isEnteringProximity = event.getIntegerValueField(.tabletProximityEventEnterProximity) != 0
    helium.penInProximity = isEnteringProximity
    lastUsedTablet = Int32(event.getIntegerValueField(.tabletProximityEventSystemTabletID))
}

func handleKeyDownEvent(_ event: CGEvent) {
    let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
    let flags = event.flags
    // this is when keyCode == 't' in US ANSI
    if keyCode == 17, flags.contains([.maskControl, .maskAlternate, .maskCommand]) {
        if flags.contains(.maskShift) {
            helium.mode = .fullscreen
            helium.display()
        } else {
            helium.mode = .precision
            helium.display()
        }
    }
    // Ctrl+C kills the program
    if keyCode == 0x08, flags.contains(.maskControl) { exit(0) }
}

func main() {
    let overlayWindowController = NSWindowController(window: helium.overlay)
    overlayWindowController.showWindow(helium.overlay)
    startKeystrokeMonitor()
}

main()
