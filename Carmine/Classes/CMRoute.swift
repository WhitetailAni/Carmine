//
//  CRRoute.swift
//  Carmine
//
//  Created by WhitetailAni on 9/2/24.
//



import Foundation
import AppKit

struct CMRoute: Codable {
    public var number: String
    public var name: String
    @NSColorCodable public var textColor: NSColor
    @NSColorCodable public var bgColor: NSColor
    
    static var deadhead = CMRoute(number: "0", name: "Deadhead", textColor: NSColor.white, bgColor: NSColor.black)
    static var n5 = CMRoute(number: "N5", name: "South Shore Night Bus", textColor: NSColor.white, bgColor: NSColor(r: 0, g: 153, b: 153))
    static var newNumberOrder = ["20", "66", "126", "70", "72", "7", "73", "74", "76", "77", "152", "12", "80", "78", "81", "81W", "92", "84", "18", "155", "96", "21", "60", "31", "15", "J14", "28", "35", "4", "X4", "3", "34", "39", "29", "156", "24", "43", "8", "8A", "108", "151", "44", "47", "9", "X9", "50", "48", "49", "49B", "X49", "51", "93", "94","52", "52A", "82","53", "53A", "55", "55A", "55N", "54", "54A", "54B", "57", "59", "85", "85A", "91", "63", "63W", "86", "165", "90", "67", "71", "75", "N5", "79", "36", "147", "22", "11", "37", "56", "68", "88", "65", "87", "156", "62", "30", "95", "106", "103", "111", "112", "115", "119", "136", "146", "148", "135", "134", "2", "6", "26", "192", "125", "120", "121", "19", "10", "130", "124", "1", "100", "172", "171", "111A", "201", "206", "97"]
    
    nonisolated(unsafe) static var defaultColor: NSColor = NSColor(r: 107, g: 160, b: 227)
    
    static func createCMRouteFromData(data: Data) -> CMRoute? {
        guard data.count == MemoryLayout<CMRoute>.size else { return nil }
        
        var route: CMRoute?
        data.withUnsafeBytes { rawBufferPointer in
            if let baseAddress = rawBufferPointer.baseAddress {
                route = baseAddress.load(as: CMRoute.self)
            }
        }
        return route
    }
    
    static func getCMRouteFromString(string: String) -> CMRoute? {
        for route in ChicagoTransitInterface().getRoutes() {
            var routeString = route.number
            if String(routeString) == string {
                return route
            }
        }
        return nil
    }
    
    func textualRepresentation(addRouteNumber: Bool = false, useNewNames: Bool, useNewNumbers: Bool) -> String {
        var addNumber = ""
        var nightVal = ""
        if addRouteNumber {
            addNumber = routeNumber(useNewNumber: useNewNumbers)
        }
        if CMRoute.isNightServiceActive(routeNumber: self.number) && self.number != "N5" {
            nightVal = " Night"
        }
        if useNewNames {
            switch self.number {
            case "15":
                return addNumber + " Jeffery/51st"
            case "18":
                return addNumber + " 16th-18th"
            case "35":
                return addNumber + " 31st-35th"
            case "44":
                return addNumber + " Wallace-Racine"
            case "54A":
                return addNumber + " North Cicero-Skokie Blvd."
            case "60":
                return addNumber + " Blue Island-26th" + nightVal
            case "72":
                return addNumber + " North Avenue"
            case "86":
                return addNumber + " Narragansett-Ridgeland"
            case "93":
                return addNumber + " California-Dodge"
            case "111":
                return addNumber + " King Drive/111th"
            case "115":
                return addNumber + " Cottage Grove/115th"
            case "146":
                return "146 Inner Lake Shore/Michigan Express"
            case "147":
                return "147 Outer DuSable Lake Shore Express"
            case "157":
                return addNumber + " Streeterville/Ogden-Taylor"
            case "171":
                return addNumber + " University of Chicago/Hyde Park"
            case "172":
                return addNumber + " University of Chicago/Kenwood"
            case "192":
                return addNumber + " University of Chicago Hospitals Express"
            default:
                return addNumber + " " + self.name + nightVal
            }
        }
        switch self.number {
        case "146":
            return "146 Inner Lake Shore/Michigan Express"
        case "147":
            return "147 Outer DuSable Lake Shore Express"
        default:
            return addNumber + " " + self.name + nightVal
        }
    }
    
