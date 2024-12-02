//
//  CRRoute.swift
//  Carmine
//
//  Created by WhitetailAni on 9/2/24.
//

import Foundation
import AppKit

enum CMRoute: CaseIterable {
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
    case _128
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
    
    func textualRepresentation(addRouteNumber: Bool = false) -> String {
        var addNumber = ""
        if addRouteNumber {
            addNumber = routeNumber() + " "
        }
        switch self {
        case ._1:
            return addNumber + "Bronzeville/Union Station"
        case ._2:
            return addNumber + "Hyde Park Express"
        case ._3:
            return addNumber + "King Drive"
        case ._4:
            return addNumber + "Cottage Grove"
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
            return addNumber + "Ashland"
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
            return addNumber + "Madison"
        case ._21:
            return addNumber + "Cermak"
        case ._22:
            return addNumber + "Clark"
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
            return addNumber + "South Michigan"
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
            return addNumber + "Western"
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
            return addNumber + "Pulaski"
        case ._53A:
            return addNumber + "South Pulaski"
        case ._54:
            return addNumber + "Cicero"
        case ._54A:
            return addNumber + "North Cicero/Skokie Blvd."
        case ._54B:
            return addNumber + "South Cicero"
        case ._55:
            return addNumber + "Garfield"
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
            return addNumber + "Blue Island/26th"
        case ._62:
            return addNumber + "Archer"
        case ._62H:
            return addNumber + "Archer/Harlem"
        case ._63:
            return addNumber + "63rd"
        case ._63W:
            return addNumber + "West 63rd"
        case ._65:
            return addNumber + "Grand"
        case ._66:
            return addNumber + "Chicago"
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
            return addNumber + "Belmont"
        case ._78:
            return addNumber + "Montrose"
        case ._79:
            return addNumber + "79th"
        case ._80:
            return addNumber + "Irving Park"
        case ._81:
            return addNumber + "Lawrence"
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
            return addNumber + "87th"
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
        case ._128:
            return addNumber + "Soldier Field Express"
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
        return routeNumber()
    }
    
    func routeNumber() -> String {
        return String(String(describing: self).dropFirst())
    }
    
    func colors() -> (main: NSColor, accent: NSColor) {
        switch self {
        case ._1, ._48, ._54B, ._55A, ._108, ._165, ._206:
            return (NSColor.white, NSColor(r: 87, g: 88, b: 90)) //white background gray text
        case ._2, ._10, ._26, ._100, ._120, ._121, ._125, ._130, ._135, ._136, ._143, ._148, ._169, ._192:
            return (NSColor.white, NSColor(r: 183, g: 17, b: 52)) //white background red text
        case ._X4, ._X9, ._X49:
            return (NSColor.white, NSColor(r: 1, g: 160, b: 120)) //white background green text
        case ._N5:
            return (NSColor.white, NSColor(r: 0, g: 153, b: 153)) //white background bluegreen text
        case ._6, ._146, ._147:
            return (NSColor(r: 183, g: 17, b: 52), NSColor.white) //red background white text
        case ._J14:
            return (NSColor(r: 1, g: 101, b: 189), NSColor.white) //blue background white text (J14 only)
        case ._19, ._128:
            return (NSColor.white, NSColor.white) //white background black text, for express buses
        case ._4, ._9, ._20, ._22, ._34, ._49, ._53, ._55, ._60, ._62, ._63, ._66, ._77, ._79, ._81, ._87:
            if ChicagoTransitInterface.isNightServiceActive(route: self) {
                return (NSColor.white, NSColor(r: 0, g: 153, b: 153)) //white background bluegreen text
            }
            return (NSColor(r: 87, g: 88, b: 90), NSColor.white)
        default:
            return (NSColor(r: 87, g: 88, b: 90), NSColor.white) //gray background white text
        }
        
    }
    
    func link() -> URL {
        var selfString = String(describing: self).dropFirst()
        if selfString.first == "N" {
            selfString = selfString.dropFirst()
        }
        return URL(string: "https://www.transitchicago.com/bus/\(selfString)")!
    }
}