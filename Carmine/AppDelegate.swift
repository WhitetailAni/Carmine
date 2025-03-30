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
@preconcurrency import PaceTracker

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
        
        _ = ChicagoTransitInterface.polylines //this makes sure the polyline table is loaded at startup
        
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
        
        autoRefresh = AutomaticRefresh(interval: Bundle.main.infoDictionary?["CMRefreshInterval"] as? Double ?? 720.0) {
            self.refreshInfo()
        }
        autoRefresh.start()
        
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
        refreshCTAInfo()
        refreshPaceInfo()
    }
    
    @MainActor @objc func refreshCTAInfo() {
        ctaMenu.removeAllItems()
        DispatchQueue.global().async {
            for route in CMRoute.allCases {
                var item: CMMenuItem!
                if let glyphs = route.glyphs() {
                    let title = NSMutableAttributedString(string: route.textualRepresentation(addRouteNumber: true))
                    item = CMMenuItem(title: "", action: #selector(self.openLink(_:)))
                    
                    for glyph in glyphs {
                        let height = NSFont.menuFont(ofSize: 0).boundingRectForFont.height - 5
                        let aspectRatio = glyph.size.width / glyph.size.height
                        let newSize = NSSize(width: height * aspectRatio, height: height)
                            
                        let image = NSImage(size: newSize)
                        image.lockFocus()
                        glyph.draw(in: NSRect(origin: .zero, size: newSize))
                        image.unlockFocus()
                        
                        let attachment = NSTextAttachment()
                        attachment.image = image
                        
                        title.append(NSAttributedString(string: " "))
                        title.append(NSAttributedString(attachment: attachment))
                    }
                    item.attributedTitle = title
                } else {
                    let title = route.textualRepresentation(addRouteNumber: true)
                    item = CMMenuItem(title: title, action: #selector(self.openLink(_:)))
                }
                
                item.linkToOpen = route.link()
                    
                let subMenu = NSMenu()
                DispatchQueue.main.sync {
                    subMenu.addItem(NSMenuItem.progressWheel())
                }
                    
                let instance = ChicagoTransitInterface()

                let info = instance.getVehiclesForRoute(route: route)
                let errorString = InterfaceResultProcessing.returnErrorString(info: info)
                if errorString != "i love kissing girls" {
                    DispatchQueue.main.sync {
                        self.ctaMenu.addItem(CMMenuItem(title: errorString, action: nil))
                    }
                    break
                }
                let vehicles = InterfaceResultProcessing.cleanUpVehicleInfo(info: info)
                
                if vehicles.count == 0 {
                    continue
                } else {
                    DispatchQueue.main.sync {
                        subMenu.removeItem(at: 0)
                        
                        let timeLastUpdated = CMTime.apiTimeToReadabletime(string: vehicles[0]["time"] ?? "")
                        subMenu.addItem(NSMenuItem(title: "Last updated at \(timeLastUpdated)", action: nil))
                        subMenu.addItem(NSMenuItem.separator())
                        
                        for vehicle in vehicles {
                            var subItem: CMMenuItem!
                            
                            let destination = vehicle["destination"] ?? "Unknown Destination"
                            if let latitudeString = vehicle["latitude"], let longitudeString = vehicle["longitude"], let latitude = Double(latitudeString), let longitude = Double(longitudeString), (latitude != -3 && longitude != -2) {
                                subItem = CMMenuItem(title: "\(vehicle["vehicleId"] ?? "Unknown Vehicle Number") to \(destination)", action: #selector(self.openCTAMapWindow(_:)))
                                subItem.vehicleCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                
                                subItem.vehicleTerminus = destination
                                
                                subItem.busRoute = route
                                subItem.vehicleNumber = vehicle["vehicleId"] ?? "Unknown Vehicle Number"
                                subItem.timeLastUpdated = timeLastUpdated
                            } else {
                                subItem = CMMenuItem(title: "\(vehicle["vehicleId"] ?? "Unknown Vehicle Number") to \(destination)", action: #selector(self.nop))
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
                                                
                                                if stop["isDelayed"] ?? "No" == "Yes" {
                                                    let delayItem = NSMenuItem(title: "Delayed", action: #selector(self.nop))
                                                    subSubSubMenu.addItem(delayItem)
                                                }
                                                
                                                let stopType = stop["isDeparture"] ?? "A"
                                                if stopType == "D" {
                                                    let departureItem = NSMenuItem(title: "Terminal stop", action: #selector(self.nop))
                                                    subSubSubMenu.addItem(departureItem)
                                                    subSubSubMenu.addItem(NSMenuItem.separator())
                                                }
                                                
                                                if subSubSubMenu.items.count > 0 {
                                                    subSubItem.submenu = subSubSubMenu
                                                }
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
                
                DispatchQueue.main.sync {
                    item.submenu = subMenu
                    self.ctaMenu.addItem(item)
                }
            }
            
            DispatchQueue.main.sync {
                if self.ctaMenu.items.count == 0 {
                    self.ctaMenu.addItem(NSMenuItem(title: "No tracking buses", action: nil))
                }
            }
            
            DispatchQueue.main.sync {
                self.ctaMenu.addItem(NSMenuItem.separator())
                self.ctaMenu.addItem(NSMenuItem(title: "Refresh", action: #selector(self.refreshCTAInfo), keyEquivalent: "r"))
            }
        }
    }
    
    @MainActor @objc func refreshPaceInfo() {
        self.paceMenu.removeAllItems()
        
        do {
            let routes = try PaceAPI().getRoutes(dropPulseNumbers: true)
            
            DispatchQueue.global().async {
                for i in 0..<routes.count {
                    let route = routes[i]
                    let item = CMMenuItem(title: route.fullName, action: #selector(self.openLink(_:)))
                    item.linkToOpen = route.link()
                    
                    if route.number == 352 {
                        let title = NSMutableAttributedString(string: route.fullName)
                        
                        let height = NSFont.menuFont(ofSize: 0).boundingRectForFont.height - 5
                        let freqBaseImage = NSImage(named: "nightOwl")!
                        let aspectRatio = freqBaseImage.size.width / freqBaseImage.size.height
                        let newSize = NSSize(width: height * aspectRatio, height: height)
                        
                        let freqImage = NSImage(size: newSize)
                        freqImage.lockFocus()
                        freqBaseImage.draw(in: NSRect(origin: .zero, size: newSize))
                        freqImage.unlockFocus()
                        
                        let frequentNetwork = NSTextAttachment()
                        frequentNetwork.image = freqImage
                        
                        let freqNetworkString = NSAttributedString(attachment: frequentNetwork)
                        title.append(NSAttributedString(string: " "))
                        title.append(freqNetworkString)
                        item.attributedTitle = title
                    }
                    
                    let subMenu = NSMenu()
                    
                    let vehicleMenuItem = CMMenuItem(title: "Vehicles", action: #selector(self.openLink(_:)))
                    vehicleMenuItem.linkToOpen = URL(string: "https://tmweb.pacebus.com/TMWebWatch/MultiRoute")
                    //subMenu.addItem(vehicleMenuItem)
                    
                    let instance = PaceAPI()
                    let vehicleSubMenu = NSMenu()
                    do {
                        let vehicles = try instance.getVehiclesForRoute(routeID: route.id)
                        
                        if vehicles.count == 0 {
                            continue
                        } else {
                            /*vehicleSubMenu*/subMenu.addItem(NSMenuItem(title: "Last updated at \(CMTime.currentReadableTime())", action: nil))
                            /*vehicleSubMenu*/subMenu.addItem(NSMenuItem.separator())
                            
                            for vehicle in vehicles {
                                let direction = PTDirection.PTVehicleDirection(degrees: vehicle.heading).description
                                
                                //let superSubMenu = NSMenu()
                                let vehicleItem = PTMenuItem(title: "\(vehicle.vehicleNumber) heading \(direction)", action: #selector(self.openPaceMapWindow(_:)))
                                vehicleItem.vehicleNumber = vehicle.vehicleNumber
                                vehicleItem.coordinate = vehicle.location
                                vehicleItem.route = route
                                vehicleItem.linkToOpen = route.link()
                                vehicleItem.vehicleHeading = vehicle.heading
                                
                                //vehicleSubMenu.addItem(vehicleItem) //flip if enabling stops ever
                                subMenu.addItem(vehicleItem)
                                
                                /*DispatchQueue.main.sync {
                                 vehicleSubMenu.addItem(vehicleItem)
                                 
                                 if vehicle.isAccessible {
                                 let isAccessibleItem = NSMenuItem(title: "Accessible bus", action: #selector(self.nop))
                                 superSubMenu.addItem(isAccessibleItem)
                                 
                                 let hasLiftItem = NSMenuItem(title: "Equipped with wheelchair lift", action: #selector(self.nop))
                                 superSubMenu.addItem(hasLiftItem)
                                 } else {
                                 let inAccessibleItem = CMMenuItem(title: "Inaccessible bus", action: #selector(self.openLink))
                                 inAccessibleItem.linkToOpen = URL(string: "https://www.pacebus.com/ada")!
                                 superSubMenu.addItem(inAccessibleItem)
                                 }
                                 
                                 if vehicle.hasWiFi {
                                 let hasWifiItem = NSMenuItem(title: "Equipped with WiFi", action: #selector(self.nop))
                                 superSubMenu.addItem(hasWifiItem)
                                 }
                                 
                                 if vehicle.hasBikeRack {
                                 let hasBikeRackItem = NSMenuItem(title: "Equipped with a bike rack", action: #selector(self.nop))
                                 superSubMenu.addItem(hasBikeRackItem)
                                 }
                                 
                                 vehicleItem.submenu = superSubMenu
                                 }*/
                            }
                            item.submenu = subMenu
                        }
                        vehicleMenuItem.submenu = vehicleSubMenu
                        
                        /*let stopMenuItem = CMMenuItem(title: "Stops", action: #selector(self.openLink(_:)))
                         stopMenuItem.linkToOpen = URL(string: "https://tmweb.pacebus.com/TMWebWatch/LiveArrivalTimes")!
                         subMenu.addItem(stopMenuItem)
                         
                         let jnstance = PaceAPI()
                         
                         let stopSubMenu = NSMenu()
                         
                         DispatchQueue.main.sync {
                         stopSubMenu.addItem(NSMenuItem.progressWheel())
                         }
                         
                         DispatchQueue.global().async {
                         let directions = jnstance.getDirectionsForRoute(routeID: route.id)
                         
                         DispatchQueue.main.sync {
                         stopSubMenu.removeItem(at: 0)
                         
                         for direction in directions {
                         let directionItem = NSMenuItem(title: direction.name, action: #selector(self.nop))
                         stopSubMenu.addItem(directionItem)
                         
                         let powerPose = PaceAPI()
                         let stopListSubMenu = NSMenu()
                         stopListSubMenu.addItem(NSMenuItem.progressWheel())
                         
                         DispatchQueue.global().async {
                         let stops = powerPose.getStopsForRouteAndDirection(routeID: route.id, directionID: direction.id)
                         
                         DispatchQueue.main.sync {
                         stopListSubMenu.removeItem(at: 0)
                         }
                         
                         for stop in stops {
                         let stopMenuItem = PTMenuItem(title: "\(stop.name)", action: #selector(self.openPaceMapWindow(_:)))
                         stopMenuItem.coordinate = stop.location
                         stopMenuItem.route = route
                         stopMenuItem.stop = stop
                         
                         let stopTypeMenu = NSMenu()
                         
                         let arrivalListItem = CMMenuItem(title: "Arrivals", action: #selector(self.openLink(_:)))
                         arrivalListItem.linkToOpen = URL(string: "https://tmweb.pacebus.com/TMWebWatch/LiveArrivalTimes")!
                         let arrivalMenu = NSMenu()
                         
                         let departureListItem = CMMenuItem(title: "Departures", action: #selector(self.openLink(_:)))
                         departureListItem.linkToOpen = URL(string: "https://tmweb.pacebus.com/TMWebWatch/LiveDepartureTimes")!
                         let departureMenu = NSMenu()
                         
                         DispatchQueue.main.sync {
                         arrivalMenu.addItem(NSMenuItem.progressWheel())
                         departureMenu.addItem(NSMenuItem.progressWheel())
                         
                         stopListSubMenu.addItem(stopMenuItem)
                         
                         stopTypeMenu.addItem(arrivalListItem)
                         stopTypeMenu.addItem(departureListItem)
                         
                         stopMenuItem.submenu = stopTypeMenu
                         }
                         
                         let arrivals = PaceAPI(stopPredictionType: .arrivals).getPredictionTimesForStop(routeID: route.id, directionID: direction.id, stopID: stop.id, timePointID: stop.timePointID)
                         let departures = PaceAPI(stopPredictionType: .departures).getPredictionTimesForStop(routeID: route.id, directionID: direction.id, stopID: stop.id, timePointID: stop.timePointID)
                         
                         arrivalMenu.removeItem(at: 0)
                         if !(arrivals.predictionSet[0].predictedTime.stringVersion() == "00:00") {
                         for arrival in arrivals.predictionSet {
                         var arrivalItem: NSMenuItem!
                         if arrival.scheduledTime.stringVersion() == "00:00" {
                         arrivalItem = NSMenuItem(title: "Arrives \(arrival.predictedTime.stringVersion())", action: #selector(self.nop))
                         } else {
                         arrivalItem = NSMenuItem(title: "Arrives \(arrival.predictedTime.stringVersion()), scheduled \(arrival.scheduledTime.stringVersion())", action: #selector(self.nop))
                         }
                         DispatchQueue.main.sync {
                         arrivalMenu.addItem(arrivalItem)
                         }
                         }
                         } else {
                         DispatchQueue.main.sync {
                         arrivalMenu.addItem(NSMenuItem(title: "No arrivals available", action: nil))
                         }
                         }
                         
                         departureMenu.removeItem(at: 0)
                         if !(departures.predictionSet[0].predictedTime.stringVersion() == "00:00") {
                         for departure in departures.predictionSet {
                         var departureItem: NSMenuItem!
                         if departure.scheduledTime.stringVersion() == "00:00" {
                         departureItem = NSMenuItem(title: "Departs \(departure.predictedTime.stringVersion())", action: #selector(self.nop))
                         } else {
                         departureItem = NSMenuItem(title: "Departs \(departure.predictedTime.stringVersion()), scheduled \(departure.scheduledTime.stringVersion())", action: #selector(self.nop))
                         }
                         DispatchQueue.main.sync {
                         departureMenu.addItem(departureItem)
                         }
                         }
                         } else {
                         DispatchQueue.main.sync {
                         departureMenu.addItem(NSMenuItem(title: "No departures available", action: nil))
                         }
                         }
                         
                         DispatchQueue.main.sync {
                         arrivalListItem.submenu = arrivalMenu
                         departureListItem.submenu = departureMenu
                         }
                         }
                         }
                         
                         directionItem.submenu = stopListSubMenu
                         }
                         
                         stopMenuItem.submenu = stopSubMenu
                         }
                         }*/
                        
                        DispatchQueue.main.sync {
                            item.submenu = subMenu
                            self.paceMenu.addItem(item)
                        }
                    } catch {
                        self.paceMenu.addItem(NSMenuItem(title: error.localizedDescription, action: nil))
                        self.paceMenu.addItem(NSMenuItem.separator())
                        self.paceMenu.addItem(NSMenuItem(title: "Refresh", action: #selector(self.refreshPaceInfo), keyEquivalent: "r"))
                    }
                }
                
                DispatchQueue.main.sync {
                    self.paceMenu.addItem(NSMenuItem.separator())
                    self.paceMenu.addItem(NSMenuItem(title: "Refresh", action: #selector(self.refreshPaceInfo), keyEquivalent: "r"))
                }
            }
        } catch {
            paceMenu.addItem(NSMenuItem(title: error.localizedDescription, action: nil))
            paceMenu.addItem(NSMenuItem.separator())
            paceMenu.addItem(NSMenuItem(title: "Refresh", action: #selector(self.refreshPaceInfo), keyEquivalent: "r"))
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
                            let view = CMMapView(bus: busMark, stop: stopMark, timeLastUpdated: timeLastUpdated)
                            if ["92nd/Commercial", "Commercial/92nd"].contains(sender.vehicleTerminus) {
                                view.n5 = true
                            }
                            self.mapWindows[index].contentView = view
                            
                            self.mapWindows[index].center()
                            self.mapWindows[index].setIsVisible(true)
                            self.mapWindows[index].orderFrontRegardless()
                            self.mapWindows[index].makeKey()
                            NSApp.activate(ignoringOtherApps: true)
                        }
                    }
                } else {
                    mapWindows[index].title = "Carmine - \(sender.busRoute?.textualRepresentation(addRouteNumber: true) ?? "Unknown Route") bus \(sender.vehicleNumber ?? "0000")"
                    
                    let view = CMMapView(bus: busMark, timeLastUpdated: timeLastUpdated)
                    if ["92nd/Commercial", "Commercial/92nd"].contains(sender.vehicleTerminus) {
                        view.n5 = true
                    }
                    mapWindows[index].contentView = view
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
        mapMutex.lock()
        if let screenSize = NSScreen.main?.frame.size {
            let window = NSWindow(contentRect: NSMakeRect(0, 0, screenSize.width * 0.5, screenSize.height * 0.5), styleMask: [.titled, .closable], backing: .buffered, defer: false)
            let index = mapWindows.count
            mapWindows.append(window)
            
            let placemark = PTPlacemark(coordinate: sender.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0))
            
            if let vehicleId = sender.vehicleNumber, let route = sender.route {
                placemark.route = route
                placemark.vehicleNumber = vehicleId
                placemark.heading = sender.vehicleHeading ?? 0
                let direction = PTDirection.PTVehicleDirection(degrees: sender.vehicleHeading ?? 0)
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale.current
                
                dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "HH:mm", options: 0, locale: Locale.current)
                
                mapWindows[index].title = "Carmine - \(route.fullName) bus \(vehicleId) heading \(direction.description)"
                
                self.mapWindows[index].contentView = PTMapView(mark: placemark, timeLastUpdated: dateFormatter.string(from: Date()), isVehicle: true)
                self.mapWindows[index].center()
                self.mapWindows[index].setIsVisible(true)
                self.mapWindows[index].orderFrontRegardless()
                self.mapWindows[index].makeKey()
                NSApp.activate(ignoringOtherApps: true)
            } else if let stop = sender.stop, let route = sender.route {
                placemark.route = route
                placemark.stopName = stop.name
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale.current
                
                dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "HH:mm", options: 0, locale: Locale.current)
                
                mapWindows[index].title = "Carmine - \(route.fullName) \(stop.directionName)bound stop \(stop.name)"
                
                self.mapWindows[index].contentView = PTMapView(mark: placemark, timeLastUpdated: dateFormatter.string(from: Date()), isVehicle: false)
                self.mapWindows[index].center()
                self.mapWindows[index].setIsVisible(true)
                self.mapWindows[index].orderFrontRegardless()
                self.mapWindows[index].makeKey()
                NSApp.activate(ignoringOtherApps: true)
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
