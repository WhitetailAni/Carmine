//
//  CRRoute.swift
//  Carmine
//
//  Created by WhitetailAni on 9/2/24.
//

import Foundation
import AppKit

enum CMRoute: String, CaseIterable {
    case _1
    case _2
    case _3
    case _4
    case _X4
    case _N5
    case _6
    case _7
    case _8
    case _8A
    case _9
    case _X9
    case _10
    case _11
    case _12
    case _J14
    case _15
    case _18
    case _19
    case _20
    case _21
    case _22
    case _24
    case _26
    case _28
    case _29
    case _30
    case _31
    case _34
    case _35
    case _36
    case _37
    case _39
    case _43
    case _44
    case _47
    case _48
    case _49
    case _49B
    case _X49
    case _50
    case _51
    case _52
    case _52A
    case _53
    case _53A
    case _54
    case _54A
    case _54B
    case _55
    case _55A
    case _55N
    case _56
    case _57
    case _59
    case _60
    case _62
    case _62H
    case _63
    case _63W
    case _65
    case _66
    case _67
    case _68
    case _70
    case _71
    case _72
    case _73
    case _74
    case _75
    case _76
    case _77
    case _78
    case _79
    case _80
    case _81
    case _81W
    case _82
    case _84
    case _85
    case _85A
    case _86
    case _87
    case _88
    case _90
    case _91
    case _92
    case _93
    case _94
    case _95
    case _96
    case _97
    case _100
    case _103
    case _106
    case _108
    case _111
    case _111A
    case _112
    case _115
    case _119
    case _120
    case _121
    case _124
    case _125
    case _126
    case _130
    case _134
    case _135
    case _136
    case _143
    case _146
    case _147
    case _148
    case _151
    case _152
    case _155
    case _156
    case _157
    case _165
    case _169
    case _171
    case _172
    case _192
    case _201
    case _206
    
    nonisolated(unsafe) static var defaultColor: NSColor = NSColor(r: 107, g: 160, b: 227)
    
    //my initial idea was to just make this enum Codable but this is way funnier
    mutating func convertSelfToData() -> Data {
        return Data(bytes: &self, count: MemoryLayout<CMRoute>.size)
    }
    
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
    
    static func createCMRouteFromString(string: String) -> CMRoute? {
        for route in CMRoute.allCases {
            var routeString = route.rawValue.dropFirst(1)
            if route == ._N5 {
                routeString = routeString.dropFirst(1)
            }
            if routeString == string {
                return route
            }
        }
        return nil
    }
    
