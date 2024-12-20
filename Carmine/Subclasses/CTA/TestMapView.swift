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
        
        let nineteenArray: [CLLocationCoordinate2D] = [
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
                lookUpRoute(text)
            case 2:
                displayId(text)
            default:
                break
            }
            
            return true
        }
        return false
    }
    
    func lookUpRoute(_ text: String) {
        print("deprecated")
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
