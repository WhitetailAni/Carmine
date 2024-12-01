//
//  AppDelegate.swift
//  Carmine
//
//  Created by WhitetailAni on 7/23/24.
//

import Cocoa
import AppKit
import Foundation
import CoreLocation
import MapKit
import SwiftUI
import PaceTracker

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var menu: NSMenu!
    var ctaMenu: NSMenu!
    var paceMenu: NSMenu!
    var autoRefresh: AutomaticRefresh!
    
    var mapWindows: [NSWindow] = []
    var mapMutex = NSLock()
    
    var aboutWindows: [NSWindow] = []
    var aboutWindowDelegate: AboutWindowDelegate!
    var aboutMutex = NSLock()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem.button {
            let image = NSImage(size: NSSize(width: 22, height: 22), flipped: false) { (rect) -> Bool in
                NSImage(named: "ctaBus")!.tint(color: .white).draw(in: rect)
                return true
            }
            
            image.isTemplate = true
            button.image = image
            button.imagePosition = .imageLeft
        }
        
        menu = NSMenu()
        ctaMenu = NSMenu()
        paceMenu = NSMenu()
        refreshInfo()
        
        let ctaTitleString = prependImageToString(imageName: "cta", title: "CTA")
        let paceTitleString = prependImageToString(imageName: "pace", title: "Pace")
        
        let ctaItem = CMMenuItem(title: "", action: #selector(openLink(_:)))
        ctaItem.attributedTitle = ctaTitleString
        ctaItem.linkToOpen = URL(string: "https://ctabustracker.com/home")
        ctaItem.submenu = ctaMenu
        
        let paceItem = CMMenuItem(title: "", action: #selector(openLink(_:)))
        paceItem.attributedTitle = paceTitleString
        paceItem.linkToOpen = URL(string: "https://tmweb.pacebus.com/TMWebWatch/")
        paceItem.submenu = paceMenu
        
        menu.addItem(ctaItem)
        menu.addItem(paceItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let aboutItem = NSMenuItem(title: "About", action: #selector(openAboutWindow), keyEquivalent: "a")
        aboutItem.keyEquivalentModifierMask = [.command]
        menu.addItem(aboutItem)
        
        let refreshItem = NSMenuItem(title: "Refresh", action: #selector(refreshInfo), keyEquivalent: "r")
        refreshItem.keyEquivalentModifierMask = [.command]
        menu.addItem(refreshItem)
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.keyEquivalentModifierMask = [.command]
        menu.addItem(quitItem)
        
        /*autoRefresh = AutomaticRefresh(interval: Bundle.main.infoDictionary?["CMRefreshInterval"] as? Double ?? 720.0) {
            //self.refreshInfo()
        }
        autoRefresh.start()*/
        
        
        //PaceAPI().getPolyLineForRouteID(routeID: "293")
        //print(routes)
        
        print(PaceAPI().getRoutes())
        
        /*print(PaceAPI().getRouteDirections(routeID: 293))
        
        let stops = PaceAPI().getStopsForRouteAndDirectionID(routeID: 293, directionID: 2)
        let stpps = PaceAPI().getStopsForRouteAndDirectionID(routeID: 293, directionID: 3)
        let starts = PaceAPI().getStopsAndLocationsForRouteID(routeID: 293)
        
        print("stop")
        print(stops)
        
        print("stpp")
        print(stpps)
        print(" ")
        print("start")
        print(starts)*/
        
        //PaceTracker().getRouteDirections(routeID: "27")
        //print(PaceAPI().getRouteDirections(routeID: 293))
        /*PaceAPI().getRouteDirections(routeID: "111")
         PaceAPI().getVehicleLocationsForRouteID(routeID: "27")
         PaceAPI().getVehicleLocationsForRouteID(routeID: "293")
         PaceAPI().getVehicleLocationsForRouteID(routeID: "111")*/
        
        statusItem.menu = menu
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return false
    }
    
    func prependImageToString(imageName: String, title: String) -> NSMutableAttributedString {
        let height = NSFont.menuFont(ofSize: 0).boundingRectForFont.height - 5
        let baseImage = NSImage(named: imageName)!
        
        let aspectRatio = baseImage.size.width / baseImage.size.height
        let newSize = NSSize(width: height * aspectRatio, height: height)
            
        let image = NSImage(size: newSize)
        image.lockFocus()
        baseImage.draw(in: NSRect(origin: .zero, size: newSize))
        image.unlockFocus()
        
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image
        
        let resultingString = NSAttributedString(attachment: imageAttachment)
        
        let attributedTitle = NSMutableAttributedString(string: "")
        attributedTitle.append(resultingString)
        attributedTitle.append(NSAttributedString(string: " "))
        attributedTitle.append(NSAttributedString(string: title))
        
        return attributedTitle
    }
    
    @MainActor @objc func refreshInfo() {
        //refreshCTAInfo()
        refreshPaceInfo()
    }
    
    @MainActor @objc func refreshPaceInfo() {
        paceMenu.removeAllItems()
        for route in /*PaceAPI().getRoutes()*/ PTRoute.testValues() {
            let outOfService = PaceAPI.hasServiceEnded(route: route)
            
            if !((Bundle.main.infoDictionary?["CMHideOutOfServiceRoutes"] as? Bool ?? false) && outOfService) {
                let item = CMMenuItem(title: route.fullName, action: #selector(openLink(_:)))
                item.linkToOpen = route.link()
                
                let subMenu = NSMenu()
                
                let vehicleMenuItem = CMMenuItem(title: "Vehicles", action: #selector(openLink(_:)))
                vehicleMenuItem.linkToOpen = URL(string: "https://tmweb.pacebus.com/TMWebWatch/MultiRoute")
                subMenu.addItem(vehicleMenuItem)
                
                let instance = PaceAPI()
                let vehicleSubMenu = NSMenu()
                vehicleSubMenu.addItem(NSMenuItem.progressWheel())
                
                DispatchQueue.global().async {
                    if !outOfService {
                        let vehicles = instance.getVehicleLocationsForRouteID(routeID: route.id)
                        
                        DispatchQueue.main.sync {
                            vehicleSubMenu.removeItem(at: 0)
                            
                            if vehicles.count > 0 {
                                for vehicle in vehicles {
                                    let direction = PTDirection.PTVehicleDirection(degrees: vehicle.heading).description
                                    
                                    let superSubMenu = NSMenu()
                                    let vehicleItem = PTMenuItem(title: "\(vehicle.vehicleNumber) heading \(direction)", action: #selector(self.openPaceMapWindow(_:)))
                                    vehicleItem.vehicleNumber = vehicle.vehicleNumber
                                    vehicleItem.coordinate = vehicle.location
                                    vehicleItem.busRoute = route
                                    vehicleItem.linkToOpen = route.link()
                                    
                                    vehicleSubMenu.addItem(vehicleItem)
                                    
                                    if vehicle.isAccessible {
                                        let isAccessibleItem = NSMenuItem(title: "Accessible bus", action: #selector(self.nop))
                                        superSubMenu.addItem(isAccessibleItem)
                                        
                                        let hasLiftItem = NSMenuItem(title: "Has wheelchair lift", action: #selector(self.nop))
                                        superSubMenu.addItem(hasLiftItem)
                                    } else {
                                        let inAccessibleItem = CMMenuItem(title: "Inaccessible bus", action: #selector(self.openLink))
                                        inAccessibleItem.linkToOpen = URL(string: "https://www.pacebus.com/ada")!
                                        superSubMenu.addItem(inAccessibleItem)
                                    }
                                    
                                    if vehicle.hasWiFi {
                                        let hasWifiItem = NSMenuItem(title: "Has WiFi", action: #selector(self.nop))
                                        superSubMenu.addItem(hasWifiItem)
                                    }
                                    
                                    if vehicle.hasBikeRack {
                                        let hasBikeRackItem = NSMenuItem(title: "Has a bike rack", action: #selector(self.nop))
                                        superSubMenu.addItem(hasBikeRackItem)
                                    }
                                    
                                    vehicleItem.submenu = superSubMenu
                                }
                            } else {
                                vehicleSubMenu.addItem(NSMenuItem(title: "No active buses", action: nil))
                            }
                            
                            vehicleMenuItem.submenu = vehicleSubMenu
                        }
                    } else {
                        subMenu.removeItem(at: 0)
                        subMenu.addItem(NSMenuItem(title: "Route not in service", action: nil))
                    }
                }
                
                let stopMenuItem = CMMenuItem(title: "Stops", action: #selector(openLink(_:)))
                stopMenuItem.linkToOpen = URL(string: "https://tmweb.pacebus.com/TMWebWatch/LiveArrivalTimes")!
                subMenu.addItem(stopMenuItem)
                
                let jnstance = PaceAPI()
                
                let stopSubMenu = NSMenu()
                stopSubMenu.addItem(NSMenuItem.progressWheel())
                
                DispatchQueue.global().async {
                    if !outOfService {
                        let directions = jnstance.getRouteDirections(routeID: route.id)
                        
                        DispatchQueue.main.sync {
                            stopSubMenu.removeItem(at: 0)
                            
                            for direction in directions {
                                let directionItem = NSMenuItem(title: direction.name, action: #selector(self.nop))
                                stopSubMenu.addItem(directionItem)
                                
                                let powerPose = PaceAPI()
                                let stopListSubMenu = NSMenu()
                                stopListSubMenu.addItem(NSMenuItem.progressWheel())
                                
                                DispatchQueue.global().async {
                                    let stops = powerPose.getStopsForRouteAndDirectionID(routeID: route.id, directionID: direction.id)
                                    
                                    DispatchQueue.main.sync {
                                        stopListSubMenu.removeItem(at: 0)
                                        for stop in stops {
                                            let stopMenuItem = PTMenuItem(title: "\(stop.name)", action: #selector(self.openPaceMapWindow(_:)))
                                            stopMenuItem.coordinate = stop.location
                                            stopListSubMenu.addItem(stopMenuItem)
                                        }
                                    }
                                }
                                
                                directionItem.submenu = stopListSubMenu
                                
                                //print(direction)
                            }
                            
                            /*if stops.count > 0 {
                                for stop in stops {
                                    //print(stop)
                                    /*let direction = PTVehicle.PTVehicleDirection(degrees: vehicle.heading).description
                                    
                                    let superSubMenu = NSMenu()
                                    let vehicleItem = PTMenuItem(title: "\(vehicle.vehicleNumber) heading \(direction)", action: #selector(self.openPaceMapWindow(_:)))
                                    vehicleItem.vehicleNumber = vehicle.vehicleNumber
                                    vehicleItem.vehicleCoordinate = vehicle.location
                                    vehicleItem.busRoute = route
                                    vehicleItem.linkToOpen = route.link()
                                    print(vehicle)
                                    
                                    vehicleSubMenu.addItem(vehicleItem)
                                    
                                    if vehicle.isAccessible {
                                        let isAccessibleItem = NSMenuItem(title: "Accessible bus", action: #selector(self.nop))
                                        superSubMenu.addItem(isAccessibleItem)
                                        
                                        let hasLiftItem = NSMenuItem(title: "Has wheelchair lift", action: #selector(self.nop))
                                        superSubMenu.addItem(hasLiftItem)
                                    } else {
                                        let inAccessibleItem = CMMenuItem(title: "Inaccessible bus", action: #selector(self.openLink))
                                        inAccessibleItem.linkToOpen = URL(string: "https://www.pacebus.com/ada")!
                                        superSubMenu.addItem(inAccessibleItem)
                                    }
                                    
                                    if vehicle.hasWiFi {
                                        let hasWifiItem = NSMenuItem(title: "Has WiFi", action: #selector(self.nop))
                                        superSubMenu.addItem(hasWifiItem)
                                    }
                                    
                                    if vehicle.hasBikeRack {
                                        let hasBikeRackItem = NSMenuItem(title: "Has a bike rack", action: #selector(self.nop))
                                        superSubMenu.addItem(hasBikeRackItem)
                                    }
                                    
                                    vehicleItem.submenu = superSubMenu*/
                                }
                            } else {
                                stopSubMenu.addItem(NSMenuItem(title: "No stops found", action: nil))
                            }*/
                            
                            stopMenuItem.submenu = stopSubMenu
                        }
                    } else {
                        subMenu.removeItem(at: 0)
                        subMenu.addItem(NSMenuItem(title: "Route not in service", action: nil))
                    }
                }
                
                item.submenu = subMenu
                
                paceMenu.addItem(item)
            }
        }
    }
    
    @MainActor @objc func refreshCTAInfo() {
        ctaMenu.removeAllItems()
        for route in CMRoute.allCases {
            let outOfService = ChicagoTransitInterface.hasServiceEnded(route: route)
            
            if !((Bundle.main.infoDictionary?["CMHideOutOfServiceRoutes"] as? Bool ?? false) && outOfService) {
                var title = ""
                if ChicagoTransitInterface.isNightServiceActive(route: route) {
                    title = "N" + route.textualRepresentation(addRouteNumber: true) + " Night"
                } else {
                    title = route.textualRepresentation(addRouteNumber: true)
                }
                let item = CMMenuItem(title: title, action: #selector(openLink(_:)))
                item.linkToOpen = route.link()
                
                let subMenu = NSMenu()
                subMenu.addItem(NSMenuItem.progressWheel())
                
                let instance = ChicagoTransitInterface()
                DispatchQueue.global().async {
                    if !outOfService {
                        let info = instance.getVehiclesForRoute(route: route)
                        let vehicles = InterfaceResultProcessing.cleanUpVehicleInfo(info: info)
                        
                        DispatchQueue.main.sync {
                            subMenu.removeItem(at: 0)
                            
                            if vehicles.count == 0 {
                                subMenu.addItem(NSMenuItem(title: "No active buses", action: nil))
                            } else {
                                let timeLastUpdated = CMTime.apiTimeToReadabletime(string: vehicles[0]["time"] ?? "")
                                subMenu.addItem(NSMenuItem(title: "Last updated at \(timeLastUpdated)", action: nil))
                                subMenu.addItem(NSMenuItem.separator())
                                
                                for vehicle in vehicles {
                                    var subItem: CMMenuItem!
                                    if let latitudeString = vehicle["latitude"], let longitudeString = vehicle["longitude"], let latitude = Double(latitudeString), let longitude = Double(longitudeString), (latitude != -3 && longitude != -2) {
                                        subItem = CMMenuItem(title: "\(vehicle["vehicleId"] ?? "Unknown Vehicle Number") to \(vehicle["destination"] ?? "Unknown Destination")", action: #selector(self.openCTAMapWindow(_:)))
                                        subItem.vehicleCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                        
                                        subItem.busRoute = route
                                        subItem.vehicleNumber = vehicle["vehicleId"] ?? "Unknown Vehicle Number"
                                        subItem.timeLastUpdated = timeLastUpdated
                                    } else {
                                        subItem = CMMenuItem(title: "\(vehicle["vehicleId"] ?? "Unknown Vehicle Number") to \(vehicle["destination"] ?? "Unknown Destination")", action: #selector(self.nop))
                                    }
                                    subItem.action = #selector(self.openCTAMapWindow(_:))
                                    
                                    let subSubMenu = NSMenu()
                                    subSubMenu.addItem(NSMenuItem.progressWheel())
                                    subItem.submenu = subSubMenu
                                    subMenu.addItem(subItem)
                                    
                                    DispatchQueue.global().async {
                                        let niceStats = InterfaceResultProcessing.cleanUpPredictionInfo(info: instance.getPredictionsForVehicle(route: route, vehicleId: vehicle["vehicleId"] ?? "0000"))
                                        
                                        DispatchQueue.main.sync {
                                            subSubMenu.removeItem(at: 0)
                                            
                                            if niceStats.count > 0 {
                                                
                                                let subSubItem = CMMenuItem(title: "\(route.textualRepresentation(addRouteNumber: false)) bus \(vehicle["vehicleId"] ?? "0000"), \((niceStats[0]["routeDirection"] ?? "Unknown Direction").lowercased()) to \(vehicle["destination"] ?? "Unknown Destination")", action: #selector(self.openCTAMapWindow(_:)))
                                                
                                                subSubItem.busRoute = route
                                                subSubItem.vehicleNumber = vehicle["vehicleId"]
                                                subSubItem.timeLastUpdated = timeLastUpdated
                                                
                                                subSubMenu.addItem(subSubItem)
                                                subSubMenu.addItem(NSMenuItem.separator())
                                                
                                                for stop in niceStats {
                                                    if let direction = niceStats[0]["routeDirection"], let vehicleId = vehicle["vehicleId"], let stopName = stop["stopName"], let stopId = stop["stopId"], let latitudeString = vehicle["latitude"], let longitudeString = vehicle["longitude"], let latitude = Double(latitudeString), let longitude = Double(longitudeString), (latitude != -3 && longitude != -2) {
                                                        let subSubItem = CMMenuItem(title: "\(stopName) at \(CMTime.apiTimeToReadabletime(string: stop["exactTime"] ?? "dont know man"))", action: #selector(self.openCTAMapWindow(_:)))
                                                        
                                                        subSubItem.vehicleDirection = direction
                                                        subSubItem.vehicleCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                                        
                                                        subSubItem.busRoute = route
                                                        subSubItem.vehicleNumber = vehicleId
                                                        subSubItem.timeLastUpdated = timeLastUpdated
                                                        subSubItem.vehicleDesiredStopID = stopId
                                                        subSubItem.vehicleDesiredStop = stopName
                                                        
                                                        subSubMenu.addItem(subSubItem)
                                                        
                                                        let subSubSubMenu = NSMenu()
                                                        
                                                        
                                                        let delayItem = NSMenuItem(title: "Delayed: \(stop["isDelayed"] ?? "No")", action: #selector(self.nop))
                                                        
                                                        if stop["isDeparture"] == "D" {
                                                            let departureItem = NSMenuItem(title: "Bus departs from this stop", action: #selector(self.nop))
                                                            subSubSubMenu.addItem(departureItem)
                                                            subSubSubMenu.addItem(NSMenuItem.separator())
                                                        }
                                                        
                                                        subSubSubMenu.addItem(delayItem)
                                                        
                                                        subSubItem.submenu = subSubSubMenu
                                                    } else {
                                                        let subSubItem = CMMenuItem(title: "\(stop["stopName"] ?? "Unknown Stop") at \(CMTime.apiTimeToReadabletime(string: stop["exactTime"] ?? "26:48"))", action: #selector(self.nop))
                                                        subSubMenu.addItem(subSubItem)
                                                    }
                                                }
                                            } else {
                                                let errorItem = NSMenuItem(title: "No predictions available", action: nil)
                                                subSubMenu.addItem(errorItem)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        subMenu.removeItem(at: 0)
                        subMenu.addItem(NSMenuItem(title: "Route not in service", action: nil))
                    }
                }
                
                item.submenu = subMenu
                ctaMenu.addItem(item)
            }
        }
    }
    
    @objc func openCTAMapWindow(_ sender: CMMenuItem) {
        mapMutex.lock()
        if let screenSize = NSScreen.main?.frame.size {
            let window = NSWindow(contentRect: NSMakeRect(0, 0, screenSize.width * 0.5, screenSize.height * 0.5), styleMask: [.titled, .closable], backing: .buffered, defer: false)
            let index = mapWindows.count
            mapWindows.append(window)
            
            let busMark = CMPlacemark(coordinate: sender.vehicleCoordinate ?? CLLocationCoordinate2D(latitude: 41.88372, longitude: 87.63238))
            
            if let route = sender.busRoute, let vehicleId = sender.vehicleNumber, let timeLastUpdated = sender.timeLastUpdated {
                let stopName = sender.vehicleDesiredStop ?? "Rochester"
                busMark.route = route
                busMark.vehicleNumber = vehicleId
                busMark.stopName = stopName
                busMark.stopId = sender.vehicleDesiredStopID
                
                let instance = ChicagoTransitInterface()
                if let id = sender.vehicleDesiredStopID, let direction = sender.vehicleDirection {
                    busMark.direction = direction
                    mapWindows[index].title = "Carmine - \(sender.busRoute?.textualRepresentation(addRouteNumber: true) ?? "Unknown Route") bus \(sender.vehicleNumber ?? "0000") to \(sender.vehicleDesiredStop ?? "Unknown")"
                    
                    DispatchQueue.global().async {
                        let returnedData = instance.getStopCoordinatesForID(route: route, direction: direction, id: id)
                        
                        let stopMark = CMPlacemark(coordinate: InterfaceResultProcessing.getLocationFromStopInfo(info: returnedData, stopId: id))
                        stopMark.stopName = sender.vehicleDesiredStop
                        stopMark.route = route
                        
                        DispatchQueue.main.sync {
                            self.mapWindows[index].contentView = CMMapView(bus: busMark, stop: stopMark, timeLastUpdated: timeLastUpdated)
                            self.mapWindows[index].center()
                            self.mapWindows[index].setIsVisible(true)
                            self.mapWindows[index].orderFrontRegardless()
                            self.mapWindows[index].makeKey()
                            NSApp.activate(ignoringOtherApps: true)
                        }
                    }
                } else {
                    mapWindows[index].title = "Carmine - \(sender.busRoute?.textualRepresentation(addRouteNumber: true) ?? "Unknown Route") bus \(sender.vehicleNumber ?? "0000")"
                    mapWindows[index].contentView = CMMapView(bus: busMark, timeLastUpdated: timeLastUpdated)
                    mapWindows[index].center()
                    mapWindows[index].setIsVisible(true)
                    mapWindows[index].orderFrontRegardless()
                    mapWindows[index].makeKey()
                    NSApp.activate(ignoringOtherApps: true)
                }
            }
        }
        mapMutex.unlock()
    }
    
    @objc func openPaceMapWindow(_ sender: PTMenuItem) {
        
    }
    
    @objc func openAboutWindow() {
        aboutMutex.lock()
        if let screenSize = NSScreen.main?.frame.size {
            let defaultRect = NSMakeRect(0, 0, screenSize.width * 0.27, screenSize.height * 0.27)
            aboutWindows.append(NSWindow(contentRect: defaultRect, styleMask: [.titled, .closable], backing: .buffered, defer: false))
            let index = aboutWindows.count - 1
            
            aboutWindows[index].contentView = NSHostingView(rootView: AboutView())
            aboutWindows[index].title = "Carmine \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "772")) - About"
            aboutWindows[index].center()
            aboutWindows[index].setIsVisible(true)
            aboutWindows[index].orderFrontRegardless()
            aboutWindows[index].makeKey()
            NSApp.activate(ignoringOtherApps: true)
            
            aboutWindowDelegate = AboutWindowDelegate(window: aboutWindows[index])
            aboutWindows[index].delegate = aboutWindowDelegate
        }
        aboutMutex.unlock()
    }
    
    @objc func openLink(_ sender: CMMenuItem) {
        if let link = sender.linkToOpen {
            NSWorkspace.shared.open(link)
        }
    }
    
    @objc func nop() { }
    
    @objc func quit() {
        NSApp.terminate(nil)
    }
}
