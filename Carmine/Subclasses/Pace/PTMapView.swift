//
//  MapViewController.swift
//  Carmine
//
//  Created by WhitetailAni on 7/23/24.
//

import AppKit
import MapKit
import SwiftUI
import PaceTracker

class PTMapView: MKMapView {
    var mark: PTPlacemark
    var isVehicle: Bool
    var timeLastUpdated: String
    var timeLabel: NSTextField!
    
    init(mark: PTPlacemark, timeLastUpdated: String, isVehicle: Bool) {
        self.mark = mark
        self.timeLastUpdated = timeLastUpdated
        self.isVehicle = isVehicle
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        self.pointOfInterestFilter = MKPointOfInterestFilter(including: [.airport, .publicTransport, .park, .hospital, .library, .museum, .nationalPark, .restroom, .postOffice, .beach])
        
        self.register(PTMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        self.delegate = self
        
        timeLabel = NSTextField(labelWithString: "Updated at \(timeLastUpdated)")
        timeLabel.font = NSFont.systemFont(ofSize: 12)
        timeLabel.textColor = NSColor(r: 222, g: 222, b: 222)
        timeLabel.isBezeled = false
        timeLabel.drawsBackground = false
        timeLabel.isEditable = false
        timeLabel.sizeToFit()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            timeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            timeLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
        ])
        
        if isVehicle {
            let refreshButton = NSButton(image: NSImage(systemSymbolName: "arrow.clockwise", accessibilityDescription: nil)!, target: self, action: #selector(refreshBusPosition))
            refreshButton.translatesAutoresizingMaskIntoConstraints = false
            
            self.addSubview(refreshButton)
            
            NSLayoutConstraint.activate([
                refreshButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
                refreshButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            ])
        }
        
        DispatchQueue.global().async {
            do {
                let coordinateArrays = try PaceAPI().getPolyLineForRouteID(routeID: self.mark.route?.id ?? 0)
                var overlayArray: [PTPolyline] = []
                
                for coordinateArray in coordinateArrays {
                    let overlay = PTPolyline(coordinates: coordinateArray, count: coordinateArray.count)
                    overlay.isPulse = false
                    
                    if self.mark.route?.number ?? 404 < 150 {
                        overlay.isPulse = true
                    }
                    
                    overlayArray.append(overlay)
                }
                DispatchQueue.main.sync {
                    self.addOverlays(overlayArray)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        if isVehicle {
            zoomMapToBus()
        } else {
            zoomMapToStop()
        }
    }
    
    private func zoomMapToBus() {
        self.removeAnnotations(self.annotations)
        
        let annotation = PTPointAnnotation()
        annotation.coordinate = mark.coordinate
        annotation.title = "\(String(mark.route?.number ?? 0)) bus \(mark.vehicleId ?? "0000")"
        annotation.mark = mark
        self.addAnnotation(annotation)
        
        let coordinate = mark.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 360 / pow(2, 17) * Double(self.frame.size.width) / 256)
        self.setRegion(MKCoordinateRegion(center: coordinate, span: span), animated: true)
    }
    
    private func zoomMapToStop() {
        self.removeAnnotations(self.annotations)
        
        let annotation = PTPointAnnotation()
        annotation.coordinate = mark.coordinate
        annotation.title = "\(String(mark.route?.number ?? 0) ) stop \(mark.stopName ?? "Unknown")"
        annotation.mark = mark
        self.addAnnotation(annotation)
        
        let coordinate = mark.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 360 / pow(2, 17) * Double(self.frame.size.width) / 256)
        self.setRegion(MKCoordinateRegion(center: coordinate, span: span), animated: true)
    }
    
    @objc func refreshBusPosition() {
        DispatchQueue.global().async {
            if let vehicleId = self.mark.vehicleId {
                let location = PaceAPI().getLocationForVehicle(vehicleID: vehicleId, routeID: self.mark.route?.id ?? 0)
                
                DispatchQueue.main.sync {
                    if (location.longitude == -4.0 && location.latitude == -4.0) {
                        self.removeAnnotations(self.annotations)
                        let overlay = YOUDIED(text: "BUS STOPPED TRACKING")
                        self.addSubview(overlay)
                        overlay.frame = self .bounds
                        overlay.animate()
                    } else {
                        let dateFormatter = DateFormatter()
                        dateFormatter.locale = Locale.current
                        
                        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "HH:mm", options: 0, locale: Locale.current)
                        
                        self.mark = self.mark.placemarkWithNewLocation(location)
                        self.timeLabel.stringValue = "Updated at \(dateFormatter.string(from: Date()))"
                        
                        self.zoomMapToBus()
                    }
                }
            }
        }
    }
}

extension PTMapView: MKMapViewDelegate {
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
