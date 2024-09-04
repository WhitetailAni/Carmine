//
//  InterfaceResultProcessing.swift
//  Carmine
//
//  Created by WhitetailAni on 7/23/24.
//

import Foundation
import CoreLocation

class InterfaceResultProcessing {
    
    ///Turns the CTA's Train Tracker API response for all runs along a line
    class func cleanUpPredictionInfo(info: [String: Any]) -> [[String: String]] {
        guard let root = info["bustime-response"] as? [String: Any], let predictions = root["prd"] as? [[String: Any]] else {
            return []
        }
        
        var predictionArray: [[String: String]] = []
        
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
            
            predictionArray.append(["destination": destination, "isDelayed": isDelayed, "distanceFromStop": distanceFromStop, "exactTime": exactTime, "stopName": stopName, "stopId": stopId, "vehicleId": vehicleId, "routeDirection": routeDirection, "isDeparture": isDeparturePrediction])
        }
        return predictionArray
    }
    
    ///Turns the CTA's Train Tracker API response for individual trains into clean and easy to read data
    class func cleanUpVehicleInfo(info: [String: Any]) -> [[String: String]] {
        guard let root = info["bustime-response"] as? [String: Any], let vehicles = root["vehicle"] as? [[String: Any]] else {
            return []
        }
        
        var vehicleArray: [[String: String]] = []
        
        for vehicle in vehicles {
            let vehicleId = vehicle["vid"] as? String ?? "0000"
            let latitudeString = vehicle["lat"] as? String ?? "-3"
            let longitudeString = vehicle["lon"] as? String ?? "-2"
            let destination = vehicle["des"] as? String ?? "Unknown Destination"
            let heading = vehicle["hdg"] as? String ?? "Unknown Heading"
            let time = vehicle["tmstmp"] as? String ?? "19700101 00:00"
            
            let cleanedVehicle: [String: String] = ["vehicleId": vehicleId, "latitude": latitudeString, "longitude": longitudeString, "destination": destination, "heading": heading, "time": time]
            vehicleArray.append(cleanedVehicle)
        }
        return vehicleArray
    }
    
    ///Gets the current location and time for a given CTA run
    class func getLocationFromStopInfo(info: [String: Any], stopId: String) -> CLLocationCoordinate2D {
        guard let root = info["bustime-response"] as? [String: Any], let stops = root["stops"] as? [[String: Any]] else {
            return CLLocationCoordinate2D(latitude: -2, longitude: -6)
        }
        
        var foundStop: [String: Any] = [:]
        for stop in stops {
            if stop["stpid"] as? String == stopId {
                foundStop = stop
                break
            }
        }
        
        if let latitude = foundStop["lat"] as? Double, let longitude = foundStop["lon"] as? Double {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        return CLLocationCoordinate2D(latitude: -2, longitude: -6)
    }
}
