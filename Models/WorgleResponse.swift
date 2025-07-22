import Foundation

struct WorgleResponse: Codable {
    let channel: Channel
}

struct Channel: Codable {
    let total: Int
    let start: Int
    let num: Int
    let title: String
    let link: String
    let description: String
    let item: [Item]
}

struct Item: Codable {
    let title: String
    let link: String
    let description: String
    let thumbnail: String
}