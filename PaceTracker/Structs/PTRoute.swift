//
//  PTRoute.swift
//  PaceTracker
//
//  Created by WhitetailAni on 11/29/24.
//

public struct PTRoute {
    ///The route's ID, for API purposes.
    public var id: Int
    ///The route's public number, posted on schedules, signs, and buses.
    public var number: Int
    ///The route's public name, posted on schedules, signs, and buses.
    public var name: String
    ///"number - name"
    public var fullName: String
    
    public func link() -> URL {
        if number == 101 {
            return URL(string: "https://www.pacebus.com/route/pulse-dempster-line")!
        }
        return URL(string: "https://www.pacebus.com/route/\(number)")!
    }
    
    public static func testValues() -> [PTRoute] {
        let pulse = PTRoute(id: 293, number: 100, name: "Pulse Milwaukee Line", fullName: "100 - Pulse Milwaukee Line")
        let greenLine = PTRoute(id: 35, number: 309, name: "Lake Street", fullName: "309 - Lake Street")
        let loop = PTRoute(id: 55, number: 354, name: "Harvey - Oak Forest Loop", fullName: "354 - Harvey - Oak Forest Loop")
        let elgin = PTRoute(id: 111, number: 541, name: "Northeast Elgin", fullName: "541 - Northeast Elgin")
        
        return [pulse, greenLine, loop, elgin]
    }
}
