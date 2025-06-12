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
    var vehicleId: String?
    var stopName: String?
    var heading: Int?
    
    func placemarkWithNewLocation(_ location: CLLocationCoordinate2D) -> PTPlacemark {
        let mark = PTPlacemark(coordinate: location)
        mark.route = self.route
        mark.vehicleId = self.vehicleId
        mark.stopName = self.stopName
        mark.heading = self.heading
        return mark
    }
}