    func apiRepresentation() -> String {
        return routeNumber(addNightOwl: false)
    }
    
    func routeNumber(addNightOwl: Bool = true, useNewNumber: Bool = false) -> String {
        if useNewNumber {
            var nightVal = ""
            if addNightOwl && CMRoute.isNightServiceActive(routeNumber: self.number) && self.number != "N5" {
                nightVal = "N"
            }
            switch self.number {
            case "1":
                return "142"
            case "2":
                return "126"
            case "3":
                return "37"
            case "4":
                return nightVal + "36"
            case "X4":
                return "L36"
            case "N5":
                return "N78"
            case "6":
                return "X127"
            case "7":
                return "6"
            case "8":
                return "44"
            case "8A":
                return "44S"
            case "9":
                return nightVal + "48"
            case "X9":
                return "L48"
            case "10":
                return "135"
            case "11":
                return "82A"
            case "J14":
                return "J33"
            case "15":
                return "33"
            case "18":
                return "18"
            case "19":
                return "X133"
            case "20":
                return nightVal + "1"
            case "21":
                return "22"
            case "22":
                return nightVal + "81"
            case "24":
                return "42"
            case "26":
                return "X128"
            case "28":
                return "34"
            case "29":
                return "40"
            case "30":
                return "91"
            case "34":
                return nightVal + "38"
            case "36":
                return "80"
            case "37":
                return "82B"
            case "39":
                return "39"
            case "44":
                return "46"
            case "48":
                return "49S"
            case "49":
                return nightVal + "50"
            case "49B":
                return "50N"
            case "X49":
                return "L50"
            case "50":
                return "49"
            case "52":
                return "53"
            case "52A":
                return "53S"
            case "53":
                return nightVal + "56"
            case "53A":
                return "56S"
            case "54":
                return "58"
            case "54A":
                return "58N"
            case "54B":
                return "58S"
            case "56":
                return "83"
            case "57":
                return "60"
            case "60":
                return nightVal + "26"
            case "62":
                return nightVal + "89"
            case "62H":
                return "89H"
            case "63":
                return nightVal + "63"
            case "63W":
                return "83W"
            case "65":
                return "86"
            case "66":
                return nightVal + "2"
            case "67":
                return "69"
            case "68":
                return "84"
            case "70":
                return "4"
            case "72":
                return "5"
            case "73":
                return "7"
            case "74":
                return "8"
            case "76":
                return "9"
            case "77":
                return nightVal + "10"
            case "78":
                return "14"
            case "79":
                return nightVal + "79"
            case "80":
                return "13"
            case "81":
                return nightVal + "15"
            case "81W":
                return "15W"
            case "82":
                return "54"
            case "84":
                return "17"
            case "85":
                return "61"
            case "85A":
                return "61N"
            case "86":
                return "64"
            case "87":
                return "87"
            case "88":
                return "85"
            case "90":
                return "66"
            case "91":
                return "62"
            case "92":
                return "16"
            case "93":
                return "52A"
            case "94":
                return "52B"
            case "96":
                return "20"
            case "97":
                return "149"
            case "100":
                return "X143"
            case "103":
                return "103W"
            case "106":
                return "103E"
            case "108":
                return "42B"
            case "111":
                return "111A"
            case "111A":
                return "146"
            case "112":
                return "111B"
            case "120":
                return "X131"
            case "121":
                return "X132"
            case "124":
                return "141"
            case "125":
                return "X130"
            case "126":
                return "3"
            case "130":
                return "140"
            case "134":
                return "X124"
            case "135":
                return "X123"
            case "136":
                return "X120"
            case "143":
                return "X124B"
            case "146":
                return "X121"
            case "147":
                return "J80"
            case "148":
                return "X122"
            case "151":
                return "45"
            case "152":
                return "11"
            case "155":
                return "19"
            case "156":
                return "41"
            case "157":
                return "88"
            case "165":
                return "65"
            case "169":
                return "X169"
            case "171":
                return "145"
            case "172":
                return "144"
            case "192":
                return "X129"
            case "201":
                return "147"
            case "206":
                return "148"
            default:
                if addNightOwl && CMRoute.isNightServiceActive(routeNumber: self.number) {
                    return "N" + self.number
                } else {
                    return self.number
                }
            }
        }
        if addNightOwl && CMRoute.isNightServiceActive(routeNumber: self.number) && self.number != "N5" {
            return "N" + self.number
        } else {
            return self.number
        }
    }
    
