//
//  Untitled.swift
//  Carmine
//
//  Created by WhitetailAni on 4/30/25.
//

import AppKit
import SwiftUI
import CoreLocation
import PaceTracker

struct FindMyBusView: View {
    @State var input: String = ""
    @State var selection: FindMyBusShownView
    
    @State var error = false
    @State var errorString = ""
    @State var thinking = false
    
    var body: some View {
        switch selection {
        case .rootSelector:
            VStack {
                Button(action: {
                    selection = .cta
                }) {
                    Image("cta")
                        .resizable()
                        .frame(width: 300, height: 75)
                    
                }
                .buttonStyle(.borderless)
                .padding(15)
                
                Button(action: {
                    print("pace")
                }) {
                    Image("pace")
                    //.resizable()
                        .frame(width: 300)
                }
                .buttonStyle(.borderless)
                .padding(15)
                
            }
        case .cta:
            VStack {
                HStack {
                    Image("cta")
                        .resizable()
                        .frame(width: 214, height: 50)
                    Text("Enter a single vehicle ID, or a range - example \"1001-1020\"")
                        .frame(width: 200)
                        .fixedSize()
                }
                .padding(15)
                
                if error {
                    Text(errorString)
                }
                if thinking {
                    ProgressView()
                        .progressViewStyle(.linear)
                        .padding(.horizontal, 15)
                }
                
                TextField("", text: $input)
                    .padding(15)
                    .onSubmit {
                        error = false
                        thinking = true
                        if input.contains("-") {
                            let range = input.components(separatedBy: "-")
                            if let first = Int(range[0]), let last = Int(range[1]) {
                                DispatchQueue.global().async {
                                    let list = Array(stride(from: first, through: last, by: 1))
                                    var registeredBuses: [String] = []
                                    for id in list {
                                        let testLocation = ChicagoTransitInterface().getLocationForVehicleId(id: String(id))
                                        if testLocation.latitude == -4 && testLocation.longitude == -4 {
                                            continue
                                        } else if testLocation.latitude == -8 && testLocation.longitude == -8 {
                                            thinking = false
                                            error = true
                                            errorString = "Daily API request limit has been reached"
                                            break
                                        }
                                        registeredBuses.append(String(id))
                                    }
                                    if registeredBuses.count == 0 {
                                        thinking = false
                                        error = true
                                        if errorString == "" {
                                            errorString = "No vehicle IDs within the provided range registered on the tracker"
                                        }
                                    } else {
                                        DispatchQueue.main.sync {
                                            (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusMutex.lock()
                                            if let screenSize = NSScreen.main?.frame.size {
                                                let window = NSWindow(contentRect: NSMakeRect(0, 0, screenSize.width * 0.5, screenSize.height * 0.5), styleMask: [.titled, .closable], backing: .buffered, defer: false)
                                                let index = (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusWindows.count
                                                (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusWindows.append(window)
                                                let view = FindMyBusCTAMapView(vehicleIds: registeredBuses)
                                                (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusWindows[index].contentView = view
                                                
                                                (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusWindows[index].center()
                                                (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusWindows[index].setIsVisible(true)
                                                (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusWindows[index].orderFrontRegardless()
                                                (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusWindows[index].makeKey()
                                                NSApp.activate(ignoringOtherApps: true)
                                                self.thinking = false
                                            }
                                            (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusMutex.unlock()
                                        }
                                    }
                                }
                            } else {
                                thinking = false
                                error = true
                                errorString = "Improperly formatted range"
                            }
                        } else {
                            let testLocation = ChicagoTransitInterface().getLocationForVehicleId(id: input)
                            if testLocation.latitude == -4 && testLocation.longitude == -4 {
                                thinking = false
                                error = true
                                errorString = "Vehicle is not registered on the tracker"
                            } else if testLocation.latitude == -8 && testLocation.longitude == -8 {
                                thinking = false
                                error = true
                                errorString = "Daily API request limit has been reached"
                            } else {
                                (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusMutex.lock()
                                if let screenSize = NSScreen.main?.frame.size {
                                    let window = NSWindow(contentRect: NSMakeRect(0, 0, screenSize.width * 0.5, screenSize.height * 0.5), styleMask: [.titled, .closable], backing: .buffered, defer: false)
                                    let index = (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusWindows.count
                                    (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusWindows.append(window)
                                    let view = FindMyBusCTAMapView(vehicleIds: [input])
                                    
                                    (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusWindows[index].title = "Carmine - Find My Bus CTA"
                                    (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusWindows[index].contentView = view
                                    
                                    (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusWindows[index].center()
                                    (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusWindows[index].setIsVisible(true)
                                    (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusWindows[index].orderFrontRegardless()
                                    (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusWindows[index].makeKey()
                                    NSApp.activate(ignoringOtherApps: true)
                                    self.thinking = false
                                }
                                (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusMutex.unlock()
                            }
                        }
                    }
            }
            .frame(width: (NSScreen.main?.frame.size.width ?? 1500) * 0.26)
        case .pace:
            HStack {
                Image("pace")
                    .resizable()
                    .frame(width: 214, height: 50)
                Text("Enter a single vehicle ID, or a range - example \"2826-2829\"")
                    .frame(width: 200)
                    .fixedSize()
            }
            .padding(15)
            if error {
                Text(errorString)
            }
            if thinking {
                ProgressView()
                    .progressViewStyle(.linear)
                    .padding(.horizontal, 15)
            }
            TextField("", text: $input)
                .padding(15)
                .onSubmit {
                    error = false
                    thinking = true
                    if input.contains("-") {
                        let range = input.components(separatedBy: "-")
                        if let first = Int(range[0]), let last = Int(range[1]) {
                            DispatchQueue.global().async {
                                let list = Array(stride(from: first, through: last, by: 1))
                                let list2 = {
                                    var list3: [String] = []
                                    for item in list {
                                        list3.append(String(item))
                                    }
                                    return list3
                                }()
                                let vehicles = PaceAPI().getVehiclesForIDs(vehicleIDs: list2)
                                DispatchQueue.main.sync {
                                    if vehicles.count == 0 {
                                        thinking = false
                                        error = true
                                        errorString = "No vehicle IDs within the provided range registered on the tracker"
                                    } else {
                                        (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusMutex.lock()
                                        if let screenSize = NSScreen.main?.frame.size {
                                            let window = NSWindow(contentRect: NSMakeRect(0, 0, screenSize.width * 0.5, screenSize.height * 0.5), styleMask: [.titled, .closable], backing: .buffered, defer: false)
                                            let index = (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusWindows.count
                                            (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusWindows.append(window)
                                            let view = FindMyBusPaceMapView(vehicles: vehicles, vehicleIds: [input])
                                            
                                            (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusWindows[index].title = "Carmine - Find My Bus Pace"
                                            (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusWindows[index].contentView = view
                                            
                                            (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusWindows[index].center()
                                            (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusWindows[index].setIsVisible(true)
                                            (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusWindows[index].orderFrontRegardless()
                                            (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusWindows[index].makeKey()
                                            NSApp.activate(ignoringOtherApps: true)
                                            self.thinking = false
                                        }
                                        (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusMutex.unlock()
                                    }
                                }
                            }
                        } else {
                            thinking = false
                            error = true
                            errorString = "Improperly formatted range"
                        }
                    } else {
                        DispatchQueue.global().async {
                            let vehicle = PaceAPI().getVehiclesForIDs(vehicleIDs: [input])
                            DispatchQueue.main.sync {
                                if vehicle.count == 0 {
                                    thinking = false
                                    error = true
                                    errorString = "Vehicle is not registered on the tracker"
                                } else {
                                    (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusMutex.lock()
                                    if let screenSize = NSScreen.main?.frame.size {
                                        let window = NSWindow(contentRect: NSMakeRect(0, 0, screenSize.width * 0.5, screenSize.height * 0.5), styleMask: [.titled, .closable], backing: .buffered, defer: false)
                                        let index = (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusWindows.count
                                        (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusWindows.append(window)
                                        let view = FindMyBusPaceMapView(vehicles: vehicle, vehicleIds: [input])
                                        
                                        (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusWindows[index].title = "Carmine - Find My Bus Pace"
                                        (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusWindows[index].contentView = view
                                        
                                        (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusWindows[index].center()
                                        (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusWindows[index].setIsVisible(true)
                                        (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusWindows[index].orderFrontRegardless()
                                        (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusWindows[index].makeKey()
                                        NSApp.activate(ignoringOtherApps: true)
                                        self.thinking = false
                                    }
                                    (NSApplication.shared as! CarmineApp).strongDelegate.findMyBusMutex.unlock()
                                }
                            }
                        }
                    }
                }
        }
    }
}

enum FindMyBusShownView {
    case rootSelector
    case cta
    case pace
}
