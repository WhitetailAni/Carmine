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
    
    static func < (lhs: CMTime, rhs: CMTime) -> Bool {
        return lhs.hour * 60 + lhs.minute < rhs.hour * 60 + rhs.minute
    }
    
    static func == (lhs: CMTime, rhs: CMTime) -> Bool {
        return lhs.hour == rhs.hour && lhs.minute == rhs.minute
    }
    
    static func isItCurrentlyBetween(start: CMTime, end: CMTime) -> Bool {
        let now = Date()
        let calendar = Calendar.current
        let current = CMTime(hour: calendar.component(.hour, from: now), minute: calendar.component(.minute, from: now))
        
        if start < end {
            return start <= current && current < end
        } else {
            return current >= start || current < end
        }
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