    public static func colors(number: String) -> (background: NSColor, text: NSColor) {
        switch number {
        case "1", "48", "54A", "55A", "108", "130", "165", "206":
            return (NSColor.white, NSColor(r: 87, g: 88, b: 90)) //white background gray text
        case "2", "10", "26", "100", "120", "121", "125", "135", "136", "143", "148", "169", "192":
            return (NSColor.white, NSColor(r: 183, g: 17, b: 52)) //white background red text
        case "X4", "X9", "X49":
            return (NSColor.white, NSColor(r: 1, g: 160, b: 120)) //white background green text
        case "N5":
            return (NSColor.white, NSColor(r: 0, g: 153, b: 153)) //white background bluegreen text
        case "6", "146", "147":
            return (NSColor(r: 183, g: 17, b: 52), NSColor.white) //red background white text
        case "J14":
            return (NSColor(r: 1, g: 101, b: 189), NSColor.white) //blue background white text (J14 only)
        case "19/*", "128*/":
            return (NSColor.white, NSColor.black) //white background black text, for express buses
        case "4", "9", "20", "22", "34", "49", "53", "55", "60", "62", "63", "66", "77", "79", "81", "87":
            if CMRoute.isNightServiceActive(routeNumber: number) {
                return (NSColor(r: 0, g: 153, b: 153), NSColor.white) //white background bluegreen text
            }
            switch number {
            case "34", "60", "63", "79", "4", "20", "49", "66", "53", "55", "77", "9", "81":
                return (NSColor(r: 65, g: 65, b: 69), NSColor.white) //frequent network white text
            default:
                return (NSColor(r: 87, g: 88, b: 90), NSColor.white)
            }
        case "47", "54", "95", "82://", "12", "72":
            return (NSColor(r: 65, g: 65, b: 69), NSColor.white)
        case "19":
            return (NSColor.white, NSColor.black)
        default:
            return (NSColor(r: 87, g: 88, b: 90), NSColor.white) //gray background white text
        }
    }
    
    func glyphs() -> [NSImage]? {
        let nightOwl = NSImage(named: "nightOwl")!
        let jump = NSImage(named: "jump")!
        let loopLink = NSImage(named: "loopLink")!
        let freqNetwork = NSImage(named: "frequentNetwork")!
        
        var imageArray: [NSImage] = []
        
        switch self.number {
        case "N5", "9", "22", "62", "81", "87":
            imageArray = [nightOwl]
        case "34", "63", "79", "4", "49", "66", "53", "55", "77"/*, "9", "81"*/:
            imageArray = [nightOwl, freqNetwork]
        case "20", "60":
            imageArray = [nightOwl, freqNetwork, loopLink]
        case "47", "54", "95", "82"/*, "12", "72"*/:
            imageArray = [freqNetwork]
        case "19", "56", "124", "157":
            imageArray = [loopLink]
        case "J14":
            imageArray = [jump, loopLink, freqNetwork]
        default:
            return nil
        }
        
        if ChicagoTransitInterface().getDetoursForRoute(route: self).count > 0 {
            imageArray.append(NSImage(named: "alert")!)
        }
        
        return imageArray
    }
    
