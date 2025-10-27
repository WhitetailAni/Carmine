//
//  FindMyBusCTASingleMapView.swift
//  Carmine
//
//  Created by WhitetailAni on 6/11/25.
//

import AppKit
import MapKit
import SwiftUI

class FindMyBusCTAMapView: MKMapView {
    var vehicleIds: [String]
    var buses: [CMPlacemark] = []
    var timeLastUpdated: String
    var timeLabel: NSTextField!
    
    init(vehicleIds: [String]) {
        var vehicles: [CMVehicle] = []
        if vehicleIds.count > 10 {
            let chunkedVehicleIds = vehicleIds.chunked(by: 10)
            for chunk in chunkedVehicleIds {
                vehicles.append(contentsOf: ChicagoTransitInterface().getInfoForVehicleIds(ids: chunk))
            }
        } else {
            vehicles = ChicagoTransitInterface().getInfoForVehicleIds(ids: vehicleIds)
        }
        
        self.timeLastUpdated = CMTime.apiTimeToReadabletime(string: vehicles[0].timestampLastUpdated)
        for vehicle in vehicles {
            let bus = CMPlacemark(coordinate: vehicle.location)
            bus.route = vehicle.route
            bus.vehicleId = vehicle.vehicleId
            bus.terminus = vehicle.destination
            self.buses.append(bus)
        }
        
        self.vehicleIds = vehicleIds
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
        
        for bus in buses {
            if let route = bus.route {
                self.addOverlays(ChicagoTransitInterface().getOverlaysForRoute(route: route))
                if let terminus = bus.terminus, route.number == "95", ["Commercial/92nd", "92nd/Commercial"].contains(terminus) {
                    self.addOverlays(ChicagoTransitInterface().getOverlaysForRoute(route: CMRoute.n5))
                }
            }
        }
        
        zoomMapToBuses()
    }
    
    private func zoomMapToBuses() {
        self.removeAnnotations(self.annotations)
        
        for bus in buses {
            if let route = bus.route, let vehicleId = bus.vehicleId {
                let annotation = CMPointAnnotation()
                annotation.coordinate = bus.coordinate
                annotation.title = "\(route.routeNumber())\(route.number == "N5" ? "" : " bus") \(vehicleId)"
                annotation.mark = bus
                self.addAnnotation(annotation)
            }
        }
        
        var coordinates: [CLLocationCoordinate2D] = []
        for bus in buses {
            coordinates.append(bus.coordinate)
        }
        
        if coordinates.count == 1 {
            let span = MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 360 / pow(2, 17) * Double(self.frame.size.width) / 256)
            self.setRegion(MKCoordinateRegion(center: coordinates[0], span: span), animated: true)
        } else {
            let latitudes = coordinates.map { $0.latitude }
            let longitudes = coordinates.map { $0.longitude }
            
            let minLat = latitudes.min()!
            let maxLat = latitudes.max()!
            let minLon = longitudes.min()!
            let maxLon = longitudes.max()!
            
            let midpointLatitude = (minLat + maxLat) / 2
            let midpointLongitude = (minLon + maxLon) / 2
            let midpoint = CLLocationCoordinate2D(latitude: midpointLatitude, longitude: midpointLongitude)
            
            let latitudeDelta = abs(maxLat - minLat) * 1.53
            let longitudeDelta = abs(maxLon - minLon) * 1.53
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            
            self.setRegion(MKCoordinateRegion(center: midpoint, span: span), animated: true)
        }
    }
    
    @objc func refreshBusPosition() {
        DispatchQueue.global().async {
            var vehicles: [CMVehicle] = []
            if self.vehicleIds.count > 10 {
                let chunkedVehicleIds = self.vehicleIds.chunked(by: 10)
                for chunk in chunkedVehicleIds {
                    vehicles.append(contentsOf: ChicagoTransitInterface().getInfoForVehicleIds(ids: chunk))
                }
            } else {
                vehicles = ChicagoTransitInterface().getInfoForVehicleIds(ids: self.vehicleIds)
            }
            
            self.buses = []
            
            self.timeLastUpdated = CMTime.apiTimeToReadabletime(string: vehicles[0].timestampLastUpdated)
            for vehicle in vehicles {
                let bus = CMPlacemark(coordinate: vehicle.location)
                bus.route = vehicle.route
                bus.vehicleId = vehicle.vehicleId
                bus.terminus = vehicle.destination
                self.buses.append(bus)
            }
            
            DispatchQueue.main.sync {
                self.removeAnnotations(self.annotations)
                
                for bus in self.buses {
                    if let route = bus.route, let vehicleId = bus.vehicleId {
                        let annotation = CMPointAnnotation()
                        annotation.coordinate = bus.coordinate
                        annotation.title = "\(route.routeNumber()) bus \(vehicleId)"
                        annotation.mark = bus
                        self.addAnnotation(annotation)
                    }
                }
                
                self.zoomMapToBuses()
            }
        }
    }
}

extension FindMyBusCTAMapView: MKMapViewDelegate {
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
