//
//  FindMyBus.swift
//  Carmine
//
//  Created by WhitetailAni on 4/23/25.
//

import Cocoa
import AppKit
import PaceTracker
import CoreLocation
import UserNotifications

class FindMyBusNotifications: NSObject, UNUserNotificationCenterDelegate {
    static let shared = FindMyBusNotifications()
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func canIPunchYou(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { yes, no in
            if let error = no {
                print("couldnt get permission \(error.localizedDescription)")
            }
            completion(yes)
        }
    }
    
    func pushNotification(title: String, body: String, info: [AnyHashable: Any] = [:]) {
        if let allowed = Bundle.main.infoDictionary?["CMFindMyBus"] as? Bool {
            if allowed {
                let notif = UNMutableNotificationContent()
                notif.title = title
                notif.body = body
                notif.sound = UNNotificationSound.default
                notif.userInfo = info
                
                let notifRequest = UNNotificationRequest(identifier: UUID().uuidString, content: notif, trigger: nil)
                
                UNUserNotificationCenter.current().add(notifRequest) { error in
                    if let error = error {
                        print("couldnt send notif \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if userInfo["busType"] as? String == "CTA" {
            if let menuItemDict = userInfo["menuItemDict"] as? [String: Any], let terminus = menuItemDict["vehicleTerminus"] as? String, let routeData = menuItemDict["busRoute"] as? Data, let vehicleId = menuItemDict["vehicleId"] as? String, let timeLastUpdated = menuItemDict["timeLastUpdated"] as? String, let latitude = menuItemDict["latitude"] as? Double, let longitude = menuItemDict["longitude"] as? Double, let route = CMRoute.createCMRouteFromData(data: routeData) {
                
                let dummyItem = CMMenuItem(title: "dummy", action: nil)
                dummyItem.vehicleCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                dummyItem.vehicleTerminus = terminus
                
                dummyItem.busRoute = route
                dummyItem.vehicleId = vehicleId
                dummyItem.timeLastUpdated = timeLastUpdated
                
                
                (NSApplication.shared as! CarmineApp).strongDelegate.openCTAMapWindow(dummyItem)
            }
        } else {
            if let menuItemDict = userInfo["menuItemDict"] as? [String: Any], let routeData = menuItemDict["route"] as? Data, let vehicleId = menuItemDict["vehicleId"] as? String, let heading = menuItemDict["heading"] as? Int, let latitude = menuItemDict["latitude"] as? Double, let longitude = menuItemDict["longitude"] as? Double, let route = PTRoute.createPTRouteFromData(data: routeData) {
                
                let dummyItem = PTMenuItem(title: "dummy", action: nil)
                dummyItem.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                dummyItem.route = route
                dummyItem.vehicleId = vehicleId
                dummyItem.vehicleHeading = heading
                
                
                (NSApplication.shared as! CarmineApp).strongDelegate.openPaceMapWindow(dummyItem)
            }
        }
        
        completionHandler()
    }
}
