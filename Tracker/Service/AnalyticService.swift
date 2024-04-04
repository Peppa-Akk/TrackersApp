import Foundation
import AppMetricaCore

struct AnalyticsService {
    
    static let shared = AnalyticsService()
    
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: "04da7133-5c4d-4e74-804e-84ef8ffe8f21") else { return }
        
        AppMetrica.activate(with: configuration)
    }
    
    func report(event: String, params : [AnyHashable : Any]) {
        AppMetrica.reportEvent(name: event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
