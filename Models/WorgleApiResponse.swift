import Foundation

struct WorgleApiResponse: Codable {
    let items: [WorgleItem]?
}

struct WorgleItem: Codable {
    let word: String?
    let senses: [Sense]?
}

struct Sense: Codable {
    let definition: String?
}