    func textualRepresentation(addRouteNumber: Bool = false) -> String {
        var addNumber = ""
        var nightVal = ""
        if addRouteNumber {
            addNumber = routeNumber() + " "
        }
        if isNightServiceActive() {
            nightVal = " Night"
        }
        switch self {
        case ._1:
            return addNumber + "Bronzeville/Union Station"
        case ._2:
            return addNumber + "Hyde Park Express"
        case ._3:
            return addNumber + "King Drive"
        case ._4:
            return addNumber + "Cottage Grove" + nightVal
        case ._X4:
            return addNumber + "Cottage Grove Express"
        case ._N5:
            return addNumber + "South Shore Night Bus"
        case ._6:
            return addNumber + "Jackson Park Express"
        case ._7:
            return addNumber + "Harrison"
        case ._8:
            return addNumber + "Halsted"
        case ._8A:
            return addNumber + "South Halsted"
        case ._9:
            return addNumber + "Ashland" + nightVal
        case ._X9:
            return addNumber + "Ashland Express"
        case ._10:
            return addNumber + "Museum of Science and Industry"
        case ._11:
            return addNumber + "Lincoln"
        case ._12:
            return addNumber + "Roosevelt"
        case ._J14:
            return addNumber + "Jeffery Jump"
        case ._15:
            return addNumber + "Jeffery Local"
        case ._18:
            return addNumber + "16th-18th"
        case ._19:
            return addNumber + "United Center Express"
        case ._20:
            return addNumber + "Madison" + nightVal
        case ._21:
            return addNumber + "Cermak"
        case ._22:
            return addNumber + "Clark" + nightVal
        case ._24:
            return addNumber + "Wentworth"
        case ._26:
            return addNumber + "South Shore Express"
        case ._28:
            return addNumber + "Stony Island"
        case ._29:
            return addNumber + "State"
        case ._30:
            return addNumber + "South Chicago"
        case ._31:
            return addNumber + "31st"
        case ._34:
            return addNumber + "South Michigan" + nightVal
        case ._35:
            return addNumber + "31st/35th"
        case ._36:
            return addNumber + "Broadway"
        case ._37:
            return addNumber + "Sedgwick"
        case ._39:
            return addNumber + "Pershing"
        case ._43:
            return addNumber + "43rd"
        case ._44:
            return addNumber + "Wallace/Racine"
        case ._47:
            return addNumber + "47th"
        case ._48:
            return addNumber + "South Damen"
        case ._49:
            return addNumber + "Western" + nightVal
        case ._49B:
            return addNumber + "North Western"
        case ._X49:
            return addNumber + "Western Express"
        case ._50:
            return addNumber + "Damen"
        case ._51:
            return addNumber + "51st"
        case ._52:
            return addNumber + "Kedzie"
        case ._52A:
            return addNumber + "South Kedzie"
        case ._53:
            return addNumber + "Pulaski" + nightVal
        case ._53A:
            return addNumber + "South Pulaski"
        case ._54:
            return addNumber + "Cicero"
        case ._54A:
            return addNumber + "North Cicero/Skokie Blvd."
        case ._54B:
            return addNumber + "South Cicero"
        case ._55:
            return addNumber + "Garfield" + nightVal
        case ._55A:
            return addNumber + "55th/Austin"
        case ._55N:
            return addNumber + "55th/Narragansett"
        case ._56:
            return addNumber + "Milwaukee"
        case ._57:
            return addNumber + "Laramie"
        case ._59:
            return addNumber + "59th/61st"
        case ._60:
            return addNumber + "Blue Island/26th" + nightVal
        case ._62:
            return addNumber + "Archer" + nightVal
        case ._62H:
            return addNumber + "Archer/Harlem"
        case ._63:
            return addNumber + "63rd" + nightVal
        case ._63W:
            return addNumber + "West 63rd"
        case ._65:
            return addNumber + "Grand"
        case ._66:
            return addNumber + "Chicago" + nightVal
        case ._67:
            return addNumber + "67th-69th-71st"
        case ._68:
            return addNumber + "Northwest Highway"
        case ._70:
            return addNumber + "Division"
        case ._71:
            return addNumber + "71st/South Shore"
        case ._72:
            return addNumber + "North"
        case ._73:
            return addNumber + "Armitage"
        case ._74:
            return addNumber + "Fullerton"
        case ._75:
            return addNumber + "74th-75th"
        case ._76:
            return addNumber + "Diversey"
        case ._77:
            return addNumber + "Belmont" + nightVal
        case ._78:
            return addNumber + "Montrose"
        case ._79:
            return addNumber + "79th" + nightVal
        case ._80:
            return addNumber + "Irving Park"
        case ._81:
            return addNumber + "Lawrence" + nightVal
        case ._81W:
            return addNumber + "West Lawrence"
        case ._82:
            return addNumber + "Kimball-Homan"
        case ._84:
            return addNumber + "Peterson"
        case ._85:
            return addNumber + "Central"
        case ._85A:
            return addNumber + "North Central"
        case ._86:
            return addNumber + "Narragansett/Ridgeland"
        case ._87:
            return addNumber + "87th" + nightVal
        case ._88:
            return addNumber + "Higgins"
        case ._90:
            return addNumber + "Harlem"
        case ._91:
            return addNumber + "Austin"
        case ._92:
            return addNumber + "Foster"
        case ._93:
            return addNumber + "California/Dodge"
        case ._94:
            return addNumber + "California"
        case ._95:
            return addNumber + "95th"
        case ._96:
            return addNumber + "Lunt"
        case ._97:
            return addNumber + "Skokie"
        case ._100:
            return addNumber + "Jeffery Manor Express"
        case ._103:
            return addNumber + "West 103rd"
        case ._106:
            return addNumber + "East 103rd"
        case ._108:
            return addNumber + "Halsted/95th"
        case ._111:
            return addNumber + "111th/King Drive"
        case ._111A:
            return addNumber + "Pullman Shuttle"
        case ._112:
            return addNumber + "Vincennes/111th"
        case ._115:
            return addNumber + "Pullman/115th"
        case ._119:
            return addNumber + "Michigan/119th"
        case ._120:
            return addNumber + "Ogilvie/Streeterville Express"
        case ._121:
            return addNumber + "Union/Streeterville Express"
        case ._124:
            return addNumber + "Navy Pier"
        case ._125:
            return addNumber + "Water Tower Express"
        case ._126:
            return addNumber + "Jackson"
        /*case ._128:
            return addNumber + "Soldier Field Express"*/
        case ._130:
            return addNumber + "Museum Campus"
        case ._134:
            return addNumber + "Stockton/LaSalle Express"
        case ._135:
            return addNumber + "Clarendon/LaSalle Express"
        case ._136:
            return addNumber + "Sheridan/LaSalle Express"
        case ._143:
            return addNumber + "Stockton/Michigan Express"
        case ._146:
            return addNumber + "Inner Lake Shore/Michigan Express"
        case ._147:
            return addNumber + "Outer DuSable Lake Shore Express"
        case ._148:
            return addNumber + "Clarendon/Michigan Express"
        case ._151:
            return addNumber + "Sheridan"
        case ._152:
            return addNumber + "Addison"
        case ._155:
            return addNumber + "Devon"
        case ._156:
            return addNumber + "LaSalle"
        case ._157:
            return addNumber + "Streeterville/Taylor"
        case ._165:
            return addNumber + "West 65th"
        case ._169:
            return addNumber + "69th/UPS Express"
        case ._171:
            return addNumber + "U. of Chicago/Hyde Park"
        case ._172:
            return addNumber + "U. of Chicago/Kenwood"
        case ._192:
            return addNumber + "U. of Chicago Hospitals Express"
        case ._201:
            return addNumber + "Central/Ridge"
        case ._206:
            return addNumber + "Evanston Circulator"
        }
    }
    