    func nightGlyphs() -> [NSImage]? {
        if ["4", "66"].contains(self.number) {
            return [NSImage(named: "loopLink")!]
        }
        return nil
    }
    
    func link() -> URL {
        return URL(string: "https://www.transitchicago.com/bus/\(self.number)")!
    }
    
    static func isNightServiceActive(routeNumber: String) -> Bool {
        var weekday = Calendar.current.component(.weekday, from: Date())
        if ChicagoTransitInterface.isHoliday() {
            weekday = 1
        }
        switch routeNumber {
        case "4":
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 10), end: CMTime(hour: 5, minute: 01))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 10), end: CMTime(hour: 4, minute: 56))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 10), end: CMTime(hour: 4, minute: 33))
            }
        case "N5":
            return true
        case "9":
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 16), end: CMTime(hour: 4, minute: 05))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 10), end: CMTime(hour: 4, minute: 07))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 20), end: CMTime(hour: 4, minute: 05))
            }
        case "20":
            if weekday == 1 || weekday == 7 {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 25), end: CMTime(hour: 5, minute: 46))
            } else {
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 25), end: CMTime(hour: 5, minute: 18))
            }
        case "22":
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 00), end: CMTime(hour: 6, minute: 36))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 00), end: CMTime(hour: 5, minute: 56))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 20), end: CMTime(hour: 5, minute: 26))
            }
        case "34":
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 12), end: CMTime(hour: 5, minute: 10))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 02), end: CMTime(hour: 5, minute: 12))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 05), end: CMTime(hour: 5, minute: 25))
            }
        case "49":
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 00), end: CMTime(hour: 5, minute: 34))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 12), end: CMTime(hour: 5, minute: 35))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 00), end: CMTime(hour: 5, minute: 38))
            }
        case "53":
            return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 26), end: CMTime(hour: 4, minute: 17))
        case "55":
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 14), end: CMTime(hour: 5, minute: 09))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 19), end: CMTime(hour: 5, minute: 18))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 42), end: CMTime(hour: 5, minute: 22))
            }
        case "60":
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 30), end: CMTime(hour: 6, minute: 26))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 30), end: CMTime(hour: 5, minute: 49))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 23, minute: 29), end: CMTime(hour: 5, minute: 55))
            }
        case "62":
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 32), end: CMTime(hour: 4, minute: 58))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 32), end: CMTime(hour: 4, minute: 28))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 32), end: CMTime(hour: 3, minute: 58))
            }
        case "63":
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 00), end: CMTime(hour: 4, minute: 27))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 00), end: CMTime(hour: 4, minute: 25))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 00), end: CMTime(hour: 4, minute: 26))
            }
        case "66":
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 15), end: CMTime(hour: 5, minute: 27))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 15), end: CMTime(hour: 5, minute: 28))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 15), end: CMTime(hour: 5, minute: 31))
            }
        case "77":
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 11), end: CMTime(hour: 4, minute: 26))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 23), end: CMTime(hour: 4, minute: 26))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 2, minute: 02), end: CMTime(hour: 4, minute: 20))
            }
        case "79":
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 30), end: CMTime(hour: 3, minute: 56))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 00), end: CMTime(hour: 4, minute: 18))
            default:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 03), end: CMTime(hour: 4, minute: 35))
            }
        case "81":
            switch weekday {
            case 1:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 05), end: CMTime(hour: 4, minute: 02))
            case 7:
                return CMTime.isItCurrentlyBetween(start: CMTime(hour: 00, minute: 05), end: CMTime(hour: 4, minute: 04))
            default:
                return !CMTime.isItCurrentlyBetween(start: CMTime(hour: 4, minute: 00), end: CMTime(hour: 23, minute: 33))
            }
        case "87":
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
}
