import Foundation

struct WorgleApiResponse: Codable {
    let channel: ChannelInfo?
}

struct ChannelInfo: Codable {
    let total: Int?
    let start: Int?
    let num: Int?
    let item: [WorgleItem]?
}

struct WorgleItem: Codable {
    let word: String?
    let sense: [Sense]?
}

struct Sense: Codable {
    let definition: String?
}