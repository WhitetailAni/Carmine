//
//  CMTime.swift
//  Carmine
//
//  Created by WhitetailAni on 7/26/24.
//

import Foundation

struct CMTime: Comparable {
    let hour: Int
    let minute: Int
    
    init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }
    
    static func < (lhs: CMTime, rhs: CMTime) -> Bool {
        return lhs.hour * 60 + lhs.minute < rhs.hour * 60 + rhs.minute
    }
    
    static func == (lhs: CMTime, rhs: CMTime) -> Bool {
        return lhs.hour == rhs.hour && lhs.minute == rhs.minute
    }
    
    static func isItCurrentlyBetween(start: CMTime, end: CMTime) -> Bool {
        let now = Date()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "America/Chicago")!
        let current = CMTime(hour: calendar.component(.hour, from: now), minute: calendar.component(.minute, from: now))
        
        if start < end {
            return start <= current && current < end
        } else {
            return current >= start || current < end
        }
    }
    
    static func is24Hour() -> Bool {
        let dateFormat = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)!

        return dateFormat.firstIndex(of: "a") == nil
    }
    
    static func apiTimeToReadabletime(string: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyyMMdd HH:mm"
        inputFormatter.timeZone = TimeZone(identifier: "America/Chicago")
        let time: Date = inputFormatter.date(from: string) ?? Date(timeIntervalSince1970: 0)
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm"
        outputFormatter.timeZone = TimeZone.autoupdatingCurrent
        
        return outputFormatter.string(from: time)
    }
    
    static func currentReadableTime() -> String {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm"
        outputFormatter.timeZone = TimeZone.autoupdatingCurrent
        
        return outputFormatter.string(from: Date())
    }
}
