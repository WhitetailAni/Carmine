//
//  Untitled.swift
//  Carmine
//
//  Created by WhitetailAni on 11/30/24.
//

import AppKit
import CoreLocation
import PaceTracker

class PTMenuItem: NSMenuItem {
    var route: PTRoute?
    var vehicleId: String?
    var coordinate: CLLocationCoordinate2D?
    var stop: PTStop?
    
    var vehicleHeading: Int?
    
    var timeLastUpdated: String?
    
    var linkToOpen: URL?
}
