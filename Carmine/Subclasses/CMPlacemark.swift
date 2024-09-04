//
//  CMPlacemark.swift
//  Carmine
//
//  Created by WhitetailAni on 7/23/24.
//

import MapKit

class CMPlacemark: MKPlacemark, @unchecked Sendable {
    var route: CMRoute?
    var vehicleNumber: String?
    var stopName: String?
    var stopId: String?
    var direction: String?
    
    func placemarkWithNewLocation(_ location: CLLocationCoordinate2D) -> CMPlacemark {
        let mark = CMPlacemark(coordinate: location)
        mark.route = self.route
        mark.vehicleNumber = self.vehicleNumber
        mark.stopName = self.stopName
        return mark
    }
}
