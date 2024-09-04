//
//  CRMenuItem.swift
//  Carmine
//
//  Created by WhitetailAni on 7/23/24.
//

import AppKit
import CoreLocation

class CMMenuItem: NSMenuItem {
    var busRoute: CMRoute?
    var vehicleNumber: String?
    var vehicleCoordinate: CLLocationCoordinate2D?
    var vehicleDesiredStop: String?
    var vehicleDesiredStopID: String?
    
    var vehicleTerminus: String?
    var vehicleTerminusID: String?
    var vehicleDirection: String?
    
    var timeLastUpdated: String?
    
    var linkToOpen: URL?
}

