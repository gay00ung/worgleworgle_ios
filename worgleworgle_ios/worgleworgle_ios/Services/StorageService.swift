import Foundation
import SwiftUI

class StorageService {
    static let shared = StorageService()
    private init() {}
    
    @AppStorage("lastWordDate") private var lastWordDate: String = ""
    @AppStorage("todayWord") private var todayWordData: Data = Data()
    @AppStorage("inputCount") var inputCount: Int = 0
    @AppStorage("hintCount") var hintCount: Int = 0
    @AppStorage("correctWordCount") var correctWordCount: Int = 0
    @AppStorage("hintList") private var hintListData: Data = Data()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var todayWord: WordItem? {
        get {
            guard !todayWordData.isEmpty else { return nil }
            return try? JSONDecoder().decode(WordItem.self, from: todayWordData)
        }
        set {
            if let newValue = newValue,
               let data = try? JSONEncoder().encode(newValue) {
                todayWordData = data
            }
        }
    }
    
    var hintList: [String] {
        get {
            guard !hintListData.isEmpty else { return [] }
            return (try? JSONDecoder().decode([String].self, from: hintListData)) ?? []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                hintListData = data
            }
        }
    }
    
    func isNewDay() -> Bool {
        let today = dateFormatter.string(from: Date())
        return lastWordDate != today
    }
    
    func updateLastWordDate() {
        lastWordDate = dateFormatter.string(from: Date())
    }
    
    func resetRoundStats() {
        inputCount = 0
        hintCount = 0
        hintList = []
    }
    
    func resetDailyStats() {
        inputCount = 0
        hintCount = 0
        correctWordCount = 0
        hintList = []
    }
    
    func addHint(_ hint: String) {
        var currentHints = hintList
        currentHints.append(hint)
        hintList = currentHints
    }
}
