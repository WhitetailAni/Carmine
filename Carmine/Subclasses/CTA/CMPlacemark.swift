//
//  CMPlacemark.swift
//  Carmine
//
//  Created by WhitetailAni on 7/23/24.
//

import MapKit

class CMPlacemark: MKPlacemark, @unchecked Sendable {
    var route: CMRoute?
    var vehicleId: String?
    var stopName: String?
    var stopId: String?
    var direction: String?
    var terminus: String?
    
    func placemarkWithNewLocation(_ location: CLLocationCoordinate2D) -> CMPlacemark {
        let mark = CMPlacemark(coordinate: location)
        mark.route = self.route
        mark.vehicleId = self.vehicleId
        mark.stopName = self.stopName
        return mark
    }
}
