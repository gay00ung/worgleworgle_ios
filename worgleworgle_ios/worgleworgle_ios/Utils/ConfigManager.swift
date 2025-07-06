import Foundation

enum ConfigManager {
    static var apiKey: String {
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let apiKey = plist["WORGLE_API_KEY"] as? String,
              !apiKey.isEmpty else {
            fatalError("API Key not found in Info.plist")
        }
        return apiKey
    }
}