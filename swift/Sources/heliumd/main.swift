import Cocoa
import ObjCWacom

let overlay = Overlay()
var lastUsedTablet: Int32 = 0
var scale = 0.5
var aspectRatio = 16.0 / 10.0
var lineWidth = 5.0
var lineColor = NSColor(red: 0.925, green: 0.282, blue: 0.600, alpha: 0.5)
var cornerLength = 50.0
var fullscreenKeepAspectRatio = false

func handleProximityEvent(_ event: CGEvent) {
    // let isEntering = event.getIntegerValueField(.tabletProximityEventEnterProximity) != 0
    lastUsedTablet = Int32(event.getIntegerValueField(.tabletProximityEventSystemTabletID))
}

func handleKeyDownEvent(_ event: CGEvent) {
    let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
    let flags = event.flags
    // this is when keyCode == 't' in US ANSI
    if keyCode == 17, flags.contains([.maskControl, .maskAlternate, .maskCommand]) {
        if flags.contains(.maskShift) {
            print("Fullscreen Mode")
        } else {
            print("Precision Mode")
            setPrecisionMode()
        }
    }
    if keyCode == 0x08, flags.contains(.maskControl) {
        exit(0)
    }
}

/// Move overlay to cover target NSRect
func moveOverlay(to rect: NSRect) {
    overlay.set(to: rect, lineColor: lineColor, lineWidth: lineWidth, cornerLength: cornerLength)
}

func main() {
    let overlayWindowController = NSWindowController(window: overlay)
    overlayWindowController.showWindow(overlay)
    startKeystrokeMonitor()
}

main()
