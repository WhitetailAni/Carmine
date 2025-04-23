//
//  FindMyBus.swift
//  Carmine
//
//  Created by WhitetailAni on 4/23/25.
//

import Cocoa
import UserNotifications

class FindMyBus {
    static let shared = FindMyBus()
    
    func canIPunchYou(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { yes, no in
            if let error = no {
                print("couldnt get permission \(error.localizedDescription)")
            }
            completion(yes)
        }
    }
    
    func pushNotification(title: String, body: String) {
        if Bundle.main.infoDictionary?["CMFindMyBus"] != nil {
            let notif = UNMutableNotificationContent()
            notif.title = title
            notif.body = body
            notif.sound = UNNotificationSound.default
            
            let notifRequest = UNNotificationRequest(identifier: UUID().uuidString, content: notif, trigger: nil)
            
            UNUserNotificationCenter.current().add(notifRequest) { error in
                if let error = error {
                    print("couldnt send notif \(error.localizedDescription)")
                }
            }
        }
    }
}
