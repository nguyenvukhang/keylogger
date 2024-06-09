import Cocoa
import ObjCWacom

/// A binary enum that just has better readability.
enum Mode {
    case precision
    case fullscreen

    mutating func next() {
        self = switch self {
        case .precision: .fullscreen
        case .fullscreen: .precision
        }
    }
}

/// Wraps Wacom with Helium's app state.
/// This includes preferences and running-state variables such as last-used tablet.
class Helium {
    var showBounds = true
    let overlay: Overlay
    var lastUsedTablet: Int32 = 0 // initialize with invalid tablet ID

    var penInProximity: Bool = false {
        didSet {
            if penInProximity { showOverlay() } else { hideOverlay() }
            print(penInProximity)
        }
    }

    var mode: Mode = .fullscreen {
        didSet {
            switch mode {
            case .fullscreen: setFullScreenMode()
            case .precision: setPrecisionMode()
            }
        }
    }

    init() {
        self.mode = .fullscreen
        self.overlay = Overlay()
    }

    func showOverlay() {
        if mode == .precision, showBounds {
            overlay.show()
        }
    }

    func hideOverlay() {
        overlay.hide()
    }

    func display() {
        switch mode {
        case .precision: if penInProximity {
                overlay.show()
            } else {
                overlay.flash()
            }
        case .fullscreen: overlay.flash()
        }
    }

    /// Make the tablet cover the area around the cursor's current location.
    func setPrecisionMode() {
        let frame = NSScreen.current().frame
        let area = frame.precisionModeFrame(at: NSEvent.mouseLocation, scale: scale, aspectRatio: aspectRatio)
        setTabletMapArea(to: area)
        moveOverlay(to: area)
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

    /// Rehydrate running state after settings have changed
    func previewOverlay() {
        let prevMode = mode
        setPrecisionMode()
        display()
        mode = prevMode
    }

    /// Move overlay to cover target NSRect
    private func moveOverlay(to rect: NSRect) {
        overlay.set(to: rect, lineColor: lineColor, lineWidth: lineWidth, cornerLength: cornerLength)
    }

    /// Sends a WacomTabletDriver API call to override tablet map area.
    /// Also makes the overlay follow wherever it goes.

    private func setTabletMapArea(to rect: NSRect) {
        ObjCWacom.setScreenMapArea(rect, tabletId: lastUsedTablet)
    }

    /// Reset screen map area to current screen. For use upon exiting.
    func reset() {
        ObjCWacom.setScreenMapArea(NSScreen.current().frame, tabletId: lastUsedTablet)
    }
}
