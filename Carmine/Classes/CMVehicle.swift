//
//  CMVehicle.swift
//  Carmine
//
//  Created by WhitetailAni on 6/11/25.
//

import Foundation
import CoreLocation

struct CMVehicle {
    var vehicleId: String
    var route: CMRoute
    var location: CLLocationCoordinate2D
    var destination: String
    var timestampLastUpdated: String
}
