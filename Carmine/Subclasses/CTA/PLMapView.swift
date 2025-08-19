//
//  PLMapView.swift
//  Carmine
//
//  Created by WhitetailAni on 6/14/25.
//

import AppKit
import MapKit
import SwiftUI

class PLMapView: MKMapView {
    var old: CMPolyline
    var new: CMPolyline
    var list = ""
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(old: CMPolyline, new: CMPolyline) {
        self.old = old
        self.new = new
        super.init(frame: .zero)
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        self.delegate = self
        
        self.pointOfInterestFilter = MKPointOfInterestFilter(including: [.airport, .publicTransport, .park, .hospital, .library, .museum, .nationalPark, .restroom, .postOffice, .beach])
        
        self.removeOverlays(self.overlays)
        self.addOverlay(self.new)
        self.addOverlay(self.old)
        
        let coordinate = CLLocationCoordinate2D(latitude: 41.87885, longitude: -87.66146)
        let span = MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 360 / pow(2, 17) * Double(self.frame.size.width) / 2)
        self.setRegion(MKCoordinateRegion(center: coordinate, span: span), animated: true)
    }
}

extension PLMapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? CMPolyline {
            let polylineRenderer = MKPolylineRenderer(polyline: polyline)
            polylineRenderer.strokeColor = polyline.color ?? NSColor(r: 107, g: 160, b: 227)
            polylineRenderer.lineWidth = 4.0
            return polylineRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
