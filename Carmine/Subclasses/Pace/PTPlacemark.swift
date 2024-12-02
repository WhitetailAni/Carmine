//
//  PTPlacemark.swift
//  Carmine
//
//  Created by WhitetailAni on 12/1/24.
//

import MapKit
import PaceTracker

class PTPlacemark: MKPlacemark, @unchecked Sendable {
    var route: PTRoute?
    var vehicleNumber: String?
    var stopName: String?
    var heading: Int?
    
    func placemarkWithNewLocation(_ location: CLLocationCoordinate2D) -> PTPlacemark {
        let mark = PTPlacemark(coordinate: location)
        mark.route = self.route
        mark.vehicleNumber = self.vehicleNumber
        mark.stopName = self.stopName
        mark.heading = self.heading
        return mark
    }
}
