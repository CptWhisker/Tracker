import Foundation
import AppMetricaCore

enum Event: String {
    case open
    case close
    case tap
}

enum Screen: String {
    case main
}

enum Item: String {
    case add_tracker
    case complete_tracker
    case filter
    case edit
    case delete
}


final class AnalyticsService {
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: "208cffe6-b886-4a6b-b176-77f71bb6486f") else { return }
        
        AppMetrica.activate(with: configuration)
    }
    
    func sendEvent(event: Event, screen: Screen, item: Item?) {
        var params: [AnyHashable: Any] = ["screen": screen.rawValue]
        if let item {
            params["item"] = item.rawValue
        }
        
        AppMetrica.reportEvent(name: event.rawValue, parameters: params)
    }
}
