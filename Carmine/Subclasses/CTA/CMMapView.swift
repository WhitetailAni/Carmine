//
//  MapViewController.swift
//  Carmine
//
//  Created by WhitetailAni on 7/23/24.
//

import AppKit
import MapKit
import SwiftUI

class CMMapView: MKMapView {
    var bus: CMPlacemark
    var stop: CMPlacemark
    var timeLastUpdated: String
    var timeLabel: NSTextField!
    
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
        
        DispatchQueue.global().async {
            self.removeOverlays(self.overlays)
            if self.bus.route?.routeNumber() == "19" {
                let coords: [CLLocationCoordinate2D] = [
                    CLLocationCoordinate2D(41.88136784248596, -87.67372637549701),
                    CLLocationCoordinate2D(41.881398763089514, -87.67175818689059),
                    CLLocationCoordinate2D(41.88217282584554, -87.67178023817601),
                    CLLocationCoordinate2D(41.882264568795094, -87.67178023817601),
                    CLLocationCoordinate2D(41.88231344008106, -87.6716887189005),
                    CLLocationCoordinate2D(41.882327120730636, -87.67158980030906),
                    CLLocationCoordinate2D(41.88240012768974, -87.66638001601436),
                    CLLocationCoordinate2D(41.88242066307094, -87.6662145229651),
                    CLLocationCoordinate2D(41.882660242053824, -87.66552956565401),
                    CLLocationCoordinate2D(41.882821101723984, -87.66494114595052),
                    CLLocationCoordinate2D(41.88287586237039, -87.66472048856171),
                    CLLocationCoordinate2D(41.882957343998974, -87.65880235847509),
                    CLLocationCoordinate2D(41.88306205166484, -87.65210318126968),
                    CLLocationCoordinate2D(41.88313863342739, -87.64740929596884),
                    CLLocationCoordinate2D(41.883155746049376, -87.6455934695401),
                    CLLocationCoordinate2D(41.88317970371595, -87.64415000258789),
                    CLLocationCoordinate2D(41.88318654876089, -87.64124008327298),
                    CLLocationCoordinate2D(41.88321050641193, -87.63689589116805),
                    CLLocationCoordinate2D(41.883224196494474, -87.63409630054753),
                    CLLocationCoordinate2D(41.8832204801674, -87.63258284746716),
                    CLLocationCoordinate2D(41.88318967747571, -87.63224266732608),
                    CLLocationCoordinate2D(41.883213635126076, -87.63092332002215),
                    CLLocationCoordinate2D(41.88323430629172, -87.63091623627055),
                    CLLocationCoordinate2D(41.88321719369076, -87.62935784346209),
                    CLLocationCoordinate2D(41.88320967714997, -87.62454478469299),
                    CLLocationCoordinate2D(41.88326785998136, -87.6243792916514),
                    CLLocationCoordinate2D(41.88334657784537, -87.62422758969659),
                    CLLocationCoordinate2D(41.88354166082952, -87.6242183956387),
                    CLLocationCoordinate2D(41.883955782383026, -87.62432412730419),
                    CLLocationCoordinate2D(41.88450337701024, -87.62438848570925)
                ]
                
                let polyline = CMPolyline(coordinates: coords, count: coords.count)
                DispatchQueue.main.sync {
                    self.addOverlay(polyline)
                }
            } else {
                let ids = self.bus.route?.gtfsKey() ?? []
                //let coordinates = ChicagoTransitInterface.polylines.overlayTable
                for id in ids {
                    self.displayId(id)
                }
            }
        }
        
        if stop.coordinate.latitude == 52.31697130005335 && stop.coordinate.longitude == 4.746418131532647 {
            zoomMapToBus()
        } else {
            zoomMapToBusAndStop()
        }
    }
    
    private func zoomMapToBus() {
        self.removeAnnotations(self.annotations)
        
        let busAnnotation = CMPointAnnotation()
        busAnnotation.coordinate = bus.coordinate
        busAnnotation.title = "\(bus.route?.textualRepresentation() ?? "Unknown") bus \(bus.vehicleNumber ?? "0000")"
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
        busAnnotation.title = "\(bus.route?.textualRepresentation() ?? "Unknown") bus \(bus.vehicleNumber ?? "0000")"
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
    
    private func displayId(_ id: Int) {
        DispatchQueue.main.sync {
            let coordinates = ChicagoTransitInterface.polylines.overlayTable
            let coords = coordinates[String(id)] ?? []
            let polyline = CMPolyline(coordinates: coords, count: coords.count)
            self.addOverlay(polyline)
        }
    }
    
    @objc func refreshBusPosition() {
        DispatchQueue.global().async {
            let instance = ChicagoTransitInterface()
            if let vehicleId = self.bus.vehicleNumber {
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

/*extension CMMapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? CMPolyline {
            let polylineRenderer = MKPolylineRenderer(polyline: polyline)
            polylineRenderer.strokeColor = polyline.color ?? CMRoute.defaultColor
            return polylineRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}*/

extension CMMapView: MKMapViewDelegate {
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
