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
    static var sharedInstance = ChicagoTransitInterface()
    var sharedKey = ""
    
    override init() {
        super.init()
    }
    
    func storeAPIKey() {
        let keys = []
        for key in keys {
            if !ChicagoTransitInterface.sharedInstance.hasKeyTimedOut(string: key) {
                sharedKey = keys[0]
                return
            }
        }
        sharedKey = keys[0]
    }
    
    func hasKeyTimedOut(string: String) -> Bool {
        let baseURL = "http://www.ctabustracker.com/bustime/api/v3/gettime"
        let senaphore = DispatchSemaphore(value: 0)
        var returnedData: [String: Any] = [:]
        
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "key", value: string)
        ]
        
        contactDowntown(components: components) { result in
            returnedData = result
            senaphore.signal()
        }
        senaphore.wait()
        
        if let root = returnedData["bustime-response"] as? [String: Any], let error = root["error"] as? [[String: Any]], let errorString = error[0]["msg"] as? String {
            if errorString == "Transaction limit for current day has been exceeded." {
                return true
            }
        }
        return false
    }
    
    class func isHoliday() -> Bool {
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
    
    ///Gets information about a given CTA bus stop ID
    func getStopCoordinatesForID(route: CMRoute, direction: String, id: String) -> CLLocationCoordinate2D {
        let baseURL = "http://www.ctabustracker.com/bustime/api/v3/getstops"
        var returnedData: [String: Any] = [:]
        
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "key", value: ChicagoTransitInterface.sharedInstance.sharedKey),
            URLQueryItem(name: "rt", value: route.apiRepresentation()),
            URLQueryItem(name: "dir", value: direction)
        ]
        
        contactDowntown(components: components) { result in
            returnedData = result
            self.semaphore.signal()
        }
        semaphore.wait()
        
        guard let root = returnedData["bustime-response"] as? [String: Any], let stops = root["stops"] as? [[String: Any]] else {
            return CLLocationCoordinate2D(latitude: -2, longitude: -6)
        }
        
        var foundStop: [String: Any] = [:]
        for stop in stops {
            if stop["stpid"] as? String == id {
                foundStop = stop
                break
            }
        }
        
        if let latitude = foundStop["lat"] as? Double, let longitude = foundStop["lon"] as? Double {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        return CLLocationCoordinate2D(latitude: -2, longitude: -6)
    }
    
    ///Gets the location of a CTA bus from its ID
    func getLocationForVehicleId(id: String) -> CLLocationCoordinate2D {
        let baseURL = "http://www.ctabustracker.com/bustime/api/v3/getvehicles"
        var returnedData: [String: Any] = [:]
        
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "key", value: ChicagoTransitInterface.sharedInstance.sharedKey),
            URLQueryItem(name: "vid", value: id)
        ]
        
        contactDowntown(components: components) { result in
            returnedData = result
            self.semaphore.signal()
        }
        semaphore.wait()
        
        if let root = returnedData["bustime-response"] as? [String: Any], let vehicles = root["vehicle"] as? [[String: Any]], let latitudeString = vehicles[0]["lat"] as? String, let longitudeString = vehicles[0]["lon"] as? String, let latitude = Double(latitudeString), let longitude = Double(longitudeString) {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else if let root = returnedData["bustime-response"] as? [String: Any], let error = root["error"] as? [[String: Any]], let errorString = error[0]["msg"] as? String {
            if errorString == "Transaction limit for current day has been exceeded." {
                return CLLocationCoordinate2D(latitude: -8, longitude: -8)
            }
        }
        return CLLocationCoordinate2D(latitude: -4, longitude: -4)
    }
    
    ///Gets basic info about a given CTA bus vehicle ID
    func getInfoForVehicleIds(ids: [String]) -> [CMVehicle] {
        let baseURL = "http://www.ctabustracker.com/bustime/api/v3/getvehicles"
        var returnedData: [String: Any] = [:]
        
        var idString = ""
        for id in ids {
            idString += "\(id),"
        }
        idString = String(idString.dropLast(1))
        
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "key", value: ChicagoTransitInterface.sharedInstance.sharedKey),
            URLQueryItem(name: "vid", value: idString)
        ]
        
        contactDowntown(components: components) { result in
            returnedData = result
            self.semaphore.signal()
        }
        semaphore.wait()
        
        var vehicleArray: [CMVehicle] = []
        
        if let root = returnedData["bustime-response"] as? [String: Any], let vehicles = root["vehicle"] as? [[String: Any]] {
            for vehicle in vehicles {
                if let vehicleId = vehicle["vid"] as? String, let latitudeString = vehicle["lat"] as? String, let longitudeString = vehicle["lon"] as? String, let latitude = Double(latitudeString), let longitude = Double(longitudeString), let destination = vehicle["des"] as? String, let timestamp = vehicle["tmstmp"] as? String, let routeString = vehicle["rt"] as? String, let route = CMRoute.createCMRouteFromString(string: routeString) {
                    
                    vehicleArray.append(CMVehicle(vehicleId: vehicleId, route: route, location: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), destination: destination, timestampLastUpdated: timestamp))
                }
            }
        }
        
        return vehicleArray
    }
    
    func getDetoursForRoute(route: CMRoute) -> [CMDetour] {
        let baseURL = "http://www.ctabustracker.com/bustime/api/v3/getdetours"
        var returnedData: [String: Any] = [:]
        
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "key", value: ChicagoTransitInterface.sharedInstance.sharedKey),
            URLQueryItem(name: "rt", value: route.apiRepresentation())
        ]
        
        contactDowntown(components: components) { result in
            returnedData = result
            //print(returnedData)
            self.semaphore.signal()
        }
        semaphore.wait()
        
        guard let root = returnedData["bustime-response"] as? [String: Any] else {
            return []
        }
        
        return []
    }
    
    ///Gets a list of every vehicle on a given CTA bus route
    func getVehiclesForRoute(route: CMRoute) -> [String: Any] {
        let baseURL = "http://www.ctabustracker.com/bustime/api/v3/getvehicles"
        var returnedData: [String: Any] = [:]
        
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "key", value: ChicagoTransitInterface.sharedInstance.sharedKey),
            URLQueryItem(name: "rt", value: route.apiRepresentation())
        ]
        
        contactDowntown(components: components) { result in
            returnedData = result
            self.semaphore.signal()
        }
        semaphore.wait()
        return returnedData
    }
    
    class func cleanUpVehicleInfo(info: [String: Any]) -> [CMVehicle] {
        guard let root = info["bustime-response"] as? [String: Any], let vehicles = root["vehicle"] as? [[String: Any]] else {
            return []
        }
        
        var vehicleArray: [CMVehicle] = []
        
        for vehicle in vehicles {
            if let vehicleId = vehicle["vid"] as? String, let latitudeString = vehicle["lat"] as? String, let longitudeString = vehicle["lon"] as? String, let destination = vehicle["des"] as? String, let latitude = Double(latitudeString), let longitude = Double(longitudeString), let timestamp = vehicle["tmstmp"] as? String, let routeString = vehicle["rt"] as? String, let route = CMRoute.createCMRouteFromString(string: routeString) {
            vehicleArray.append(CMVehicle(vehicleId: vehicleId, route: route, location: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), destination: destination, timestampLastUpdated: timestamp))
            }
        }
        return vehicleArray
    }
    
    class func returnErrorString(info: [String: Any]) -> String {
        let yuri = "i love kissing girls"
        guard let root = info["bustime-response"] as? [String: Any], let error = root["error"] as? [[String: Any]] else {
            return yuri
        }
        let errorString: String = error[0]["msg"] as? String ?? yuri
        if errorString == yuri {
            return yuri
        }
        let errorStruct = CMError(string: errorString)
        if errorStruct == .apiRequestLimit {
            ChicagoTransitInterface.sharedInstance.storeAPIKey()
        }
        return errorStruct.menuItemText()
    }
    
    ///Gets a list of every stop prediction for a given vehicle ID
    func getPredictionsForVehicle(route: CMRoute, vehicleId: String) -> [CMPrediction] {
        let baseURL = "http://www.ctabustracker.com/bustime/api/v3/getpredictions"
        var returnedData: [String: Any] = [:]
        
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "key", value: ChicagoTransitInterface.sharedInstance.sharedKey),
            URLQueryItem(name: "rt", value: route.apiRepresentation()),
            URLQueryItem(name: "vid", value: vehicleId)
        ]
        
        contactDowntown(components: components) { result in
            returnedData = result
            self.semaphore.signal()
        }
        semaphore.wait()
        
        guard let root = returnedData["bustime-response"] as? [String: Any], let predictions = root["prd"] as? [[String: Any]] else {
            return []
        }
        
        var predictionArray: [CMPrediction] = []
        
        for prediction in predictions {
            if let destination = prediction["des"] as? String, let exactTime = prediction["prdtm"] as? String, let stopName = prediction["stpnm"] as? String, let stopId = prediction["stpid"] as? String, let isDeparturePrediction = prediction["typ"] as? String, let vehicleId = prediction["vid"] as? String, let routeDirection = prediction["rtdir"] as? String {
                
                predictionArray.append(CMPrediction(destination: destination, delayed: { prediction["dly"] as? String ?? "0" != "0" }(), departureTimestamp: exactTime, stopName: stopName, stopId: stopId, isDeparture: { isDeparturePrediction == "D" }(), vehicleId: vehicleId, direction: routeDirection))
            }
        }
        return predictionArray
    }
    
    func getOverlaysForRoute(route: CMRoute) -> [CMPolyline] {
        guard route != ._19 else {
            return [CMPolyline.nineteen]
        }
        
        let baseURL = "http://www.ctabustracker.com/bustime/api/v3/getpatterns"
        var returnedData: [String: Any] = [:]
        
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "key", value: ChicagoTransitInterface.sharedInstance.sharedKey),
            URLQueryItem(name: "rt", value: route.apiRepresentation())
        ]
        
        contactDowntown(components: components) { result in
            returnedData = result
            self.semaphore.signal()
        }
        semaphore.wait()
        
        guard let root = returnedData["bustime-response"] as? [String: Any], let pointer = root["ptr"] as? [[String: Any]] else {
            return [CMPolyline(coordinates: [], count: 0)]
        }
        
        var polylines: [CMPolyline] = []
        
        for pointss in pointer {
            var coordinates: [CLLocationCoordinate2D] = []
            
            if let points = pointss["pt"] as? [[String: Any]] {
                for point in points {
                    if let latitude = point["lat"] as? Double, let longitude = point["lon"] as? Double {
                        coordinates.append(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                    }
                }
            }
            
            polylines.append(CMPolyline(coordinates: coordinates, count: coordinates.count))
        }
        
        return polylines
    }
    
    func getNextPredictionForVehicle(route: CMRoute, vehicleId: String) -> [String: String] {
        let baseURL = "http://www.ctabustracker.com/bustime/api/v3/getpredictions"
        var returnedData: [String: Any] = [:]
        
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "key", value: ChicagoTransitInterface.sharedInstance.sharedKey),
            URLQueryItem(name: "rt", value: route.apiRepresentation()),
            URLQueryItem(name: "vid", value: vehicleId),
            URLQueryItem(name: "top", value: "1")
        ]
        
        contactDowntown(components: components) { result in
            returnedData = result
            self.semaphore.signal()
        }
        semaphore.wait()
        
        guard let root = returnedData["bustime-response"] as? [String: Any], let predictions = root["prd"] as? [[String: Any]] else {
            return [:]
        }
        
        for prediction in predictions {
            let destination = prediction["des"] as? String ?? "Unknown Destination"
            let isDelayedRaw = prediction["dly"] as? String ?? "0"
            var isDelayed = "Yes"
            if isDelayedRaw == "0" {
                isDelayed = "No"
            }
            let distanceFromStop = prediction["dstp"] as? String ?? "9999"
            let exactTime = prediction["prdtm"] as? String ?? "Unknown Departure Time"
            let stopName = prediction["stpnm"] as? String ?? "Unknown Stop"
            let stopId = prediction["stpid"] as? String ?? "Unknown Stop ID"
            let isDeparturePrediction = prediction["typ"] as? String ?? "A"
            let vehicleId = prediction["vid"] as? String ?? "0000"
            let routeDirection = prediction["rtdir"] as? String ?? "Unknown Direction"
            
            return (["destination": destination, "isDelayed": isDelayed, "distanceFromStop": distanceFromStop, "exactTime": exactTime, "stopName": stopName, "stopId": stopId, "vehicleId": vehicleId, "routeDirection": routeDirection, "isDeparture": isDeparturePrediction])
        }
        return [:]
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
