//
//  FindMyBusPaceMapView.swift
//  Carmine
//
//  Created by WhitetailAni on 6/11/25.
//

import AppKit
import MapKit
import SwiftUI
import PaceTracker

class FindMyBusPaceMapView: MKMapView {
    var vehicles: [PTVehicle]
    var vehicleIds: [String]
    var buses: [PTPlacemark] = []
    var timeLastUpdated: String
    var timeLabel: NSTextField!
    
    init(vehicles: [PTVehicle], vehicleIds: [String]) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "HH:mm", options: 0, locale: Locale.current)
        
        self.timeLastUpdated = dateFormatter.string(from: Date())
        for vehicle in vehicles {
            let bus = PTPlacemark(coordinate: vehicle.location)
            bus.route = vehicle.route!
            bus.vehicleId = vehicle.vehicleId
            self.buses.append(bus)
        }
        
        self.vehicles = vehicles
        self.vehicleIds = vehicleIds
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        self.pointOfInterestFilter = MKPointOfInterestFilter(including: [.airport, .publicTransport, .park, .hospital, .library, .museum, .nationalPark, .restroom, .postOffice, .beach])
        
        self.register(PTMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
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
                do {
                    let coordinateArrays = try PaceAPI().getPolyLineForRouteID(routeID: route.id)
                    for coordinateArray in coordinateArrays {
                        let polyline = PTPolyline(coordinates: coordinateArray, count: coordinateArray.count)
                        if route.number < 150 {
                            polyline.isPulse = true
                        }
                        self.addOverlay(polyline)
                    }
                } catch { }
            }
        }
        
        zoomMapToBuses()
    }
    
    private func zoomMapToBuses() {
        self.removeAnnotations(self.annotations)
        
        for bus in buses {
            if let route = bus.route, let vehicleId = bus.vehicleId {
                let annotation = PTPointAnnotation()
                annotation.coordinate = bus.coordinate
                if route.number < 150 {
                    annotation.title = "\(route.name) bus \(vehicleId)"
                } else {
                    annotation.title = "\(route.number) bus \(vehicleId)"
                }
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
            var vehicles: [PTVehicle] = []
            vehicles = PaceAPI().getVehiclesForIDs(vehicleIDs: self.vehicleIds)
            self.buses = []
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale.current
            dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "HH:mm", options: 0, locale: Locale.current)
            
            self.timeLastUpdated = dateFormatter.string(from: Date())
            
            for vehicle in vehicles {
                let bus = PTPlacemark(coordinate: vehicle.location)
                bus.route = vehicle.route
                bus.vehicleId = vehicle.vehicleId
                self.buses.append(bus)
            }
            
            DispatchQueue.main.sync {
                self.removeAnnotations(self.annotations)
                
                for bus in self.buses {
                    if let route = bus.route, let vehicleId = bus.vehicleId {
                        let annotation = PTPointAnnotation()
                        annotation.coordinate = bus.coordinate
                        annotation.title = "\(route.number) bus \(vehicleId)"
                        annotation.mark = bus
                        self.addAnnotation(annotation)
                    }
                }
                
                self.zoomMapToBuses()
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

