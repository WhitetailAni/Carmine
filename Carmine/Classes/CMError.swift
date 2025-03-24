//
//  CMError.swift
//  Carmine
//
//  Created by WhitetailAni on 2/18/25.
//

enum CMError {
    case apiRequestLimit
    case noApiKey
    case unassignedApiKey
    case bannedApiKey
    case internalServerError
    case fake
    case fuck
    
    init(string: String) {
        switch string {
        case "Internal server error - Unable to complete request at this time":
            self = .internalServerError
        case "Transaction limit for current day has been exceeded.":
            self = .apiRequestLimit
        case "No API access key supplied":
            self = .noApiKey
        case "No API access permitted":
            self = .bannedApiKey
        case "Invalid API access key supplied":
            self = .unassignedApiKey
        case "No data found for parameter":
            self = .fake
        default:
            self = .fuck
        }
        return
    }
    
    func menuItemText() -> String {
        switch self {
        case .apiRequestLimit:
            return "Daily API request limit has been reached"
        case .noApiKey:
            return "No API key was provided"
        case .unassignedApiKey:
            return "API key provided is unused"
        case .bannedApiKey:
            return "API key provided has been banned"
        case .internalServerError:
            return "500 Internal Server Error"
        case .fuck:
            return "Unknown case. Fuck"
        case .fake:
            return "i love kissing girls"
        }
    }
}
