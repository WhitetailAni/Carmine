//
//  MapView.swift
//  Carmine
//
//  Created by WhitetailAni on 7/23/24.
//

import Foundation
import CoreLocation

///The class used to interface with the CTA's Train Tracker API. A new instance should be created on every request to allow for multiple concurrent requests.
class ChicagoTransitInterface: NSObject {
    let semaphore = DispatchSemaphore(value: 0)
    private let busTrackerAPIKey = "NknhMpnUYfzxrjk3pWw2pTZ3A"
    
    public static var polylines = ChicagoTransitInterface(polyline: true)
    var overlayTable: [String: [CLLocationCoordinate2D]] = [:]
    
    override init() {
        super.init()
    }
    
    init(polyline: Bool) {
        super.init()
        storeOverlay()
    }
    
    ///Checks if service has ended for the day for a given CTA line
    /*class func hasServiceEnded(route: CMRoute) -> Bool {
        var weekday = Calendar.current.component(.weekday, from: Date())
        if isHoliday() {
            weekday = 1
        }
        switch route {
        case ._1:
            if !(weekday == 1 || weekday == 7) {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 9, minute: 31), end: CMTime(hour: 14, minute: 27)) || CMTime.isItCurrentlyBetween(start: CMTime(hour: 19, minute: 27), end: CMTime(hour: 5, minute: 45))
            }
            return true
        case ._2:
            if !(weekday == 1 || weekday == 7) {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 10, minute: 08), end: CMTime(hour: 15, minute: 30)) || CMTime.isItCurrentlyBetween(start: CMTime(hour: 19, minute: 51), end: CMTime(hour: 6, minute: 00))
            }
            return true
        case ._3:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 20), end: CMTime(hour: 5, minute: 54))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 32), end: CMTime(hour: 4, minute: 25))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 32), end: CMTime(hour: 4, minute: 24))
            }
        case ._4, ._9, ._20, ._22, ._34, ._49, ._53, ._55, ._60, ._62, ._63, ._66, ._77, ._79, ._81, ._87:
            return false
        case ._X4:
            if !(weekday == 1 || weekday == 7) {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 11, minute: 01), end: CMTime(hour: 13, minute: 30)) || CMTime.isItCurrentlyBetween(start: CMTime(hour: 19, minute: 37), end: CMTime(hour: 5, minute: 44))
            }
        case ._N5:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 6, minute: 03), end: CMTime(hour: 23, minute: 51))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 5, minute: 37), end: CMTime(hour: 23, minute: 51))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 5, minute: 39), end: CMTime(hour: 23, minute: 51))
            }
        case ._6:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 50), end: CMTime(hour: 4, minute: 00))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 51), end: CMTime(hour: 4, minute: 55))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 49), end: CMTime(hour: 4, minute: 55))
            }
        case ._7:
            if !(weekday == 1 || weekday == 7) {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 50), end: CMTime(hour: 4, minute: 00))
            }
        case ._8:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 36), end: CMTime(hour: 4, minute: 09))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 54), end: CMTime(hour: 3, minute: 43))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 47), end: CMTime(hour: 4, minute: 05))
            }
        case ._8A:
            if weekday == 1 || weekday == 7 {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 35), end: CMTime(hour: 3, minute: 38))
            } else {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 47), end: CMTime(hour: 4, minute: 05))
            }
        case ._X9:
            if !(weekday == 1 || weekday == 7) {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 20, minute: 53), end: CMTime(hour: 4, minute: 43)) || CMTime.isItCurrentlyBetween(start: CMTime(hour: 12, minute: 08), end: CMTime(hour: 13, minute: 24))
            }
        case ._10:
            if dorvalCarter() {
                switch weekday {
                case 1:
                    return CMTime.isItCurrentlyBetween(start: CMTime(hour: 18, minute: 51), end: CMTime(hour: 8, minute: 50))
                case 7:
                    return CMTime.isItCurrentlyBetween(start: CMTime(hour: 18, minute: 52), end: CMTime(hour: 8, minute: 50))
                default:
                    return CMTime.isItCurrentlyBetween(start: CMTime(hour: 18, minute: 53), end: CMTime(hour: 8, minute: 50))
                }
            }
        case ._11:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 19, minute: 21), end: CMTime(hour: 7, minute: 08))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 19, minute: 52), end: CMTime(hour: 7, minute: 11))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 19, minute: 55), end: CMTime(hour: 6, minute: 00))
            }
        case ._12:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 40), end: CMTime(hour: 3, minute: 49))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 43), end: CMTime(hour: 3, minute: 40))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 35), end: CMTime(hour: 3, minute: 38))
            }
        case ._J14:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 11, minute: 30), end: CMTime(hour: 5, minute: 39))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 14), end: CMTime(hour: 4, minute: 55))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 00), end: CMTime(hour: 3, minute: 45))
            }
        case ._15:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 45), end: CMTime(hour: 4, minute: 40))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 46), end: CMTime(hour: 4, minute: 30))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 45), end: CMTime(hour: 4, minute: 00))
            }
        case ._18:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 20, minute: 32), end: CMTime(hour: 7, minute: 25))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 20, minute: 39), end: CMTime(hour: 6, minute: 24))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 22, minute: 01), end: CMTime(hour: 5, minute: 24))
            }
        case ._19, ._128:
            #warning("Event specific buses are fun! Just assume always active ig")
            return false
        case ._21:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 59), end: CMTime(hour: 5, minute: 50))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 36), end: CMTime(hour: 3, minute: 58))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 32), end: CMTime(hour: 4, minute: 00))
            }
        case ._24:
            if !(weekday == 1 || weekday == 7) {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 21, minute: 17), end: CMTime(hour: 5, minute: 45))
            }
        case ._26:
            if !(weekday == 1 || weekday == 7) {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 22, minute: 37), end: CMTime(hour: 4, minute: 15))
            }
        case ._28:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 57), end: CMTime(hour: 5, minute: 05))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 59), end: CMTime(hour: 4, minute: 45))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 59), end: CMTime(hour: 4, minute: 00))
            }
        case ._29:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 30), end: CMTime(hour: 4, minute: 00))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 32), end: CMTime(hour: 4, minute: 00))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 22), end: CMTime(hour: 4, minute: 00))
            }
        case ._30:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 10), end: CMTime(hour: 5, minute: 51))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 22), end: CMTime(hour: 4, minute: 45))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 23), end: CMTime(hour: 4, minute: 23))
            }
        case ._31:
            if !(weekday == 1 || weekday == 7) {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 19, minute: 35), end: CMTime(hour: 6, minute: 31))
            }
        case ._35:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 12, minute: 15), end: CMTime(hour: 3, minute: 57))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 20), end: CMTime(hour: 3, minute: 32))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 16), end: CMTime(hour: 3, minute: 28))
            }
        case ._36:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 23), end: CMTime(hour: 4, minute: 10))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 44), end: CMTime(hour: 4, minute: 09))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 25), end: CMTime(hour: 4, minute: 00))
            }
        case ._37:
            if !(weekday == 1 || weekday == 7) {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 20, minute: 00), end: CMTime(hour: 6, minute: 05))
            }
        case ._39:
            if weekday == 1 || weekday == 7 {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 18, minute: 31), end: CMTime(hour: 7, minute: 30))
            } else {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 15), end: CMTime(hour: 5, minute: 00))
            }
        case ._43:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 19, minute: 37), end: CMTime(hour: 7, minute: 00))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 19, minute: 36), end: CMTime(hour: 6, minute: 40))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 07), end: CMTime(hour: 5, minute: 00))
            }
        case ._44:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 19, minute: 35), end: CMTime(hour: 8, minute: 51))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 19, minute: 37), end: CMTime(hour: 7, minute: 50))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 17), end: CMTime(hour: 4, minute: 21))
            }
        case ._47:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 56), end: CMTime(hour: 3, minute: 45))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 54), end: CMTime(hour: 3, minute: 44))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 58), end: CMTime(hour: 3, minute: 36))
            }
        case ._48:
            if !(weekday == 1 || weekday == 7) {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 10, minute: 12), end: CMTime(hour: 14, minute: 00)) || CMTime.isItCurrentlyBetween(start: CMTime(hour: 19, minute: 13), end: CMTime(hour: 6, minute: 08))
            }
        case ._49B:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 00), end: CMTime(hour: 5, minute: 12))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 04), end: CMTime(hour: 4, minute: 10))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 03), end: CMTime(hour: 4, minute: 12))
            }
        case ._X49:
            if !(weekday == 1 || weekday == 7) {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 10, minute: 14), end: CMTime(hour: 2, minute: 30)) || CMTime.isItCurrentlyBetween(start: CMTime(hour: 18, minute: 54), end: CMTime(hour: 5, minute: 30))
            }
        case ._50:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 03), end: CMTime(hour: 5, minute: 00))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 10), end: CMTime(hour: 5, minute: 00))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 14), end: CMTime(hour: 4, minute: 30))
            }
        case ._51:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 21, minute: 12), end: CMTime(hour: 7, minute: 37))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 21, minute: 12), end: CMTime(hour: 5, minute: 38))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 21, minute: 13), end: CMTime(hour: 5, minute: 37))
            }
        case ._52:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 58), end: CMTime(hour: 5, minute: 24))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 59), end: CMTime(hour: 4, minute: 25))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 12), end: CMTime(hour: 3, minute: 56))
            }
        case ._52A:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 21, minute: 51), end: CMTime(hour: 7, minute: 02))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 22, minute: 55), end: CMTime(hour: 4, minute: 10))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 21), end: CMTime(hour: 3, minute: 35))
            }
        case ._53A:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 29), end: CMTime(hour: 5, minute: 42))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 48), end: CMTime(hour: 4, minute: 50))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 59), end: CMTime(hour: 3, minute: 42))
            }
        case ._54:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 36), end: CMTime(hour: 3, minute: 40))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 40), end: CMTime(hour: 3, minute: 40))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 50), end: CMTime(hour: 3, minute: 35))
            }
        case ._54A:
            if !(weekday == 1 || weekday == 7) {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 18, minute: 54), end: CMTime(hour: 6, minute: 00))
            }
        case ._54B:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 20, minute: 35), end: CMTime(hour: 6, minute: 40))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 58), end: CMTime(hour: 4, minute: 20))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 15), end: CMTime(hour: 4, minute: 30))
            }
        case ._55A:
            if !(weekday == 1 || weekday == 7) {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 18, minute: 55), end: CMTime(hour: 5, minute: 17))
            }
        case ._55N:
            if weekday != 1 {
                if weekday == 7 {
                    return CMTime.isItCurrentlyBetween(start: CMTime(hour: 19, minute: 36), end: CMTime(hour: 5, minute: 32))
                } else {
                    return CMTime.isItCurrentlyBetween(start: CMTime(hour: 20, minute: 39), end: CMTime(hour: 5, minute: 06))
                }
            }
        case ._56:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 21), end: CMTime(hour: 4, minute: 20))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 41), end: CMTime(hour: 4, minute: 20))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 37), end: CMTime(hour: 4, minute: 20))
            }
        case ._57:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 18, minute: 45), end: CMTime(hour: 8, minute: 29))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 18, minute: 50), end: CMTime(hour: 6, minute: 09))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 21, minute: 37), end: CMTime(hour: 5, minute: 29))
            }
        case ._59:
            if weekday != 1 {
                if weekday == 7 {
                    return CMTime.isItCurrentlyBetween(start: CMTime(hour: 21, minute: 12), end: CMTime(hour: 7, minute: 10))
                } else {
                    return CMTime.isItCurrentlyBetween(start: CMTime(hour: 21, minute: 18), end: CMTime(hour: 5, minute: 08))
                }
            }
        case ._62H:
            if weekday != 1 {
                if weekday == 7 {
                    return CMTime.isItCurrentlyBetween(start: CMTime(hour: 19, minute: 15), end: CMTime(hour: 5, minute: 28))
                } else {
                    return CMTime.isItCurrentlyBetween(start: CMTime(hour: 20, minute: 47), end: CMTime(hour: 4, minute: 50))
                }
            }
        case ._63W:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 22, minute: 18), end: CMTime(hour: 6, minute: 40))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 19), end: CMTime(hour: 4, minute: 42))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 16), end: CMTime(hour: 3, minute: 58))
            }
        case ._65:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 00), end: CMTime(hour: 6, minute: 19))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 03), end: CMTime(hour: 4, minute: 40))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 04), end: CMTime(hour: 4, minute: 25))
            }
        case ._67:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 2, minute: 25), end: CMTime(hour: 5, minute: 07))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 2, minute: 38), end: CMTime(hour: 4, minute: 30))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 2, minute: 32), end: CMTime(hour: 4, minute: 14))
            }
        case ._68:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 20, minute: 33), end: CMTime(hour: 6, minute: 30))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 22, minute: 03), end: CMTime(hour: 4, minute: 30))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 22, minute: 06), end: CMTime(hour: 4, minute: 36))
            }
        case ._70:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 04), end: CMTime(hour: 4, minute: 49))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 12), end: CMTime(hour: 4, minute: 48))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 09), end: CMTime(hour: 4, minute: 28))
            }
        case ._71:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 31), end: CMTime(hour: 5, minute: 20))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 17), end: CMTime(hour: 4, minute: 40))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 23), end: CMTime(hour: 4, minute: 14))
            }
        case ._72:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 55), end: CMTime(hour: 3, minute: 30))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 2, minute: 03), end: CMTime(hour: 3, minute: 25))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 2, minute: 05), end: CMTime(hour: 3, minute: 26))
            }
        case ._73:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 20, minute: 13), end: CMTime(hour: 6, minute: 10))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 20, minute: 24), end: CMTime(hour: 5, minute: 11))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 04), end: CMTime(hour: 4, minute: 11))
            }
        case ._74:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 40), end: CMTime(hour: 5, minute: 20))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 36), end: CMTime(hour: 4, minute: 00))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 38), end: CMTime(hour: 3, minute: 40))
            }
        case ._75:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 14), end: CMTime(hour: 5, minute: 00))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 22), end: CMTime(hour: 5, minute: 00))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 23), end: CMTime(hour: 5, minute: 00))
            }
        case ._76:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 21, minute: 58), end: CMTime(hour: 7, minute: 21))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 22), end: CMTime(hour: 5, minute: 00))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 23), end: CMTime(hour: 5, minute: 00))
            }
        case ._78:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 18), end: CMTime(hour: 4, minute: 18))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 23), end: CMTime(hour: 3, minute: 25))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 25), end: CMTime(hour: 3, minute: 30))
            }
        case ._80:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 22), end: CMTime(hour: 6, minute: 30))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 30), end: CMTime(hour: 5, minute: 30))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 28), end: CMTime(hour: 4, minute: 34))
            }
        case ._81W:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 22, minute: 35), end: CMTime(hour: 8, minute: 20))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 20, minute: 40), end: CMTime(hour: 4, minute: 53))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 22, minute: 54), end: CMTime(hour: 4, minute: 55))
            }
        case ._82:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 57), end: CMTime(hour: 4, minute: 14))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 50), end: CMTime(hour: 4, minute: 19))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 57), end: CMTime(hour: 4, minute: 01))
            }
        case ._84:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 22, minute: 36), end: CMTime(hour: 5, minute: 00))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 20, minute: 47), end: CMTime(hour: 5, minute: 00))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 20, minute: 34), end: CMTime(hour: 7, minute: 30))
            }
        case ._85:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 16), end: CMTime(hour: 3, minute: 40))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 21), end: CMTime(hour: 3, minute: 40))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 17), end: CMTime(hour: 3, minute: 20))
            }
        case ._85A:
            if weekday != 1 {
                if weekday == 7 {
                    return CMTime.isItCurrentlyBetween(start: CMTime(hour: 19, minute: 43), end: CMTime(hour: 5, minute: 50))
                } else {
                    return CMTime.isItCurrentlyBetween(start: CMTime(hour: 21, minute: 23), end: CMTime(hour: 5, minute: 10))
                }
            }
        case ._86:
            if !(weekday == 1 || weekday == 7) {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 22, minute: 08), end: CMTime(hour: 5, minute: 27))
            }
        case ._88:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 22, minute: 42), end: CMTime(hour: 6, minute: 45))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 22, minute: 45), end: CMTime(hour: 5, minute: 45))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 22, minute: 45), end: CMTime(hour: 4, minute: 45))
            }
        case ._90:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 22, minute: 05), end: CMTime(hour: 6, minute: 20))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 22, minute: 38), end: CMTime(hour: 5, minute: 40))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 18), end: CMTime(hour: 4, minute: 15))
            }
        case ._91:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 22, minute: 41), end: CMTime(hour: 6, minute: 20))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 22, minute: 59), end: CMTime(hour: 4, minute: 30))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 51), end: CMTime(hour: 4, minute: 20))
            }
        case ._92:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 07), end: CMTime(hour: 4, minute: 19))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 22, minute: 27), end: CMTime(hour: 4, minute: 18))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 22, minute: 20), end: CMTime(hour: 5, minute: 30))
            }
        case ._93:
            if weekday != 1 {
                if weekday == 7 {
                    return CMTime.isItCurrentlyBetween(start: CMTime(hour: 20, minute: 57), end: CMTime(hour: 6, minute: 35))
                } else {
                    return CMTime.isItCurrentlyBetween(start: CMTime(hour: 22, minute: 23), end: CMTime(hour: 4, minute: 53))
                }
            }
        case ._94:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 34), end: CMTime(hour: 5, minute: 20))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 04), end: CMTime(hour: 4, minute: 40))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 48), end: CMTime(hour: 3, minute: 40))
            }
        case ._95:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 08), end: CMTime(hour: 5, minute: 02))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 07), end: CMTime(hour: 4, minute: 32))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 10), end: CMTime(hour: 4, minute: 30))
            }
        case ._96:
            if !(weekday == 1 || weekday == 7) {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 19, minute: 29), end: CMTime(hour: 5, minute: 26))
            }
        case ._97:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 22, minute: 55), end: CMTime(hour: 6, minute: 35))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 22, minute: 51), end: CMTime(hour: 6, minute: 30))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 16), end: CMTime(hour: 4, minute: 55))
            }
        case ._100:
            if !(weekday == 1 || weekday == 7) {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 19, minute: 48), end: CMTime(hour: 5, minute: 20))
            }
        case ._103:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 26), end: CMTime(hour: 4, minute: 35))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 14), end: CMTime(hour: 4, minute: 40))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 32), end: CMTime(hour: 4, minute: 30))
            }
        case ._106:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 20, minute: 23), end: CMTime(hour: 4, minute: 42))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 22, minute: 12), end: CMTime(hour: 4, minute: 45))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 22, minute: 46), end: CMTime(hour: 4, minute: 45))
            }
        case ._108:
            if !(weekday == 1 || weekday == 7) {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 21, minute: 18), end: CMTime(hour: 5, minute: 30))
            }
        case ._111:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 37), end: CMTime(hour: 5, minute: 36))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 34), end: CMTime(hour: 4, minute: 56))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 39), end: CMTime(hour: 4, minute: 30))
            }
        case ._111A:
            if weekday == 7 {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 20, minute: 03), end: CMTime(hour: 6, minute: 10))
            } else {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 20, minute: 02), end: CMTime(hour: 4, minute: 30))
            }
        case ._112:
            if weekday == 1 || weekday == 7 {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 4, minute: 24), end: CMTime(hour: 1, minute: 32))
            } else {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 22, minute: 58), end: CMTime(hour: 4, minute: 14))
            }
        case ._115:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 30), end: CMTime(hour: 5, minute: 23))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 25), end: CMTime(hour: 4, minute: 42))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 41), end: CMTime(hour: 4, minute: 25))
            }
        case ._119:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 00), end: CMTime(hour: 5, minute: 10))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 17), end: CMTime(hour: 5, minute: 10))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 25), end: CMTime(hour: 4, minute: 02))
            }
        case ._120:
            if !(weekday == 1 || weekday == 7) {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 9, minute: 40), end: CMTime(hour: 15, minute: 50)) || CMTime.isItCurrentlyBetween(start: CMTime(hour: 18, minute: 25), end: CMTime(hour: 6, minute: 50))
            }
        case ._121:
            if !(weekday == 1 || weekday == 7) {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 9, minute: 55), end: CMTime(hour: 15, minute: 40)) || CMTime.isItCurrentlyBetween(start: CMTime(hour: 18, minute: 31), end: CMTime(hour: 6, minute: 40))
            }
        case ._124:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 22, minute: 45), end: CMTime(hour: 8, minute: 40))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 22, minute: 49), end: CMTime(hour: 8, minute: 40))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 22, minute: 47), end: CMTime(hour: 8, minute: 40))
            }
        case ._125:
            if !(weekday == 1 || weekday == 7) {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 9, minute: 52), end: CMTime(hour: 14, minute: 50)) || CMTime.isItCurrentlyBetween(start: CMTime(hour: 19, minute: 43), end: CMTime(hour: 6, minute: 15))
            }
        case ._126:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 47), end: CMTime(hour: 5, minute: 25))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 52), end: CMTime(hour: 5, minute: 26))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 57), end: CMTime(hour: 4, minute: 50))
            }
        case ._130:
            if dorvalCarter() {
                switch weekday {
                case 1:
                    return CMTime.isItCurrentlyBetween(start: CMTime(hour: 18, minute: 28), end: CMTime(hour: 9, minute: 30))
                case 7:
                    return CMTime.isItCurrentlyBetween(start: CMTime(hour: 18, minute: 29), end: CMTime(hour: 9, minute: 39))
                default:
                    return CMTime.isItCurrentlyBetween(start: CMTime(hour: 18, minute: 36), end: CMTime(hour: 9, minute: 17))
                }
            }
        case ._134:
            if !(weekday == 1 || weekday == 7) {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 9, minute: 54), end: CMTime(hour: 15, minute: 45)) || CMTime.isItCurrentlyBetween(start: CMTime(hour: 19, minute: 05), end: CMTime(hour: 6, minute: 15))
            }
        case ._135:
            if !(weekday == 1 || weekday == 7) {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 10, minute: 12), end: CMTime(hour: 15, minute: 00)) || CMTime.isItCurrentlyBetween(start: CMTime(hour: 19, minute: 38), end: CMTime(hour: 5, minute: 45))
            }
        case ._136:
            if !(weekday == 1 || weekday == 7) {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 9, minute: 49), end: CMTime(hour: 15, minute: 45)) || CMTime.isItCurrentlyBetween(start: CMTime(hour: 19, minute: 23), end: CMTime(hour: 5, minute: 45))
            }
        case ._143:
            if !(weekday == 1 || weekday == 7) {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 9, minute: 34), end: CMTime(hour: 16, minute: 00)) || CMTime.isItCurrentlyBetween(start: CMTime(hour: 19, minute: 10), end: CMTime(hour: 6, minute: 30))
            }
        case ._146:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 25), end: CMTime(hour: 6, minute: 00))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 32), end: CMTime(hour: 6, minute: 00))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 25), end: CMTime(hour: 5, minute: 00))
            }
        case ._147:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 22), end: CMTime(hour: 5, minute: 19))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 24), end: CMTime(hour: 4, minute: 40))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 22), end: CMTime(hour: 4, minute: 10))
            }
        case ._148:
            if !(weekday == 1 || weekday == 7) {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 10, minute: 03), end: CMTime(hour: 15, minute: 00)) || CMTime.isItCurrentlyBetween(start: CMTime(hour: 19, minute: 15), end: CMTime(hour: 6, minute: 00))
            }
        case ._151:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 52), end: CMTime(hour: 4, minute: 20))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 2, minute: 31), end: CMTime(hour: 4, minute: 30))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 2, minute: 22), end: CMTime(hour: 4, minute: 00))
            }
        case ._152:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 23), end: CMTime(hour: 7, minute: 09))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 28), end: CMTime(hour: 5, minute: 14))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 19), end: CMTime(hour: 4, minute: 27))
            }
        case ._155:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 58), end: CMTime(hour: 4, minute: 45))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 59), end: CMTime(hour: 5, minute: 00))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 58), end: CMTime(hour: 5, minute: 20))
            }
        case ._156:
            if !(weekday == 1 || weekday == 7) {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 20, minute: 53), end: CMTime(hour: 5, minute: 15))
            }
        case ._157:
            if !(weekday == 1 || weekday == 7) {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 20, minute: 10), end: CMTime(hour: 5, minute: 23))
            }
        case ._165:
            if !(weekday == 1 || weekday == 7) {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 9, minute: 36), end: CMTime(hour: 14, minute: 43)) || CMTime.isItCurrentlyBetween(start: CMTime(hour: 18, minute: 29), end: CMTime(hour: 5, minute: 41))
            }
        case ._169:
            if !(weekday == 1 || weekday == 7) {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 3, minute: 20), end: CMTime(hour: 8, minute: 27))
                || CMTime.isItCurrentlyBetween(start: CMTime(hour: 10, minute: 37), end: CMTime(hour: 15, minute: 15))
                || CMTime.isItCurrentlyBetween(start: CMTime(hour: 16, minute: 20), end: CMTime(hour: 20, minute: 53))
                || CMTime.isItCurrentlyBetween(start: CMTime(hour: 22, minute: 32), end: CMTime(hour: 2, minute: 34))
            }
        case ._171:
            if weekday != 1 {
                if weekday == 7 {
                    return CMTime.isItCurrentlyBetween(start: CMTime(hour: 18, minute: 32), end: CMTime(hour: 8, minute: 02))
                } else {
                    return CMTime.isItCurrentlyBetween(start: CMTime(hour: 19, minute: 42), end: CMTime(hour: 6, minute: 17))
                }
            }
        case ._172:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 18, minute: 37), end: CMTime(hour: 8, minute: 00))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 18, minute: 37), end: CMTime(hour: 8, minute: 00))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 19, minute: 48), end: CMTime(hour: 6, minute: 15))
            }
        case ._192:
            if !(weekday == 1 || weekday == 7) {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 9, minute: 33), end: CMTime(hour: 15, minute: 45)) || CMTime.isItCurrentlyBetween(start: CMTime(hour: 20, minute: 04), end: CMTime(hour: 6, minute: 00))
            }
        case ._201:
            if weekday != 1 {
                if weekday == 7 {
                    return CMTime.isItCurrentlyBetween(start: CMTime(hour: 19, minute: 58), end: CMTime(hour: 8, minute: 55))
                } else {
                    return CMTime.isItCurrentlyBetween(start: CMTime(hour: 20, minute: 38), end: CMTime(hour: 5, minute: 00))
                }
            }
        case ._206:
            if !(weekday == 1 || weekday == 7) {
                if weekday == 2 {
                    return CMTime.isItCurrentlyBetween(start: CMTime(hour: 8, minute: 31), end: CMTime(hour: 14, minute: 10)) || CMTime.isItCurrentlyBetween(start: CMTime(hour: 17, minute: 01), end: CMTime(hour: 7, minute: 05))
                } else {
                    return CMTime.isItCurrentlyBetween(start: CMTime(hour: 8, minute: 31), end: CMTime(hour: 14, minute: 18)) || CMTime.isItCurrentlyBetween(start: CMTime(hour: 17, minute: 01), end: CMTime(hour: 7, minute: 05))
                }
            }
        }
        return true
    }*/
    
