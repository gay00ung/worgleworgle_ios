import Foundation
import Combine

class NetworkService {
    static let shared = NetworkService()
    private init() {}
    
    private let baseURL = "https://opendict.korean.go.kr/api/search"
    private var apiKey: String {
        // TODO: 실제 API 키로 교체하세요
        return "YOUR_ACTUAL_API_KEY_HERE"
    }
    
    func fetchRandomWord() -> AnyPublisher<WordItem, Error> {
        return Future<WordItem, Error> { promise in
            Task {
                do {
                    if let wordItem = try await self.fetchRandomWordAsync() {
                        promise(.success(wordItem))
                    } else {
                        promise(.failure(URLError(.cannotFindHost)))
                    }
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func fetchRandomWordAsync() async throws -> WordItem? {
        
        while true {
            let randomChar = getRandomKoreanChar()
            print("Random Korean char: \(randomChar)")
            
            var components = URLComponents(string: baseURL)!
            components.queryItems = [
                URLQueryItem(name: "key", value: apiKey),
                URLQueryItem(name: "q", value: String(randomChar)),
                URLQueryItem(name: "num", value: "100"),
                URLQueryItem(name: "part", value: "word"),
                URLQueryItem(name: "translated", value: "n"),
                URLQueryItem(name: "advanced", value: "n"),
                URLQueryItem(name: "method", value: "include")
            ]
            
            guard let url = components.url else {
                throw URLError(.badURL)
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(WorgleApiResponse.self, from: data)
            
            let validWords = response.items?.filter { item in
                guard let word = item.word,
                      word.count >= 2,
                      !word.contains("-") else { return false }
                return true
            }
            
            if let validWords = validWords, !validWords.isEmpty {
                let selectedItem = validWords.randomElement()!
                let word = selectedItem.word ?? ""
                let definition = selectedItem.senses?.compactMap { $0.definition }
                    .joined(separator: "\n")
                    .trimmingCharacters(in: .whitespacesAndNewlines) ?? "정의 없음"
                
                print("Selected word: \(word) / Definition: \(definition)")
                return WordItem(word: word, definition: definition)
            } else {
                print("No valid words found for \(randomChar)")
            }
        }
    }
    
    private func getDefaultWord() -> WordItem {
        let defaultWords = [
            WordItem(word: "사과", definition: "배와 함께 대표적인 과일의 하나."),
            WordItem(word: "컴퓨터", definition: "전자 회로를 이용하여 자동으로 계산이나 정보를 처리하는 기계."),
            WordItem(word: "책상", definition: "책을 읽거나 글을 쓸 때에 쓰는 상."),
            WordItem(word: "하늘", definition: "지구를 둘러싼 무한대의 공간."),
            WordItem(word: "바다", definition: "지구 표면에서 육지를 제외한 짠물이 차 있는 부분.")
        ]
        return defaultWords.randomElement()!
    }
    
    private func parseDefinition(from description: String) -> String {
        // HTML 태그 제거 및 정의 추출
        let cleanedString = description
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&[^;]+;", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 첫 번째 정의만 추출
        let components = cleanedString.components(separatedBy: ".")
        if let firstDefinition = components.first {
            return firstDefinition.trimmingCharacters(in: .whitespacesAndNewlines) + "."
        }
        
        return cleanedString
    }
}