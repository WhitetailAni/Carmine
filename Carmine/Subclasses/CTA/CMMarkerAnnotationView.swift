//
//  CRMarkerAnnotationView.swift
//  Carmine
//
//  Created by WhitetailAni on 7/26/24.
//

import AppKit
import MapKit
import Foundation

class CMMarkerAnnotationView: MKMarkerAnnotationView {
    
    override var annotation: MKAnnotation? {
        didSet { configure(for: annotation) }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        configure(for: annotation)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(for annotation: MKAnnotation?) {
        if annotation is CMPointAnnotation {
            let annotation: CMPointAnnotation = annotation as! CMPointAnnotation
            if let route = annotation.mark?.route {
                if let vehicleId = annotation.mark?.vehicleId {
                    glyphText = vehicleId
                    markerTintColor = route.bgColor
                    glyphTintColor = route.textColor
                } else if annotation.mark?.stopName != nil {
                    glyphImage = .ctaBus
                    markerTintColor = route.bgColor
                    glyphTintColor = route.textColor
                }
                displayPriority = .required
            }
        }
    }
}
//thanks to https://stackoverflow.com/questions/63020138/how-to-custom-the-image-of-mkannotation-pin
