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
    var busRoute: PTRoute?
    var vehicleNumber: String?
    var coordinate: CLLocationCoordinate2D?
    
    var vehicleHeading: String?
    
    var timeLastUpdated: String?
    
    var linkToOpen: URL?
}
