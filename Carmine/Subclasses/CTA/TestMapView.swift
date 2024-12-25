//
//  MapViewController.swift
//  Carmine
//
//  Created by WhitetailAni on 7/23/24.
//

import AppKit
import MapKit
import SwiftUI

class TestMapView: MKMapView {
    var coordinates: [String: [CLLocationCoordinate2D]] = [:]
    
    init() { super.init(frame: .zero) }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var routeField: NSTextField = {
        let textField = NSTextField(frame: NSRect(x: 10, y: self.frame.height - 60, width: self.frame.width / 2 - 20, height: 40))
        textField.placeholderString = "route request"
        textField.delegate = self
        textField.tag = 1
        return textField
    }()
    
    private lazy var idField: NSTextField = {
        let textField = NSTextField(frame: NSRect(x: self.frame.width / 2 + 10, y: self.frame.height - 60, width: self.frame.width / 2 - 20, height: 40))
        textField.placeholderString = "id input"
        textField.delegate = self
        textField.tag = 2
        return textField
    }()
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        self.pointOfInterestFilter = MKPointOfInterestFilter(including: [.airport, .publicTransport, .park])
        
        coordinates = ChicagoTransitInterface.polylines.overlayTable
        
        //let span = MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 360 / pow(2, 17) * Double(self.frame.size.width) / 256)
        //self.setRegion(MKCoordinateRegion(center: nineteenArray[5], span: span), animated: true)
        
        //let line = MKPolyline(coordinates: nineteenArray, count: nineteenArray.count)
        //self.addOverlay(line)
        
        let span = MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 360 / pow(2, 17) * Double(self.frame.size.width) / 64)
        self.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(41.87745052316166, -87.66492834118198), span: span), animated: true)
        
        self.addSubview(routeField)
        self.addSubview(idField)
        
        self.register(CMMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        self.delegate = self
    }
}

extension TestMapView: NSTextFieldDelegate {
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            guard let textField = control as? NSTextField else { return false }
            
            let text = textField.stringValue
            
            switch textField.tag {
            case 1:
                { }()
            case 2:
                displayId(text)
            default:
                break
            }
            
            return true
        }
        return false
    }
    
    func displayId(_ text: String) {
        self.removeOverlays(self.overlays)
        let ids = text.components(separatedBy: ",")
        for id in ids {
            let coords = coordinates[id] ?? []
            let polyline = MKPolyline(coordinates: coords, count: coords.count)
            self.addOverlay(polyline)
        }
    }
}

extension TestMapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let polylineRenderer = MKPolylineRenderer(polyline: polyline)
            /*if polyline.isPulse == true {
                polylineRenderer.strokeColor = NSColor(r: 128, g: 76, b: 158)
            } else {
                polylineRenderer.strokeColor = NSColor(r: 0, g: 133, b: 255)
            }*/
            polylineRenderer.strokeColor = NSColor(r: 107, g: 160, b: 227)
            polylineRenderer.lineWidth = 4.0
            return polylineRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
