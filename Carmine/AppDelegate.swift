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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var menu: NSMenu!
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
        refreshInfo()
        
        autoRefresh = AutomaticRefresh(interval: Bundle.main.infoDictionary?["CMRefreshInterval"] as? Double ?? 720.0) {
            self.refreshInfo()
        }
        autoRefresh.start()
        
        statusItem.menu = menu
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        for window in mapWindows {
            window.close()
        }
        for aboutWindow in aboutWindows {
            aboutWindow.close()
        }
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return false
    }
    
    
    
    @MainActor @objc func refreshInfo() {
        menu.removeAllItems()
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
                                        subItem = CMMenuItem(title: "\(vehicle["vehicleId"] ?? "Unknown Vehicle Number") to \(vehicle["destination"] ?? "Unknown Destination")", action: #selector(self.openWindow(_:)))
                                        subItem.vehicleCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                        
                                        subItem.busRoute = route
                                        subItem.vehicleNumber = vehicle["vehicleId"] ?? "Unknown Vehicle Number"
                                        subItem.timeLastUpdated = timeLastUpdated
                                    } else {
                                        subItem = CMMenuItem(title: "\(vehicle["vehicleId"] ?? "Unknown Vehicle Number") to \(vehicle["destination"] ?? "Unknown Destination")", action: #selector(self.nop))
                                    }
                                    subItem.action = #selector(self.openWindow(_:))
                                    
                                    let subSubMenu = NSMenu()
                                    subSubMenu.addItem(NSMenuItem.progressWheel())
                                    subItem.submenu = subSubMenu
                                    subMenu.addItem(subItem)
                                    
                                    DispatchQueue.global().async {
                                        let niceStats = InterfaceResultProcessing.cleanUpPredictionInfo(info: instance.getPredictionsForVehicle(route: route, vehicleId: vehicle["vehicleId"] ?? "0000"))
                                        
                                        DispatchQueue.main.sync {
                                            subSubMenu.removeItem(at: 0)
                                            
                                            if niceStats.count > 0 {
                                                
                                                let subSubItem = CMMenuItem(title: "\(route.textualRepresentation(addRouteNumber: false)) bus \(vehicle["vehicleId"] ?? "0000"), \((niceStats[0]["routeDirection"] ?? "Unknown Direction").lowercased()) to \(vehicle["destination"] ?? "Unknown Destination")", action: #selector(self.openWindow(_:)))
                                                
                                                subSubItem.busRoute = route
                                                subSubItem.vehicleNumber = vehicle["vehicleId"]
                                                subSubItem.timeLastUpdated = timeLastUpdated
                                                
                                                subSubMenu.addItem(subSubItem)
                                                subSubMenu.addItem(NSMenuItem.separator())
                                                
                                                for stop in niceStats {
                                                    if let direction = niceStats[0]["routeDirection"], let vehicleId = vehicle["vehicleId"], let stopName = stop["stopName"], let stopId = stop["stopId"], let latitudeString = vehicle["latitude"], let longitudeString = vehicle["longitude"], let latitude = Double(latitudeString), let longitude = Double(longitudeString), (latitude != -3 && longitude != -2) {
                                                        let subSubItem = CMMenuItem(title: "\(stopName) at \(CMTime.apiTimeToReadabletime(string: stop["exactTime"] ?? "dont know man"))", action: #selector(self.openWindow(_:)))
                                                        
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
                menu.addItem(item)
            }
        }
        
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
    }
    
    @objc func openWindow(_ sender: CMMenuItem) {
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