    class func isNightServiceActive(route: CMRoute) -> Bool {
        var weekday = Calendar.current.component(.weekday, from: Date())
        if isHoliday() {
            weekday = 1
        }
        switch route {
        case ._4:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 10), end: CMTime(hour: 5, minute: 01))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 10), end: CMTime(hour: 4, minute: 56))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 10), end: CMTime(hour: 4, minute: 33))
            }
        case ._N5:
            return true
        case ._9:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 16), end: CMTime(hour: 4, minute: 05))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 10), end: CMTime(hour: 4, minute: 07))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 20), end: CMTime(hour: 4, minute: 05))
            }
        case ._20:
            if weekday == 1 || weekday == 7 {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 25), end: CMTime(hour: 5, minute: 46))
            } else {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 25), end: CMTime(hour: 5, minute: 18))
            }
        case ._22:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 00), end: CMTime(hour: 6, minute: 36))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 00), end: CMTime(hour: 5, minute: 56))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 20), end: CMTime(hour: 5, minute: 26))
            }
        case ._34:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 12), end: CMTime(hour: 5, minute: 10))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 02), end: CMTime(hour: 5, minute: 12))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 05), end: CMTime(hour: 5, minute: 25))
            }
        case ._49:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 00), end: CMTime(hour: 5, minute: 34))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 12), end: CMTime(hour: 5, minute: 35))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 00), end: CMTime(hour: 5, minute: 38))
            }
        case ._53:
            return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 26), end: CMTime(hour: 3, minute: 06))
        case ._55:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 14), end: CMTime(hour: 5, minute: 09))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 19), end: CMTime(hour: 5, minute: 18))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 42), end: CMTime(hour: 5, minute: 22))
            }
        case ._60:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 30), end: CMTime(hour: 6, minute: 26))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 30), end: CMTime(hour: 5, minute: 49))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 29), end: CMTime(hour: 5, minute: 55))
            }
        case ._62:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 32), end: CMTime(hour: 4, minute: 58))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 32), end: CMTime(hour: 4, minute: 28))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 32), end: CMTime(hour: 3, minute: 58))
            }
        case ._63:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 00), end: CMTime(hour: 4, minute: 27))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 00), end: CMTime(hour: 4, minute: 25))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 00), end: CMTime(hour: 4, minute: 26))
            }
        case ._66:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 15), end: CMTime(hour: 5, minute: 27))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 15), end: CMTime(hour: 5, minute: 28))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 15), end: CMTime(hour: 5, minute: 31))
            }
        case ._77:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 11), end: CMTime(hour: 4, minute: 26))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 23), end: CMTime(hour: 4, minute: 26))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 2, minute: 02), end: CMTime(hour: 4, minute: 20))
            }
        case ._79:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 30), end: CMTime(hour: 3, minute: 56))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 00), end: CMTime(hour: 4, minute: 18))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 03), end: CMTime(hour: 4, minute: 35))
            }
        case ._81:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 05), end: CMTime(hour: 4, minute: 02))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 05), end: CMTime(hour: 4, minute: 04))
            default:
                return !CMTime.isItCurrentlyBetween(start: CMTime(hour: 4, minute: 00), end: CMTime(hour: 23, minute: 33))
            }
        case ._87:
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 30), end: CMTime(hour: 3, minute: 56))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 15), end: CMTime(hour: 3, minute: 56))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 15), end: CMTime(hour: 3, minute: 56))
            }
        default:
            return false
        }
    }
    
    class private func isHoliday() -> Bool {
        let calendar = Calendar.current
        let today = Date()
        let year = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: today)
        let day = calendar.component(.day, from: today)
        let weekday = calendar.component(.weekday, from: today)

        if month == 1 && day == 1 {
            return true
        }

        if month == 5 && weekday == 2 && (31 - day) < 7 {
            return true
        }

        if month == 7 && day == 4 {
            return true
        }

        if month == 9 && weekday == 2 && day <= 7 {
            return true
        }

        if month == 11 && weekday == 5 && (22...28).contains(day) {
            return true
        }

        if month == 12 && day == 25 {
            return true
        }
        
        let easterDate = calculateEasterDate(year: year)
        if calendar.isDate(today, inSameDayAs: easterDate) {
            return true
        }

        return false
    }

    class private func calculateEasterDate(year: Int) -> Date {
        let a = year % 19
        let b = Int(floor(Double(year) / 100))
        let c = year % 100
        let d = Int(floor(Double(b) / 4))
        let e = b % 4
        let f = Int(floor(Double(b + 8) / 25))
        let g = Int(floor(Double(b - f + 1) / 3))
        let h = (19 * a + b - d - g + 15) % 30
        let i = Int(floor(Double(c) / 4))
        let k = c % 4
        let l = (32 + 2 * e + 2 * i - h - k) % 7
        let m = Int(floor(Double(a + 11 * h + 22 * l) / 451))
        let month = Int(floor(Double(h + l - 7 * m + 114) / 31))
        let day = ((h + l - 7 * m + 114) % 31) + 1

        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day

        return Calendar.current.date(from: dateComponents)!
    }
    
    class private func dorvalCarter() -> Bool {
        let calendar = Calendar.current
        
        var memorialDateComponents = calendar.dateComponents([.year], from: Date())
        memorialDateComponents.month = 5
        memorialDateComponents.day = 31
        
        guard let memorialDay = calendar.date(from: memorialDateComponents),
              let memorialDayWeekend = calendar.date(byAdding: .day, value: -2, to: memorialDay) else {
            return false
        }
        
        var laborDateComponents = calendar.dateComponents([.year], from: Date())
        laborDateComponents.month = 9
        laborDateComponents.day = 1
        
        guard let laborDay = calendar.date(from: laborDateComponents) else {
            return false
        }
        
        return Date() >= memorialDayWeekend && Date() <= laborDay
    }
    
    func storeOverlay() {
        DispatchQueue.global().async {
            var dataDict: [String: [CLLocationCoordinate2D]] = [:]
            
            guard let filePath = Bundle.main.path(forResource: "shapes", ofType: "csv") else {
                return
            }
            
            var rawList = ""
            
            do {
                rawList = try String(contentsOfFile: filePath)
            } catch {
                print(error.localizedDescription)
                return
            }
            
            var rows = rawList.components(separatedBy: "\n")
            rows.removeFirst()
            
            for row in rows {
                let components = row.split(separator: ",")
                
                guard components.count >= 4,
                      let id = components[0] as Substring?,
                      let latitude = Double(components[1]),
                      let longitude = Double(components[2]) else {
                    continue
                }
                
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                let idString = String(id)
                if dataDict[idString] == nil {
                    dataDict[idString] = []
                }
                dataDict[idString]?.append(coordinate)
            }
            DispatchQueue.main.sync {
                self.overlayTable = dataDict
            }
        }
    }
    
    ///Gets information about a given CTA bus stop ID
    func getStopCoordinatesForID(route: CMRoute, direction: String, id: String) -> [String: Any] {
        let baseURL = "http://www.ctabustracker.com/bustime/api/v2/getstops"
        var returnedData: [String: Any] = [:]
        
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "key", value: busTrackerAPIKey),
            URLQueryItem(name: "rt", value: route.apiRepresentation()),
            URLQueryItem(name: "dir", value: direction)
        ]
        
        contactDowntown(components: components) { result in
            returnedData = result
            self.semaphore.signal()
        }
        semaphore.wait()
        return returnedData
    }
    
    ///Gets the location of a CTA bus from its ID
    func getLocationForVehicleId(id: String) -> CLLocationCoordinate2D {
        let baseURL = "http://www.ctabustracker.com/bustime/api/v2/getvehicles"
        var returnedData: [String: Any] = [:]
        
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "key", value: busTrackerAPIKey),
            URLQueryItem(name: "vid", value: id)
        ]
        
        contactDowntown(components: components) { result in
            returnedData = result
            self.semaphore.signal()
        }
        semaphore.wait()
        
        if let root = returnedData["bustime-response"] as? [String: Any], let vehicles = root["vehicle"] as? [[String: Any]], let latitudeString = vehicles[0]["lat"] as? String, let longitudeString = vehicles[0]["lon"] as? String, let latitude = Double(latitudeString), let longitude = Double(longitudeString) {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        return CLLocationCoordinate2D(latitude: -4, longitude: -4)
    }
    
    ///Gets a list of every vehicle on a given CTA bus route
    func getVehiclesForRoute(route: CMRoute) -> [String: Any] {
        let baseURL = "http://www.ctabustracker.com/bustime/api/v2/getvehicles"
        var returnedData: [String: Any] = [:]
        
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "key", value: busTrackerAPIKey),
            URLQueryItem(name: "rt", value: route.apiRepresentation())
        ]
        
        contactDowntown(components: components) { result in
            returnedData = result
            self.semaphore.signal()
        }
        semaphore.wait()
        return returnedData
    }
    
    ///Gets a list of every stop prediction for a given vehicle ID
    func getPredictionsForVehicle(route: CMRoute, vehicleId: String) -> [String: Any] {
        let baseURL = "http://www.ctabustracker.com/bustime/api/v2/getpredictions"
        var returnedData: [String: Any] = [:]
        
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "key", value: busTrackerAPIKey),
            URLQueryItem(name: "rt", value: route.apiRepresentation()),
            URLQueryItem(name: "vid", value: vehicleId)
        ]
        
        contactDowntown(components: components) { result in
            returnedData = result
            self.semaphore.signal()
        }
        semaphore.wait()
        return returnedData
    }
    
    private func contactDowntown(components: URLComponents?, completion: @escaping ([String: Any]) -> Void) {
        var conponents = components
        conponents?.queryItems?.append(URLQueryItem(name: "format", value: "json"))
        
        guard let url = conponents?.url else {
            completion(["Error": "Invalid URL"])
            return
        }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            if let error = error {
                completion(["Error": "Request failed: \(error.localizedDescription)"])
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 502 {
                    completion(["destNm": "Error", "lat":"Unable to get predictions"])
                } else if response.statusCode == 503 {
                    completion(["destNm": "Error", "lat":"Run has no predictions"])
                }
            }
            
            guard let data = data else {
                completion(["Error": "No data received"])
                return
            }
            
            do {
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? ["Error": "Invalid JSON"]
                completion(jsonResult)
            } catch {
                completion(["Error": "JSON parsing failed: \(error.localizedDescription)"])
            }
        }
        
        task.resume()
    }
}
