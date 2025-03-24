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
    
    func textualRepresentation(addRouteNumber: Bool = false) -> String {
        var addNumber = ""
        var nightVal = ""
        if addRouteNumber {
            addNumber = routeNumber() + " "
            if ChicagoTransitInterface.isNightServiceActive(route: self) {
                addNumber = "N" + routeNumber() + " "
            }
        }
        if ChicagoTransitInterface.isNightServiceActive(route: self) {
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
    
    func gtfsKey(n5: Bool = false) -> [Int] {
        switch self {
        case ._1:
            return [66808085, //35th indiana to greyhound
                    66808084, //35th indiana to union
                    66806351] //greyhound to 34th michigan
        case ._2:
            if CMTime.isItCurrentlyBetween(start: CMTime(hour: 5, minute: 30), end: CMTime(hour: 10, minute: 30)) {
                return [66805530, //northbound AM
                        66805529] //southbound AM
            }
            return [66805531, //northbound PM
                    66805528] //southbound PM
        case ._3:
            return [66818414, //northbound full
                    66801054, //saturday 79th orig northbound
                    66818415, //southbound full
                    66818417, //weekday cermak orig southbound
                    66819388, //79th orig southbound?
                    66818416, //31st orig southbound?
                    66807770, //31st-79th?
                    66818412, //35th orig southbound?
                    66818413] //25th orig southbound?
        case ._4:
            return [66819378, //115th northboundx
                    66819383, //95th northbound
                    66819382, //95th northbound + loop detour
                    66802642, //N4 northbound
                    66820422, //79th orig northbound
                    66808130, //44th top half
                    66807388, //63rd orig northbound
                    66819379, //115th southbound
                    66819380, //95th southbound
                    66819384, //95th southbound + loop detour
                    66810928, //N4 southbound
                    66819381, //115th southbound loop
                    66808129] //95th to 44th
        case ._X4:
            return [66819372, //95th northbound
                    66819373, //79th northbound
                    66819374] //southbound
        case ._N5:
            return [66812428, //southbound
                    66812429] //northbound
        case ._6:
            return [66814134, //northbound
                    66807107] //southbound
        case ._7:
            return [66804361, //central eastbound
                    66804362, //kedzie eastbound
                    66814107, //central->kedzie eastbound
                    66806522, //leamington->union
                    66803626, //kedzie->central westbound
                    66805912, //central westbound
                    66805911] //kedzie westbound
        case ._8:
            return [66809376, //full length northbound
                    66808388, //79th->root northbound
                    66810949, //root->waveland northbound
                    66809250, //north branch northbound
                    66810954, //root->north branch northbound
                    66808957, //79th->madison northbound
                    66809368, //full length southbound
                    66809345, //waveland->root southbound
                    66810951, //division->79th southbound (north branch other half)
                    66809344, //madison->root southbound
                    66809343, //division->root southbound
                    66808959] //madison->79th southbound
        case ._8A:
            return [66807129, //127th northbound
                    66807131, //120th northbound
                    66807128, //127th southbound
                    66807130, //vincennes southbound
                    66807127] //120th southbound
        case ._9:
            return [66809371,
                    66801763,
                    66804680,
                    66803637,
                    66809372,
                    66809370,
                    66800582,
                    66803639,
                    66825897,
                    66800593,
                    66809373,
                    66809717,
                    66809889,
                    66803634,
                    66809718,
                    66809375,
                    66801748,
                    66809794,
                    66803635,
                    66825896]
        case ._X9:
            return [66808469, //74th northbound
                    66808470, //95th northbound
                    66815955, //74th southbound
                    66804658, //95th southbound
                    66809803] //95th southbound
            
        #warning("10 overlay not in data, extract separately")
        case ._10:
            return []
        case ._11:
            return [66807171, //northbound
                    66807170] //southbound
        case ._12:
            return [66804135, //eastbound
                    66807172,
                    66803879,
                    66807471,
                    66803881,
                    66807532,
                    66803883,
                    66806602] //15th->kedzie westbound
        case ._J14:
            return [66804276, //northbound
                    66804277, //madison northbound
                    //66807173, //idk + idc
                    66804278, //93rd->madison northbound
                    66804275, //southbound
                    66804274] //93rd southbound
        case ._15:
            return [66804288, //northbound
                    66804531, //blackstone northbound
                    66823278, //63rd->103rd southbound
                    66804530, //anthony northbound
                    66804287, //southbound
                    66823279] //103rd->63rd northbound
        case ._18:
            return [66803916, //eastbound
                    66803915, //kedzie eastbound
                    66800941, //47th->kedzie westbound
                    66800940, //kedzie->47th eastbound
                    66803918] //westbound
        case ._19:
            return [] //will never be used
        case ._20:
            return [66802063, 66800957, 66800956, 66800951, 66802062, 66800959, 66825888, 66800947, 66800949, 66800954, 66804096, 66804095, 66800953]
        case ._21:
            return [66804555, 66805021, 66804554, 66807534, 66814129, 66804557, 66804556, 66821484, 66805019, 66805020]
        case ._22:
            return [66803932, 66800246, 66805725, 66803936, 66803935, 66803929, 66805422]
        case ._24:
            return [66806772, 66806775, 66801009, 66807454, 66809653, 66806771, 66806778, 66806779, 66806776, 66806773, 66806777, 66807007]
        case ._26:
            return [66808121, //northbound
                    //66808120, //useless
                    66808119] //southbound
        case ._28:
            return [66810941, 66802162, 66823276, 66808123, 66808122, 66802156, 66810931, 66806643, 66803937, 66802823, 66823277, 66808380]
        case ._29:
            return [66801039, //northbound
                    66801042] //southbound
        case ._30:
            return [66808384, 66808228, 66808383, 66808382, 66808227, 66807901, 66808226, 66807904, 66808381, 66801070]
        case ._31:
            return [66808128, //eastbound
                    66808127, //sox-35th eastbound
                    66808125, //westbound
                    66808124] //sox-35th westbound
        case ._34:
            return [66810916, //gardens southbound
                    66804561, //gardens + carver southbound
                    66801093, //carver southbound
                    66810934, //gardens northbound
                    //66800420, //??
                    66804563, //gardens->corliss hs northbound
                    66802673] //carver + gardens northbound
        case ._35:
            return [66807104, 66807100, 66807105, 66807103, 66807101, 66807102, 66807387, 66806455]
        case ._36:
            return [66805907, //full length northbound
                    //66805906, //useless
                    66805905, //northbound
                    66805901] //foster southbound
        case ._37:
            return [66807175, //northbound
                    66807174] //southbound
        case ._39:
            return [66807556, //eastbound
                    66807555] //westbound
        case ._43:
            return [66808179, //eastbound
                    66807010, //47th eastbound
                    66808180, //westbound
                    66807012] //47th westbound
        case ._44:
            return [66807014, //northbound
                    66801145, //74th northbound
                    66807015, //southbound
                    66801144] //74th southbound
        case ._47:
            return [66806126, //eastbound
                    66802402, //kedzie->metra eastbound
                    66803449, //ashland->metra eastbound
                    66806125, //midway->ashland eastbound
                    66802404, //metra->kedzie westbound
                    66806128, //westbound
                    66806127] //ashland->midway westbound
        case ._48:
            return [66807804, //northbound
                    66801168, //74th->87th southbound
                    66807016, //74th->western northbound
                    66801166, //87th->74th northbound
                    66807805, //southbound
                    66807018] //western->74th southbound
        case ._49:
            return [66801180, //northbound
                    66801175, //division northbound
                    //66809379, //identical to 1178
                    66801178] //southbound
        case ._49B:
            return [66801187, //western brown->foster northbound
                    66804107, //northbound
                    66804106, //foster->howard northbound
                    66804108, //southbound
                    66801184] //foster->western brown southbound
        case ._X49:
            return [66807873, //northbound
                    //66809808, //identical to 7871
                    66807871] //southbound
        case ._50:
            return [66801192, //northbound
                    66814126, //jackson northbound
                    66801151, //southbound
                    66807389, //adams southbound
                    66814127, //jackson southbound
                    //66810920, //southbound copy
                    66801190] //foster southbound
        case ._51:
            return [66807021, //eastbound
                    66807020] //westbound
        case ._52:
            return [66814117,
                    66804718,
                    66814122,
                    66814121,
                    66814120,
                    66814128,
                    66804720]
        case ._52A:
            return [66807458, //northbound
                    66807457, //79th northbound
                    66807456, //southbound
                    66807455] //79th southbound
        case ._53:
            return [66801228,
                    66807210,
                    66808234,
                    66808232,
                    66801234,
                    66808233,
                    66802165,
                    66825889,
                    66803208,
                    66803207,
                    66819390,
                    66801232,
                    66810923,
                    66808230,
                    66801231,
                    66808235,
                    66815022,
                    66801235,
                    66804466,
                    66808231,
                    66803954,
                    66803953]
        case ._53A:
            return [66809247, 66800845, 66804579, 66804577, 66803470, 66803469, 66808386, 66803474, 66804570, 66803464, 66803463, 66803467, 66804571, 66803466, 66808385, 66804582, 66804573]
        case ._54:
            return [66804588, //northbound
                    66804586, //chicago->montrose northbound
                    66804587, //24th->chicago northbound
                    66804585, //chicago->24th southbound
                    66804590, //southbound
                    66804589] //montrose->chicago southbound
        case ._54A:
            return [66801274, //northbound
                    66801275, //southbound
                    66804335] //skokie courthouse -> yellow line
        case ._54B:
            return [66801277, //southbound
                    66804729, //dart northbound
                    66819400, //midway orig southbound
                    66801286, //northbound
                    66804726] //dart southbound
        case ._55:
            return [66805424, 66801299, 66801300, 66801298, 66807735, 66805029, 66803751, 66820424, 66805425, 66801293, 66801295, 66805426, 66801291, 66819392]
        case ._55A:
            return [66804665, //eastbound
                    66804663] //westbound
        case ._55N:
            return [66804664, //westbound
                    66804662] //eastbound
        case ._56:
            return [66801970, //full length northbound
                    66808695, //michigan->washington westbound??
                    66801315, //kedzie->jefferson park northbound
                    66801971, //full length southbound
                    66806485, //addison->canal southbound
                    66801316] //jefferson park->kedzie southbound
        case ._57:
            return [66801328, //northbound
                    66808414, //chicago northbound
                    66801329, //school trip (ignore)
                    66801326, //southbound
                    66808415] //chicago southbound
        case ._59:
            return [66807025, //eastbound
                    66807024, //ashland eastbound
                    66801334, //ashland->midway eastbound
                    66807023, //westbound
                    66807022, //ashland westbound
                    66801333] //ashland->midway westbound
        case ._60:
            return [66801345, 66801344, 66801347, 66801348, 66801350, 66801341, 66801342, 66808416, 66805908, 66801351]
        case ._62:
            return [66807111, 66807108, 66807110, 66807109, 66810877, 66815952, 66805687, 66812430, 66807112, 66808465, 66815950, 66815951, 66807120, 66809365, 66805693, 66809364, 66800890, 66812431, 66807119, 66807124]
        case ._62H:
            return [66806137, //eastbound
                    66806136] //westbound
        case ._63:
            return [66810930, 66804219, 66804115, 66804116, 66805355, 66810940, 66811682, 66810917, 66805058, 66804853, 66804112, 66801618, 66804111, 66805057]
        case ._63W:
            return [66804597, //archer eastbound
                    66804598, //65th westbound
                    66819363, //midway->narragansett westbound
                    66806509, //archer->cicero eastbound
                    66804595, //archer westbound
                    66806508, //cicero->archer westbound
                    66804596] //65th eastbound
        case ._65:
            return [66806656, 66806655, 66803213, 66802095, 66807905, 66803963, 66808181, 66814125, 66806652, 66806657, 66806653, 66807908, 66824001, 66807909, 66808417, 66803258]
        case ._66:
            return [66806662, //full length eastbound
                    66804355, //troy->navy pier eastbound
                    66806982, //austin->kostner eastbound
                    66804353, //kostner N66 eastbound
                    66804603, //kostner->navy pier eastbound
                    66820426, //kostner->navy pier eastbound
                    66806661, //N66 eastbound
                    66806665, //full length westbound
                    66804601, //kostner->austin westbound
                    66806658, //N66 westbound
                    66804344, //kostner->N66 westbound
                    66804357] //navy pier->kostner westbound
        case ._67:
            return [66804611,
                    66804610,
                    66801464,
                    66801465,
                    66801457,
                    66804609,
                    66804608,
                    66801463,
                    66822569,
                    66819371,
                    66819393,
                    66804605,
                    66822568,
                    66811676,
                    66801454,
                    66801450,
                    66801449,
                    66825893,
                    66804604]
        case ._68:
            return [66803215, //southbound
                    66819377, //nagle northbound
                    66803214, //northbound
                    66805728] //nagle southbound
        case ._70:
            return [66802289, //eastbound
                    66801500, //austin->pulaski eastbound
                    66802291, //westbound
                    66801499, //pulaski->austin westbound
                    66805670, //cicero->austin westbound
                    66801497] //western-austin some way
        case ._71:
            return [66807032, //northbound
                    66807031, //73rd northbound
                    66807030, //104th northbound
                    66807029, //southbound
                    66807028, //104th southbound
                    66807027] //73rd southbound
        case ._72:
            return [66810913, 66810919, 66801522, 66825890, 66801523, 66800100, 66800095, 66800096, 66805603, 66810918, 66801512, 66801516, 66805671]
        case ._73:
            return [66802170, //full length eastbound
                    66803493, //grand->pulaski eastbound
                    66802169, //full length westbound
                    66802292] //pulaski->grand westbound
        case ._74:
            return [66808422, //grand eastbound
                    66808418, //narragansett eastbound
                    66808421, //grand->pulaski eastbound
                    66808420, //grand westbound
                    66808423, //pulaski->grand westbound
                    66808419] //narragansett westbound
        case ._75:
            return [66801540, //westbound
                    66801541] //eastbound
        case ._76:
            return [66813247, 66804619, 66813248, 66804618, 66807176, 66804621, 66804615, 66809660, 66813249, 66807177]
        case ._77:
            return [66810944, 66810901, 66811678, 66801526, 66807739, 66825894, 66810937, 66804725, 66825895, 66807806, 66810924, 66810902, 66810904, 66807559, 66807561, 66808467, 66807560, 66810907]
        case ._78:
            return [66802922, //central->wilson eastbound
                    66807742, //forest preserve->central eastbound
                    66807743, //eastbound
                    66807740, //westbound
                    66808184, //wilson->central westbound
                    66807741] //central->forest preserve eastbound
        case ._79:
            return [66801612, 66801603, 66801628, 66803501, 66801627, 66806492, 66801611, 66801977, 66806538, 66801609, 66801604, 66801597, 66819376, 66801598, 66801599, 66803498, 66819369]
        case ._80:
            return [66803084, 66820427, 66805610, 66803082, 66803090, 66801031, 66810811, 66810909, 66803086, 66805704, 66801017, 66814106, 66801643, 66810926]
        case ._81:
            return [66816550, //eastbound
                    66816551] //westbound
        case ._81W:
            return [66806547, //eastbound weekday
                    66801652, //eastbound weekend
                    66801651, //westbound weekend
                    66806546] //westbound weekday
        case ._82:
            return [66801662, 66805066, 66801654, 66801656, 66804625, 66801661, 66810925, 66819396, 66819395, 66819394, 66801679, 66805070, 66801659, 66801664, 66815953, 66809792, 66805364, 66805069, 66806598, 66808468, 66803519, 66806984]
        case ._84:
            return [66801681, //eastbound
                    66821485, //eastbound 2?
                    66801682, //westbound
                    66813244] //westbound 2?
        case ._85:
            return [66810943, //northbound
                    66807570, //southbound
                    66813251, //jefferson park->belmont southbound
                    66805674] //belmont/leclaire southbound
        case ._85A:
            return [66805675, //northbound
                    66805676] //southbound
        case ._86:
            return [66803527, //northbound
                    66805678, //north->bryn mawr northbound
                    66813253, //north->diversey northbound
                    66810905, //southbound
                    66805679, //bryn mawr->north southbound
                    66804245, //milwaukee->north southbound
                    66806872] //southbound
        case ._87:
            return [66805571, 66805567, 66801718, 66805618, 66801708, 66805613, 66805566, 66814123, 66805569, 66805570, 66801706, 66805572, 66805680, 66801707, 66805616, 66805568]
        case ._88:
            return [66804672, //southbound
                    66823988, //harlem->jefferson park southbound
                    66801728] //northbound
        case ._90:
            return [66802944, //northbound
                    66805917] //southbound
        case ._91:
            return [66802946, //northbound
                    66803781, //belmont northbound
                    66802945] //southbound
        case ._92:
            return [66816548, //eastbound
                    66802725, //jefferson park->kedzie eastbound
                    66807750, //damen eastbound
                    66807749, //kedzie->red line eastbound
                    66816549, //westbound
                    66802721] //kedzie->jefferson park westbound
        case ._93:
            return [66808140, //albany->evanston hs northbound
                    66801800, //northbound
                    66801799, //kimball->albany northbound
                    66805376, //thorndale->howard northbound
                    66801802, //southbound
                    66801798, //albany->kimball southbound
                    66805736, //evanston hs->albany southbound
                    66801803] //howard->kimball southbound
        case ._94:
            return [66814118, //northbound
                    66814119, //southbound
                    66807184] //california orig southbound
        case ._95:
            if n5 {
                return [66808148, //95 becomes N5 at 95th/dan ryan eastbound
                        66808142] //N5 becomes 95 at 95th/dan ryan westbound
            }
            return [66808147, //eastbound
                    66808146, //stony island->south chicago eastbound
                    66808149, //throop->state eastbound
                    66815949, //95th/dan ryan->south chicago eastbound
                    66810956, //westbound
                    66808144, //south chicago->95th/dan ryan westbound
                    66808143] //south chicago->stony island westbound
        case ._96:
            return [66802107, //eastbound + lincolnwood tc
                    66802106, //eastbound
                    66802104, //westbound + lincolnwood tc
                    66802105] //westbound
        case ._97:
            return [66804369, //old orchard westbound
                    66804370, //dempster-skokie eastbound
                    66804372, //old orchard eastbound
                    66804371] //dempster-skokie westbound
        case ._100:
            return [66800703, //eastbound
                    66800699, //104th eastbound
                    66800701, //westbound
                    66800700, //104th westbound
                    66800702] //school trip
        case ._103:
            return [66805666, //104th+100th eastbound
                    66800717, //104th eastbound
                    66800704, //julian HS eastbound
                    66800714, //vincennes->95th eastbound
                    66800308, //104th+100th eastbound
                    66800710, //95th->vincennes westbound
                    66800711, //104th westbound
                    66800712, //104th+100th westbound
                    66800706] //michigan->vincennes westbound
        case ._106:
            return [66804493, //eastbound
                    66804492, //eastbound college bypass
                    66804491, //westbound college bypass
                    66804490, //westbound
                    66800720] //corliss
        case ._108:
            return [66800731, //northbound
                    66800727, //carver northbound
                    66800729, //southbound
                    66803411, //103rd southbound
                    66800730] //carver southbound
        case ._111:
            return [66806356, //northbound
                    66806354] //southbound
        case ._111A:
            return [66807134, //northbound
                    66807135] //southbound
        case ._112:
            return [66800752, //northbound
                    66800746, //vincennes->95th northbound
                    66800751, //vincennes southbound
                    //66807348, //northbound repeat?
                    66800749, //southbound
                    66800750] //vincennes northbound
        case ._115:
            return [66806358, //northbound
                    66806357] //southbound
        case ._119:
            return [66800754, //western northbound
                    66800755, //ashland northbound
                    66800757, //western southbound
                    66800758] //ashland southbound
        case ._120:
            if CMTime.isItCurrentlyBetween(start: CMTime(hour: 5, minute: 30), end: CMTime(hour: 10, minute: 30)) {
                return [66806361, //AM northbound
                        66806363] //AM southbound
            }
            return [66806362, //PM northbound
                    66806364] //PM southbound
        case ._121:
            if CMTime.isItCurrentlyBetween(start: CMTime(hour: 5, minute: 30), end: CMTime(hour: 10, minute: 30)) {
                return [66808086, //AM northbound
                        66808089] //AM southbound
            }
            return [66808087, //PM northbound
                    66808091] //PM southbound?
            //[66808090, //more no sense
            //66808088] //idk
        case ._124:
            return [66810950, //eastbound
                    66804708] //westbound
        case ._125:
            return [66802863, //northbound slightly farther
                    //66806369, //northbound
                    66802862] //southbound
        case ._126:
            return [66804505, 66810912, 66810903, 66808413, 66801116, 66801111, 66804504, 66801117, 66803934, 66801110, 66805857, 66810932, 66810922, 66800786, 66810911]
        /*case ._128:
            return []*/
        
        #warning("130 overlay not in data, extract separately")
        case ._130:
            return []
        case ._134:
            return [66804508, //northbound
                    66804509] //southbound
        case ._135:
            return [66804510, //northbound
                    66807444, //southbound
                    66807443] //sheridan southbound
        case ._136:
            return [66804080, //northbound
                    66807385] //southbound
        case ._143:
            return [66804511, //northbound
                    66804512] //southbound
        case ._146:
            return [66806582, 66806395, 66806581, 66806400, 66806399, 66806586, 66806398, 66806394, 66807451, 66807449, 66807447, 66807445, 66807452, 66807448, 66807450, 66807446]
        case ._147:
            return [66804524, //northbound
                    66800839, //sheridan->howard northbound
                    66804519, //randolph->sheridan northbound
                    66807724, //randolph->howard northbound
                    66807533, //balbo->broadway northbound
                    66804526, //southbound
                    66804522, //broadway->balbo southbound
                    66804525, //howard->randolph southbound
                    66804521] //broadway->balbo southbound
        case ._148:
            return [66806403, //northbound
                    66806402] //southbound
        case ._151:
            return [66806414, 66806413, 66806411, 66806409, 66806412, 66806410, 66808102, 66808095, 66808097, 66808103, 66808099, 66808096, 66808101, 66814112, 66808458]
        case ._152:
            return [66800899, 66800894, 66801938, 66807453, 66800896, 66807098, 66800893, 66800898, 66803041, 66807096, 66807097, 66800903, 66807727, 66803910, 66808104, 66805194]
        case ._155:
            return [66800905, //eastbound
                    66800904] //westbound
        case ._156:
            return [66808110, 66804537, 66808109, 66808461, 66808106, 66808108, 66808107, 66808111, 66808105, 66808112, 66825887]
        case ._157:
            #warning("this bus route is fucked up")
            return [66814133, //halsted northbound
                    66814132, //northbound
                    //66807864, //what
                    66814131, //ogilvie southbound
                    66814130] //southbound
        case ._165:
            return [66804599, //eastbound
                    66804671] //westbound
        case ._169:
            return [66807006, //westbound
                    66807005] //eastbound
        case ._171:
            return [66814111, //northbound
                    66814108] //southbound
        case ._172:
            return [66814103, //northbound
                    66814110] //southbound
        case ._192:
            if CMTime.isItCurrentlyBetween(start: CMTime(hour: 5, minute: 30), end: CMTime(hour: 10, minute: 30)) {
                return [66824000, //AM
                        66806980, //AM
                        66819367] //AM
            }
            return [66802671] //AM
        case ._201:
            return [66804318, //full length northbound
                    66804321, //central cowper southbound
                    66804319, //full length southbound
                    66804320] //central cowper northbound
        case ._206:
            if CMTime.isItCurrentlyBetween(start: CMTime(hour: 7, minute: 00), end: CMTime(hour: 9, minute: 30)) {
                return [66803189, //AM southbound
                        66808113, //AM southbound
                        66808115, //AM school northbound
                        //66808117, //AM northbound
                        66808116] //AM northbound but better
            } else {
                return [66803190, //PM southbound
                        66800978, //PM school southbound
                        66808689, //PM school chicago southbound
                        66808114] //PM northbound
                        //66808118] //central->school southbound?
            }
        }
    }
    
    func apiRepresentation() -> String {
        return routeNumber()
    }
    
    func routeNumber() -> String {
        if self == ._N5 {
            return "5"
        } else {
            return String(String(describing: self).dropFirst())
        }
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
        case ._19/*, ._128*/:
            return (NSColor.white, NSColor.white) //white background black text, for express buses
        case ._4, ._9, ._20, ._22, ._34, ._49, ._53, ._55, ._60, ._62, ._63, ._66, ._77, ._79, ._81, ._87:
            if ChicagoTransitInterface.isNightServiceActive(route: self) {
                return (NSColor(r: 0, g: 153, b: 153), NSColor.white) //white background bluegreen text
            }
            switch self {
            case ._34, ._60, ._63, ._79://, ._4, ._20, ._49, ._66://, ._53, ._55, ._77://, ._9, ._81:
                return (NSColor(r: 65, g: 65, b: 69), NSColor.white) //frequent network white text
            default:
                return (NSColor(r: 87, g: 88, b: 90), NSColor.white)
            }
        case ._47, ._54, ._95://, ._82://, ._12, ._72
            return (NSColor(r: 65, g: 65, b: 69), NSColor.white)
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