    func apiRepresentation() -> String {
        var number = routeNumber(addNightOwl: false)
        if self == ._N5 {
            number = String(number.dropFirst(1))
        }
        return number
    }
    
    func routeNumber(addNightOwl: Bool = true, useNewNumber: Bool = false) -> String {
        if useNewNumber {
            switch self {
            case ._1:
                return "133"
            case ._2:
                return "126"
            case ._3:
                return "37"
            case ._4:
                return "36"
            case ._X4:
                return "X36"
            case ._N5:
                return "N78"
            case ._6:
                return "127"
            case ._7:
                return "6"
            case ._8:
                return "44"
            case ._8A:
                return "44S"
            case ._9:
                return "48"
            case ._X9:
                return "X48"
            case ._10:
                return "136"
            case ._11:
                return "82A"
            case ._J14:
                return "J33"
            case ._15:
                return "33"
            case ._18:
                return "18"
            case ._19:
                return "135"
            case ._20:
                return "1"
            case ._21:
                return "22"
            case ._22:
                return "81"
            case ._24:
                return "42"
            case ._26:
                return "128"
            case ._28:
                return "34"
            case ._29:
                return "40"
            case ._30:
                return "91"
            case ._34:
                return "39"
            case ._36:
                return "80"
            case ._37:
                return "82B"
            case ._39:
                return "38"
            case ._44:
                return "46"
            case ._48:
                return "49S"
            case ._49:
                return "50"
            case ._49B:
                return "50N"
            case ._X49:
                return "X50"
            case ._50:
                return "49"
            case ._52:
                return "53"
            case ._52A:
                return "53S"
            case ._53:
                return "54"
            case ._53A:
                return "54S"
            case ._54:
                return "57"
            case ._54A:
                return "57N"
            case ._54B:
                return "57S"
            case ._56:
                return "83"
            case ._57:
                return "58"
            case ._60:
                return "26"
            case ._62:
                return "89"
            case ._62H:
                return "89H"
            case ._63:
                return "63"
            case ._63W:
                return "83W"
            case ._65:
                return "86"
            case ._66:
                return "2"
            case ._67:
                return "69"
            case ._68:
                return "84"
            case ._70:
                return "4"
            case ._72:
                return "5"
            case ._73:
                return "7"
            case ._74:
                return "8"
            case ._76:
                return "9"
            case ._77:
                return "10"
            case ._78:
                return "14"
            case ._79:
                return "79"
            case ._80:
                return "13"
            case ._81:
                return "15"
            case ._81W:
                return "15W"
            case ._82:
                return "52"
            case ._84:
                return "17"
            case ._85:
                return "60"
            case ._85A:
                return "60N"
            case ._86:
                return "62"
            case ._87:
                return "87"
            case ._88:
                return "85"
            case ._90:
                return "64"
            case ._91:
                return "61"
            case ._92:
                return "16"
            case ._93:
                return "52A"
            case ._94:
                return "52B"
            case ._96:
                return "20"
            case ._97:
                return "140"
            case ._100:
                return "143"
            case ._103:
                return "103W"
            case ._106:
                return "103E"
            case ._108:
                return "42B"
            case ._111:
                return "111A"
            case ._111A:
                return "144"
            case ._112:
                return "111B"
            case ._120:
                return "132A"
            case ._121:
                return "132B"
            case ._124:
                return "131"
            case ._125:
                return "130"
            case ._126:
                return "3"
            case ._130:
                return "134"
            case ._134:
                return "125"
            case ._135:
                return "124"
            case ._136:
                return "121"
            case ._143:
                return "125B"
            case ._146:
                return "122"
            case ._147:
                return "120"
            case ._148:
                return "123"
            case ._151:
                return "45"
            case ._152:
                return "11"
            case ._155:
                return "19"
            case ._156:
                return "41"
            case ._157:
                return "88"
            case ._165:
                return "65"
            case ._171:
                return "142"
            case ._172:
                return "141"
            case ._192:
                return "129"
            default:
                return String(String(describing: self).dropFirst())
            }
        }
        if addNightOwl && isNightServiceActive() && self != ._N5 {
            let string = ("N" + String(String(describing: self).dropFirst()))
            return string
        } else {
            return String(String(describing: self).dropFirst())
        }
    }
    
