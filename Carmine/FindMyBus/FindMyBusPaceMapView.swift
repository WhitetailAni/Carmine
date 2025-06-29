//
//  FindMyBusPaceMapView.swift
//  Carmine
//
//  Created by WhitetailAni on 6/11/25.
//

import AppKit
import MapKit
import SwiftUI

class FindMyBusPaceMapView: MKMapView {
    var bus: CMPlacemark
    var stop: CMPlacemark
    var timeLastUpdated: String
    var timeLabel: NSTextField!
    var n5: Bool = false
    
    init(bus: CMPlacemark, timeLastUpdated: String) {
        self.bus = bus
        self.stop = CMPlacemark(coordinate: CLLocationCoordinate2D(latitude: 52.31697130005335, longitude: 4.746418131532647))
        self.timeLastUpdated = timeLastUpdated
        super.init(frame: .zero)
    }
    
    init(bus: CMPlacemark, stop: CMPlacemark, timeLastUpdated: String) {
        self.bus = bus
        self.stop = stop
        self.timeLastUpdated = timeLastUpdated
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        self.pointOfInterestFilter = MKPointOfInterestFilter(including: [.airport, .publicTransport, .park, .hospital, .library, .museum, .nationalPark, .restroom, .postOffice, .beach])
        
        self.register(CMMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        timeLabel = NSTextField(labelWithString: "Updated at \(timeLastUpdated)")
        timeLabel.font = NSFont.systemFont(ofSize: 12)
        timeLabel.textColor = NSColor(r: 222, g: 222, b: 222)
        timeLabel.isBezeled = false
        timeLabel.drawsBackground = false
        timeLabel.isEditable = false
        timeLabel.sizeToFit()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(timeLabel)
        
        self.delegate = self
        
        NSLayoutConstraint.activate([
            timeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            timeLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
        ])
        
        let refreshButton = NSButton(image: NSImage(systemSymbolName: "arrow.clockwise", accessibilityDescription: nil)!, target: self, action: #selector(refreshBusPosition))
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(refreshButton)
        
        NSLayoutConstraint.activate([
            refreshButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            refreshButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
        ])
        
        if let route = self.bus.route {
            self.addOverlays(ChicagoTransitInterface().getOverlaysForRoute(route: route))
            if route == ._95 && n5 {
                self.addOverlays(ChicagoTransitInterface().getOverlaysForRoute(route: ._N5))
            }
        }
        
        if [52.31697130005335, 0].contains(stop.coordinate.latitude) && [4.746418131532647, 0].contains(stop.coordinate.longitude) {
            zoomMapToBus()
        } else {
            zoomMapToBusAndStop()
        }
    }
    
    private func zoomMapToBus() {
        self.removeAnnotations(self.annotations)
        
        let busAnnotation = CMPointAnnotation()
        busAnnotation.coordinate = bus.coordinate
        busAnnotation.title = "\(bus.route?.routeNumber() ?? "Unknown")\(bus.route == ._N5 ? "" : " bus") \(bus.vehicleId ?? "0000")"
        busAnnotation.mark = bus
        self.addAnnotation(busAnnotation)
        
        let coordinate = bus.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 360 / pow(2, 17) * Double(self.frame.size.width) / 256)
        self.setRegion(MKCoordinateRegion(center: coordinate, span: span), animated: true)
    }
    
    private func zoomMapToBusAndStop() {
        self.removeAnnotations(self.annotations)
        
        let busAnnotation = CMPointAnnotation()
        busAnnotation.coordinate = bus.coordinate
        busAnnotation.title = "\(bus.route?.routeNumber() ?? "Unknown")\(bus.route == ._N5 ? "" : " bus") \(bus.vehicleId ?? "0000")"
        busAnnotation.mark = bus
        self.addAnnotation(busAnnotation)
        
        let stopAnnotation = CMPointAnnotation()
        stopAnnotation.coordinate = stop.coordinate
        stopAnnotation.title = stop.stopName ?? "Unknown"
        stopAnnotation.mark = stop
        
        self.addAnnotations([busAnnotation, stopAnnotation])
        
        let midpointLatitude = (busAnnotation.coordinate.latitude + stopAnnotation.coordinate.latitude) / 2
        let midpointLongitude = (busAnnotation.coordinate.longitude + stopAnnotation.coordinate.longitude) / 2
        let midpoint = CLLocationCoordinate2D(latitude: midpointLatitude, longitude: midpointLongitude)
        let latitudeDelta = abs(busAnnotation.coordinate.latitude - stopAnnotation.coordinate.latitude) * 1.53
        let longitudeDelta = abs(busAnnotation.coordinate.longitude - stopAnnotation.coordinate.longitude) * 1.53
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        self.setRegion(MKCoordinateRegion(center: midpoint, span: span), animated: true)
    }
    
    @objc func refreshBusPosition() {
        DispatchQueue.global().async {
            let instance = ChicagoTransitInterface()
            if let vehicleId = self.bus.vehicleId {
                let locationInfo = instance.getLocationForVehicleId(id: vehicleId)
                
                if locationInfo.latitude == -4, locationInfo.longitude == -4 {
                    return
                }
                
                DispatchQueue.main.sync {
                    self.bus = self.bus.placemarkWithNewLocation(locationInfo)
                    self.timeLabel.stringValue = "Updated at \({ let formatter = DateFormatter(); formatter.dateFormat = "HH:mm"; return formatter.string(from: Date()) }())"
                    
                    if self.stop.coordinate.latitude == 52.31697130005335 && self.stop.coordinate.longitude == 4.746418131532647 {
                        self.zoomMapToBus()
                    } else {
                        self.zoomMapToBusAndStop()
                    }
                }
            }
        }
    }
}

extension FindMyBusPaceMapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? PTPolyline {
            let polylineRenderer = MKPolylineRenderer(polyline: polyline)
            if polyline.isPulse == true {
                polylineRenderer.strokeColor = NSColor(r: 128, g: 76, b: 158)
            } else {
                polylineRenderer.strokeColor = NSColor(r: 0, g: 133, b: 255)
            }
            polylineRenderer.lineWidth = 4.0
            return polylineRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
