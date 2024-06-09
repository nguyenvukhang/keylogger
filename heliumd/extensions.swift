import Cocoa

extension NSScreen {
    /// Gets the screen that contains the user's cursor.
    static func current() -> NSScreen {
        NSScreen.screens.first { s in NSPointInRect(NSEvent.mouseLocation, s.frame) }!
    }
}
