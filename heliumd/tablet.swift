import Cocoa
import ObjCWacom

/// Sends a WacomTabletDriver API call to override tablet map area.
func setTabletMapArea(to rect: NSRect) {
    ObjCWacom.setScreenMapArea(rect, tabletId: lastUsedTablet)
}
