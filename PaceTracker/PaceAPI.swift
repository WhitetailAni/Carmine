//
//  Contact.swift
//  PaceTracker
//
//  Created by WhitetailAni on 11/29/24.
//

import Foundation
import MapKit

///Create one instance of PaceTracker per request you would like to send. Otherwise requests may be dropped.
public class PaceAPI: NSObject {
    let semaphore = DispatchSemaphore(value: 0)
    
    ///Tells you if service has ended for the day for a given route.
    class public func hasServiceEnded(route: PTRoute) -> Bool {
        var weekday = Calendar.current.component(.weekday, from: Date())
        if isHoliday() {
            weekday = 1
        }
        
        switch route.number {
        case 293:
            switch weekday {
            case 1:
                return PTTime.isItCurrentlyBetween(start: PTTime(hour: 1, minute: 20), end: PTTime(hour: 5, minute: 54))
            case 7:
                return PTTime.isItCurrentlyBetween(start: PTTime(hour: 1, minute: 32), end: PTTime(hour: 4, minute: 25))
            default:
                return PTTime.isItCurrentlyBetween(start: PTTime(hour: 1, minute: 32), end: PTTime(hour: 4, minute: 24))
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

        if month == 6 && day == 19 {
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
    
    ///Returns a list of all current Pace routes. See the readme for more info.
    public func getRoutes() -> [PTRoute] {
        var returnedData: [String: Any] = [:]
        var routeArray: [PTRoute] = []
        
        theScraperrrrr(endpoint: "Arrivals.aspx/getRoutes") { result in
            returnedData = result
            self.semaphore.signal()
        }
        semaphore.wait()
        
        let routes: [[String: Any]] = returnedData["d"] as? [[String : Any]] ?? []
        for route in routes {
            let name = route["name"] as! String
            routeArray.append(PTRoute(id: route["id"] as! Int, number: Int(name.components(separatedBy: " - ").first ?? "0")!, name: name.components(separatedBy: " - ").dropFirst().joined(separator: " - "), fullName: name))
        }
        
        return routeArray
    }
    
    ///For a given route ID, this will tell you the route's directions. See the readme for more info.
    public func getRouteDirections(routeID: Int) -> [PTDirection] {
        var returnedData: [String: Any] = [:]
        var directionArray: [PTDirection] = []
        
        theScraperrrrr(endpoint: "Arrivals.aspx/getDirections", body: ["routeID": routeID]) { result in
            returnedData = result
            self.semaphore.signal()
        }
        self.semaphore.wait()
        
        let directions: [[String: Any]] = returnedData["d"] as? [[String: Any]] ?? []
        for direction in directions {
            directionArray.append(PTDirection(id: direction["id"] as? Int ?? -1, name: direction["name"] as? String ?? ""))
        }
        
        return directionArray
    }
    
    ///For a given route ID and a given direction ID, this will give you a list of all stops the route will make in that direction.
    public func getStopsForRouteAndDirectionID(routeID: Int, directionID: Int) -> [PTStop] {
        var returnedData: [String: Any] = [:]
        var idArray: [Int] = []
        var stopArray: [PTStop] = []
        
        theScraperrrrr(endpoint: "Arrivals.aspx/getStops", body: ["routeID": routeID, "directionID": directionID]) { result in
            returnedData = result
            self.semaphore.signal()
        }
        self.semaphore.wait()
        
        let stops: [[String: Any]] = returnedData["d"] as! [[String : Any]]
        for stop in stops {
            idArray.append(stop["id"] as? Int ?? -1)
        }
        
        let tooManyStops = PaceAPI().getStopsAndLocationsForRouteID(routeID: routeID)
        for stop in tooManyStops {
            if idArray.contains(stop.id) && !stopArray.contains(where: { $0.id == stop.id }) {
                stopArray.append(stop)
            }
        }
        
        return stopArray
    }
    
    ///For a given route ID, direction ID, and stop ID, this will give you the next 3 expected arrival times for that stop. See the readme for more info.
    public func getArrivalTimesForRouteDirectionAndStopID(routeID: Int, directionID: Int, stopID: Int) -> [String: Any] {
        var returnedData: [String: Any] = [:]
        
        theScraperrrrr(endpoint: "Arrivals.aspx/getStopTimes", body: ["routeID": routeID, "directionID": directionID, "stopID": stopID]) { result in
            returnedData = result
            self.semaphore.signal()
        }
        self.semaphore.wait()
        
        return returnedData
    }
    
    ///For a given route ID, this will return all the stops and their locations for that route in both directions. See the readme for more info.
    public func getStopsAndLocationsForRouteID(routeID: Int) -> [PTStop] {
        var returnedData: [String: Any] = [:]
        var stopArray: [PTStop] = []
        
        theScraperrrrr(endpoint: "GoogleMap.aspx/getStops", body: ["routeID": routeID]) { result in
            returnedData = result
            self.semaphore.signal()
        }
        self.semaphore.wait()
        
        let stops: [[String: Any]] = returnedData["d"] as? [[String : Any]] ?? []
        for stop in stops {
            let directionID = stop["directionID"] as? Int ?? 0
            let directionName = stop["directionName"] as? String ?? ""
            let location = CLLocationCoordinate2D(latitude: stop["lat"] as? Double ?? 0.0, longitude: stop["lon"] as? Double ?? 0.0)
            let stopID = stop["stopID"] as? Int ?? 0
            let stopName = stop["stopName"] as? String ?? ""
            let stopNumber = stop["stopNumber"] as? Int ?? 0
            let timePointID = stop["timePointID"] as? Int ?? 0
            stopArray.append(PTStop(id: stopID, name: stopName, timePointID: timePointID, directionID: directionID, directionName: directionName, location: location, number: stopNumber))
        }
        
        return stopArray
    }
    
    ///For a given route ID, this will return all active vehicles and many properties about them. See the readme for more info.
    public func getVehicleLocationsForRouteID(routeID: Int) -> [PTVehicle] {
        var returnedData: [String: Any] = [:]
        var vehicleArray: [PTVehicle] = []
        
        theScraperrrrr(endpoint: "GoogleMap.aspx/getVehicles", body: ["routeID": routeID]) { result in
            returnedData = result
            self.semaphore.signal()
        }
        self.semaphore.wait()
        
        let vehicles: [[String: Any]] = returnedData["d"] as? [[String : Any]] ?? []
        for vehicle in vehicles {
            let hasBikeRack = vehicle["bikeRack"] as? Bool ?? false
            let heading = vehicle["heading"] as? Int ?? 0
            let location = CLLocationCoordinate2D(latitude: vehicle["lat"] as? Double ?? 0, longitude: vehicle["lon"] as? Double ?? 0)
            let vehicleNumber = vehicle["propertyTag"] as? String ?? "0000"
            let routeID = vehicle["routeID"] as? Int ?? 000
            let routeName = vehicle["routeName"] as? String ?? "Unknown Route"
            let hasWifi = vehicle["wiFiAccess"] as? Bool ?? false
            let isAccessible = vehicle["wheelChairAccessible"] as? Bool ?? false
            let hasWheelchairLift = vehicle["wheelChairLift"] as? Bool ?? false
            
            let vehicle = PTVehicle(hasBikeRack: hasBikeRack, heading: heading, location: location, vehicleNumber: vehicleNumber, routeID: routeID, routeName: routeName, hasWiFi: hasWifi, isAccessible: isAccessible, hasWheelchairLift: hasWheelchairLift)
            vehicleArray.append(vehicle)
        }
        
        return vehicleArray
    }
    
    /*public func getPolyLineForRouteID(routeID: Int) /*-> MKPolyline*/ {
        var rawData: Data = Data()
        
        var request = URLRequest(url: URL(string: "https://tmweb.pacebus.com/TMWebWatch/getRouteTrace")!)
        request.httpMethod = "POST"
        request.setValue("application/json, charset=utf8", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["routeID": routeID])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.semaphore.signal()
            }
            
            if let response = response as? HTTPURLResponse {
                print(response.statusCode)
            }
            
            if let data: Data = data {
                rawData = data
                self.semaphore.signal()
            }
            
            self.semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
     
        print(String(data: rawData, encoding: .utf8))
        do {
            let jsonResult = try JSONDecoder().decode(String.self, from: rawData)
        } catch {
            print(error.localizedDescription)
        }
        //print(jsonResult)
    }*/
    
    private func theScraperrrrr(endpoint: String, body: [String: Any] = [:], completion: @escaping ([String: Any]) -> Void) {
        guard let url = URL(string: "https://tmweb.pacebus.com/TMWebWatch/\(endpoint)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(["Error": "Request failed: \(error.localizedDescription)"])
                return
            }
            
            guard let data = data else {
                completion(["Error": "No data received"])
                return
            }
            
            //print(String(data: data, encoding: .utf8))
            
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