    func colors() -> (main: NSColor, accent: NSColor) {
        switch self {
        case ._1, ._48, ._54A, ._55A, ._108, ._130, ._165, ._206:
            return (NSColor.white, NSColor(r: 87, g: 88, b: 90)) //white background gray text
        case ._2, ._10, ._26, ._100, ._120, ._121, ._125, ._135, ._136, ._143, ._148, ._169, ._192:
            return (NSColor.white, NSColor(r: 183, g: 17, b: 52)) //white background red text
        case ._X4, ._X9, ._X49:
            return (NSColor.white, NSColor(r: 1, g: 160, b: 120)) //white background green text
        case ._N5:
            return (NSColor.white, NSColor(r: 0, g: 153, b: 153)) //white background bluegreen text
        case ._6, ._146, ._147:
            return (NSColor(r: 183, g: 17, b: 52), NSColor.white) //red background white text
        case ._J14:
            return (NSColor(r: 1, g: 101, b: 189), NSColor.white) //blue background white text (J14 only)
        case ._19/*, ._128*/:
            return (NSColor.white, NSColor.black) //white background black text, for express buses
        case ._4, ._9, ._20, ._22, ._34, ._49, ._53, ._55, ._60, ._62, ._63, ._66, ._77, ._79, ._81, ._87:
            if isNightServiceActive() {
                return (NSColor(r: 0, g: 153, b: 153), NSColor.white) //white background bluegreen text
            }
            switch self {
            case ._34, ._60, ._63, ._79, ._4, ._20, ._49, ._66, ._53, ._55, ._77, ._9, ._81:
                return (NSColor(r: 65, g: 65, b: 69), NSColor.white) //frequent network white text
            default:
                return (NSColor(r: 87, g: 88, b: 90), NSColor.white)
            }
        case ._47, ._54, ._95, ._82://, ._12, ._72
            return (NSColor(r: 65, g: 65, b: 69), NSColor.white)
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
        
        switch self {
        case ._N5, ._9, ._22, ._62, ._81, ._87:
            imageArray = [nightOwl]
        case ._34, ._63, ._79, ._4, ._49, ._66, ._53, ._55, ._77/*, ._9, _81*/:
            imageArray = [nightOwl, freqNetwork]
        case ._20, ._60:
            imageArray = [nightOwl, freqNetwork, loopLink]
        case ._47, ._54, ._95, ._82/*, ._12, ._72*/:
            imageArray = [freqNetwork]
        case ._19, ._56, ._124, ._157:
            imageArray = [loopLink]
        case ._J14:
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
        if [._4, ._66].contains(self) {
            return [NSImage(named: "loopLink")!]
        }
        return nil
    }
    
    func link() -> URL {
        var selfString = String(describing: self).dropFirst()
        if selfString.first == "N" {
            selfString = selfString.dropFirst()
        }
        return URL(string: "https://www.transitchicago.com/bus/\(selfString)")!
    }
    
    static func isNightBus(route: CMRoute, destination: String) -> Bool {
        switch route {
        case ._4, ._9:
            if ["95th Red Line", "North/Clark"].contains(destination) {
                return true
            }
        case ._77:
            if destination == "Harlem" {
                return true
            }
        default:
            return false
        }
        return false
    }
    
    func isNightServiceActive() -> Bool {
        var weekday = Calendar.current.component(.weekday, from: Date())
        if ChicagoTransitInterface.isHoliday() {
            weekday = 1
        }
        switch self {
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
            return CMTime.isItCurrentlyBetween(start: CMTime(hour: 1, minute: 26), end: CMTime(hour: 4, minute: 17))
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
}
