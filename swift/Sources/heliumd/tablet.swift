import Cocoa
import ObjCWacom

/// Sends a WacomTabletDriver API call to override tablet map area.
func setTabletMapArea(to rect: NSRect) {
    ObjCWacom.setScreenMapArea(rect, tabletId: lastUsedTablet)
}

/// Make the tablet cover the whole screen that contains the user's cursor.
func setFullScreenMode() {
    var frame = NSScreen.current().frame
    if fullscreenKeepAspectRatio {
        frame = frame.centeredSubRect(withAspectRatio: aspectRatio)
    }
    setTabletMapArea(to: frame)
    overlay.fullscreen(to: &frame, lineColor: lineColor, lineWidth: lineWidth, cornerLength: cornerLength)
}

/// Make the tablet cover the area around the cursor's current location.
func setPrecisionMode() {
    let frame = NSScreen.current().frame
    let area = frame.precisionModeFrame(
        at: NSEvent.mouseLocation,
        scale: scale,
        aspectRatio: aspectRatio)
    setTabletMapArea(to: area)
    moveOverlay(to: area)
    overlay.show()
}
