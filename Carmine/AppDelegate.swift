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
    
    var findMyBusWindows: [NSWindow] = []
    var findMyBusMutex = NSLock()
    
    var canPush = false
    var findMyBusDict: [String: Any] = [:]
    var ctaBusesAlreadyPushed: [String] = []
    var paceBusesAlreadyPushed: [String] = []
    var totalBuses = 0
    
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
        
        FindMyBusNotifications.shared.canIPunchYou { permissionState in
            self.canPush = permissionState
        }
        findMyBusDict = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "bus", ofType: "plist") ?? "") as? [String: Any] ?? [:]
        
        menu = NSMenu()
        ctaMenu = NSMenu()
        paceMenu = NSMenu()
        
        refreshInfo()
        
        /*findMyBusMutex.lock()
        if let screenSize = NSScreen.main?.frame.size {
            let defaultRect = NSMakeRect(0, 0, screenSize.width * 0.8, screenSize.height * 0.8)
            findMyBusWindows.append(NSWindow(contentRect: defaultRect, styleMask: [.titled, .closable], backing: .buffered, defer: false))
            let index = findMyBusWindows.count - 1
            
            findMyBusWindows[index].contentView = FCMapView(skippedRoutes: []/*[._90, ._86, ._201, ._206, ._30, ._152, ._78, ._165, ._63W, ._62, ._54A, ._54B, ._65, ._81W, ._93, ._85A, ._68, ._88, ._52A, ._108, ._50, ._44, ._62H, ._95, ._71, ._57, ._7, ._134, ._135, ._136, ._143, ._148, ._146, ._155, ._97, ._3, ._X4, ._112, ._115, ._100, ._60, ._157, ._73, ._76, ._1, ._70, ._92, ._94, ._X9, ._X49, ._24, ._146, ._147, ._26, ._6, ._59, ._67, ._126, ._156, ._36, ._120, ._121, ._111A, ._56, ._48, ._11, ._37, ._130, ._10, ._124, ._18, ._55A, ._55N, ._151, ._96, ._125]*/)
            findMyBusWindows[index].title = "Carmine - Fiscal Cliff"
            findMyBusWindows[index].center()
            findMyBusWindows[index].setIsVisible(true)
            findMyBusWindows[index].orderFrontRegardless()
            findMyBusWindows[index].makeKey()
            NSApp.activate(ignoringOtherApps: true)
        }
        findMyBusMutex.unlock()*/
        
        let ctaTitleString = createMutableStringFromImage(imageName: "cta")
        let paceTitleString = createMutableStringFromImage(imageName: "pace")
        
        let ctaItem = CMMenuItem(title: "", action: #selector(twoInOne(_:)))
        ctaItem.attributedTitle = ctaTitleString
        ctaItem.linkToOpen = URL(string: "https://ctabustracker.com/home")
        ctaItem.viewState = .cta
        ctaItem.submenu = ctaMenu
        
        let paceItem = CMMenuItem(title: "", action: #selector(twoInOne(_:)))
        paceItem.attributedTitle = paceTitleString
        paceItem.linkToOpen = URL(string: "https://tmweb.pacebus.com/TMWebWatch/")
        paceItem.viewState = .pace
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
    
    func createMutableStringFromImage(imageName: String) -> NSMutableAttributedString {
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
        
        return attributedTitle
    }
    
    @MainActor @objc func refreshInfo() {
        findMyBusDict = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "bus", ofType: "plist") ?? "") as? [String: Any] ?? [:]
        
        refreshCTAInfo()
        refreshPaceInfo()
        if NSEvent.modifierFlags.contains(.option) {
            ctaBusesAlreadyPushed = []
            paceBusesAlreadyPushed = []
        }
    }
    
    @MainActor @objc func refreshCTAInfo() {
        ctaMenu.removeAllItems()
        totalBuses = 0
        DispatchQueue.global().async {
            for route2 in CMRoute.allCases {
                var route = route2
                let findMyCTABusDict = self.findMyBusDict["CMFindMyBusCTA"] as? [String: Any] ?? [:]
                let findMyCTABusSpecific = findMyCTABusDict["CMFindMyBusSpecific"] as? [String] ?? []
                let findMyCTABusRange = findMyCTABusDict["CMFindMyBusRange"] as? [[String]] ?? []
                
                var item: CMMenuItem!
                if var glyphs = route.glyphs() {
                    let title = NSMutableAttributedString(string: route.textualRepresentation(addRouteNumber: true))
                    item = CMMenuItem(title: "", action: #selector(self.openLink(_:)))
                    if route2.isNightServiceActive() {
                        glyphs.append(contentsOf: route.nightGlyphs() ?? [])
                    }
                    
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
                    
                let info = ChicagoTransitInterface().getVehiclesForRoute(route: route)
                let errorString = ChicagoTransitInterface.returnErrorString(info: info)
                if errorString != "i love kissing girls" {
                    DispatchQueue.main.sync {
                        self.ctaMenu.addItem(CMMenuItem(title: errorString, action: nil))
                    }
                    break
                }
                let vehicles = ChicagoTransitInterface.cleanUpVehicleInfo(info: info)
                
                if vehicles.count == 0 {
                    continue
                } else {
                    let detours = ChicagoTransitInterface().getDetoursForRoute(route: route)
                    //print(detours)
                    
                    DispatchQueue.main.sync {
                        subMenu.removeItem(at: 0)
                        
                        let timeLastUpdated = CMTime.apiTimeToReadabletime(string: vehicles[0].timestampLastUpdated)
                        
                        if detours.count > 0 {
                            let timeLastUpdatedItem = NSMenuItem(title: "", action: #selector(self.nop))
                            let title = NSMutableAttributedString(string: "Last updated at \(timeLastUpdated)")
                            item = CMMenuItem(title: "", action: #selector(self.openLink(_:)))
                            
                            let glyph = NSImage(named: "alert")!
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
                            timeLastUpdatedItem.attributedTitle = title
                            
                            
                            //once the getdetours endpoint works, the timeLastUpdated item will show applicable route detours
                            
                            /*let detourMenu = NSMenu()
                            
                            for detour in detours {
                                let detourItem = CMMenuItem(title: "\(detour.title)", action: #selector(self.openLink(_:)))
                                detourItem.linkToOpen = detour.link
                                detourMenu.addItem(detourItem)
                            }
                            
                            timeLastUpdatedItem.submenu = detourMenu = detourMenu*/
                            
                            subMenu.addItem(timeLastUpdatedItem)
                        } else {
                            subMenu.addItem(NSMenuItem(title: "Last updated at \(timeLastUpdated)", action: nil))
                        }
                        
                        subMenu.addItem(NSMenuItem.separator())
                        
                        for vehicle in vehicles {
                            var subItem: CMMenuItem!
                            self.totalBuses += 1
                            
                            subItem = CMMenuItem(title: "\(vehicle.vehicleId) to \(vehicle.destination)", action: #selector(self.openCTAMapWindow(_:)))
                            subItem.vehicleCoordinate = vehicle.location
                            subItem.vehicleTerminus = vehicle.destination
                            
                            subItem.busRoute = route
                            subItem.vehicleId = vehicle.vehicleId
                            subItem.timeLastUpdated = timeLastUpdated
                            subItem.action = #selector(self.openCTAMapWindow(_:))
                            
                            if !self.ctaBusesAlreadyPushed.contains(vehicle.vehicleId) {
                                self.ctaBusesAlreadyPushed.removeAll(where: { $0 == vehicle.vehicleId })
                            }
                            
                            for busNumber in findMyCTABusSpecific {
                                if busNumber == vehicle.vehicleId && !self.ctaBusesAlreadyPushed.contains(vehicle.vehicleId) {
                                    let nextStop = ChicagoTransitInterface().getNextPredictionForVehicle(route: route, vehicleId: vehicle.vehicleId)
                                    let nextStopName = nextStop["stopName"] ?? "Unknown"
                                    
                                    FindMyBusNotifications.shared.pushNotification(title: "\(vehicle.vehicleId) on route \(route.routeNumber())", body: "Next stop \(nextStopName), terminus \(vehicle.destination)", info: ["busType": "CTA", "menuItemDict": ["latitude": vehicle.location.latitude, "longitude": vehicle.location.longitude, "vehicleTerminus": vehicle.destination, "busRoute": route.convertSelfToData(), "vehicleId": vehicle.vehicleId, "timeLastUpdated": timeLastUpdated]])
                                    self.ctaBusesAlreadyPushed.append(vehicle.vehicleId)
                                    
                                }
                            }
                            for busRange in findMyCTABusRange {
                                let first = busRange[0]
                                let last = busRange[1]
                                if (first <= vehicle.vehicleId && vehicle.vehicleId <= last) && !self.ctaBusesAlreadyPushed.contains(vehicle.vehicleId) {
                                    let nextStop = ChicagoTransitInterface().getNextPredictionForVehicle(route: route, vehicleId: vehicle.vehicleId)
                                    let nextStopName = nextStop["stopName"] ?? "Unknown"
                                    
                                    FindMyBusNotifications.shared.pushNotification(title: "\(vehicle.vehicleId) on route \(route.routeNumber())", body: "Next stop \(nextStopName), terminus \(vehicle.destination)", info: ["busType": "CTA", "menuItemDict": ["latitude": vehicle.location.latitude, "longitude": vehicle.location.longitude, "vehicleTerminus": vehicle.destination, "busRoute": route.convertSelfToData(), "vehicleId": vehicle.vehicleId, "timeLastUpdated": timeLastUpdated]])
                                    self.ctaBusesAlreadyPushed.append(vehicle.vehicleId)
                                }
                            }
                            
                            let subSubMenu = NSMenu()
                            subSubMenu.addItem(NSMenuItem.progressWheel())
                            subItem.submenu = subSubMenu
                            subMenu.addItem(subItem)
                            
                            DispatchQueue.global().async {
                                let stopPredictions = ChicagoTransitInterface().getPredictionsForVehicle(route: route, vehicleId: vehicle.vehicleId)
                                
                                DispatchQueue.main.sync {
                                    subSubMenu.removeItem(at: 0)
                                    
                                    if stopPredictions.count > 0 {
                                        let subSubItem = CMMenuItem(title: "\(route.textualRepresentation(addRouteNumber: false)) bus \(vehicle.vehicleId), \((stopPredictions[0].direction).lowercased()) to \(vehicle.destination)", action: #selector(self.openCTAMapWindow(_:)))
                                        
                                        subSubItem.busRoute = route
                                        subSubItem.vehicleId = vehicle.vehicleId
                                        subSubItem.timeLastUpdated = timeLastUpdated
                                        
                                        subSubMenu.addItem(subSubItem)
                                        subSubMenu.addItem(NSMenuItem.separator())
                                        
                                        for stop in stopPredictions {
                                            let subSubItem = CMMenuItem(title: "\(stop.stopName) at \(CMTime.apiTimeToReadabletime(string: stop.departureTimestamp))", action: #selector(self.openCTAMapWindow(_:)))
                                            
                                            subSubItem.vehicleDirection = stop.direction
                                            subSubItem.vehicleCoordinate = vehicle.location
                                            subSubItem.busRoute = route
                                            subSubItem.vehicleId = vehicle.vehicleId
                                            subSubItem.timeLastUpdated = timeLastUpdated
                                            subSubItem.vehicleDesiredStopID = stop.stopId
                                            subSubItem.vehicleDesiredStop = stop.stopName
                                            
                                            subSubMenu.addItem(subSubItem)
                                            
                                            let subSubSubMenu = NSMenu()
                                            
                                            if stop.delayed {
                                                let delayItem = NSMenuItem(title: "Delayed", action: #selector(self.nop))
                                                subSubSubMenu.addItem(delayItem)
                                            }
                                            
                                            if stop.isDeparture {
                                                let departureItem = NSMenuItem(title: "Terminal stop", action: #selector(self.nop))
                                                subSubSubMenu.addItem(departureItem)
                                                subSubSubMenu.addItem(NSMenuItem.separator())
                                            }
                                            
                                            if subSubSubMenu.items.count > 0 {
                                                subSubItem.submenu = subSubSubMenu
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
                    
                    let findMyBusPaceDict = self.findMyBusDict["CMFindMyBusPace"] as? [String: Any] ?? [:]
                    let findMyPaceBusSpecific = findMyBusPaceDict["CMFindMyBusSpecific"] as? [String] ?? []
                    let findMyPaceBusRange = findMyBusPaceDict["CMFindMyBusRange"] as? [[String]] ?? []
                    
                    if [0, 352].contains(route.number) {
                        let title = NSMutableAttributedString(string: route.fullName)
                        
                        let height = NSFont.menuFont(ofSize: 0).boundingRectForFont.height - 5
                        var freqBaseImage: NSImage!
                        if route.number == 352 {
                            freqBaseImage = NSImage(named: "nightOwl")!
                        } else {
                            freqBaseImage = NSImage(named: "pulse")!
                        }
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
                    
                    let vehicleMenuItem = PTMenuItem(title: "Vehicles", action: #selector(self.openLink(_:)))
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
                                let vehicleItem = PTMenuItem(title: "\(vehicle.vehicleId) heading \(direction)", action: #selector(self.openPaceMapWindow(_:)))
                                vehicleItem.vehicleId = vehicle.vehicleId
                                vehicleItem.coordinate = vehicle.location
                                vehicleItem.route = route
                                vehicleItem.linkToOpen = route.link()
                                vehicleItem.vehicleHeading = vehicle.heading
                                
                                if !self.paceBusesAlreadyPushed.contains(vehicle.vehicleId) {
                                    self.paceBusesAlreadyPushed.removeAll(where: { $0 == vehicle.vehicleId })
                                }
                                
                                for busNumber in findMyPaceBusSpecific {
                                    if busNumber == vehicle.vehicleId && !self.paceBusesAlreadyPushed.contains(vehicle.vehicleId) {
                                        
                                        var routeNum = "route \(route.number)"
                                        if route.number == 0 {
                                            routeNum = route.fullName
                                        }
                                        
                                        FindMyBusNotifications.shared.pushNotification(title: "\(vehicle.vehicleId) on \(routeNum)", body: "Current heading \(vehicle.heading)°", info: ["busType": "Pace", "menuItemDict": ["vehicleId": vehicle.vehicleId, "latitude": vehicle.location.latitude, "longitude": vehicle.location.longitude, "route": route.convertSelfToData(), "heading": vehicle.heading]])
                                        self.paceBusesAlreadyPushed.append(vehicle.vehicleId)
                                        
                                    }
                                }
                                for busRange in findMyPaceBusRange {
                                    let first = busRange[0]
                                    let last = busRange[1]
                                    if (first <= vehicle.vehicleId && vehicle.vehicleId <= last) && !self.paceBusesAlreadyPushed.contains(vehicle.vehicleId) {
                                        
                                        var routeNum = "route \(route.number)"
                                        if route.number == 0 {
                                            routeNum = route.fullName
                                        }
                                        
                                        FindMyBusNotifications.shared.pushNotification(title: "\(vehicle.vehicleId) on \(routeNum)", body: "Current heading \(vehicle.heading)°", info: ["busType": "Pace", "menuItemDict": ["vehicleId": vehicle.vehicleId, "latitude": vehicle.location.latitude, "longitude": vehicle.location.longitude, "route": route.convertSelfToData(), "heading": vehicle.heading]])
                                        self.paceBusesAlreadyPushed.append(vehicle.vehicleId)
                                    }
                                }
                                
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
            
            if let route = sender.busRoute, let vehicleId = sender.vehicleId, let timeLastUpdated = sender.timeLastUpdated {
                let stopName = sender.vehicleDesiredStop ?? "Rochester"
                busMark.route = route
                busMark.vehicleId = vehicleId
                busMark.stopName = stopName
                busMark.stopId = sender.vehicleDesiredStopID
                
                let instance = ChicagoTransitInterface()
                if let id = sender.vehicleDesiredStopID, let direction = sender.vehicleDirection {
                    busMark.direction = direction
                    mapWindows[index].title = "Carmine - \(sender.busRoute?.textualRepresentation(addRouteNumber: true) ?? "Unknown Route") bus \(sender.vehicleId ?? "0000") to \(sender.vehicleDesiredStop ?? "Unknown")"
                    
                    DispatchQueue.global().async {
                        let coordinate = instance.getStopCoordinatesForID(route: route, direction: direction, id: id)
                        
                        let stopMark = CMPlacemark(coordinate: coordinate)
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
                    mapWindows[index].title = "Carmine - \(sender.busRoute?.textualRepresentation(addRouteNumber: true) ?? "Unknown Route") bus \(sender.vehicleId ?? "0000")"
                    
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
            
            if let vehicleId = sender.vehicleId, let route = sender.route {
                placemark.route = route
                placemark.vehicleId = vehicleId
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
    
    @objc func openFindMyBusWindow(_ sender: CMMenuItem) {
        findMyBusMutex.lock()
        if let screenSize = NSScreen.main?.frame.size, let state = sender.viewState {
            let defaultRect = NSMakeRect(0, 0, screenSize.width * 0.27, screenSize.height * 0.27)
            findMyBusWindows.append(NSWindow(contentRect: defaultRect, styleMask: [.titled, .closable], backing: .buffered, defer: false))
            let index = findMyBusWindows.count - 1
            
            findMyBusWindows[index].contentView = NSHostingView(rootView: FindMyBusView(selection: state))
            findMyBusWindows[index].title = "Carmine - Find My Bus"
            findMyBusWindows[index].center()
            findMyBusWindows[index].setIsVisible(true)
            findMyBusWindows[index].orderFrontRegardless()
            findMyBusWindows[index].makeKey()
            NSApp.activate(ignoringOtherApps: true)
        }
        findMyBusMutex.unlock()
    }
    
    @objc func twoInOne(_ sender: CMMenuItem) {
        guard let currentEvent = NSApp.currentEvent else {
            return
        }
        
        if currentEvent.modifierFlags.contains(.option) {
            openFindMyBusWindow(sender)
        } else {
            openLink(sender)
        }
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
