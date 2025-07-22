import Foundation
import Combine

class NetworkService {
    static let shared = NetworkService()
    private init() {}
    
    private let baseURL = "https://krdict.korean.go.kr/api/search"
    private var apiKey: String {
        let key = ConfigManager.apiKey
        print("🔑 API Key loaded: \(key)")
        return key
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
        var attempts = 0
        let maxAttempts = 10 // 최대 10번만 시도
        
        while attempts < maxAttempts {
            attempts += 1
            let randomChar = getRandomKoreanChar()
            print("Random Korean char: \(randomChar) (Attempt \(attempts)/\(maxAttempts))")
            
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
            
            print("API URL: \(url)")
            let (data, response) = try await URLSession.shared.data(from: url)
            print("API Response Status: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
            print("API Response Data Size: \(data.count) bytes")
            
            // 응답 데이터 확인
            guard let responseString = String(data: data, encoding: .utf8) else {
                print("❌ Failed to decode response data, trying next character...")
                continue
            }
            
            print("API Response: \(responseString)")
            
            // XML 에러 응답 체크
            if responseString.contains("<error>") {
                print("❌ API returned error response, trying next character...")
                continue
            }
            
            // XML 파싱 (간단한 정규식 사용)
            let words = parseWordsFromXML(responseString)
            let validWords = words.filter { item in
                guard item.word.count >= 2,
                      !item.word.contains("-"),
                      !item.word.contains("_") else { return false }
                return true
            }
            
            print("Total words found: \(words.count), Valid words after filtering: \(validWords.count)")
            
            if !validWords.isEmpty {
                let selectedItem = validWords.randomElement()!
                print("✅ Selected word: \(selectedItem.word) / Definition: \(selectedItem.definition)")
                return selectedItem
            } else {
                print("❌ No valid words found for \(randomChar), trying next character...")
            }
        }
        
        // 최대 시도 횟수 초과 시 기본 단어 반환
        print("⚠️ Max attempts reached, using default word")
        return getDefaultWord()
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
    
    private func parseWordsFromXML(_ xml: String) -> [WordItem] {
        var words: [WordItem] = []
        
        // <item> 태그로 분리
        let itemPattern = "<item>(.*?)</item>"
        let itemRegex = try? NSRegularExpression(pattern: itemPattern, options: .dotMatchesLineSeparators)
        let itemMatches = itemRegex?.matches(in: xml, range: NSRange(xml.startIndex..., in: xml)) ?? []
        
        for match in itemMatches {
            if let itemRange = Range(match.range(at: 1), in: xml) {
                let itemXML = String(xml[itemRange])
                
                // word 추출
                var word = ""
                if let wordMatch = itemXML.range(of: "<word>", options: .caseInsensitive),
                   let wordEndMatch = itemXML.range(of: "</word>", options: .caseInsensitive) {
                    word = String(itemXML[wordMatch.upperBound..<wordEndMatch.lowerBound])
                }
                
                // definition 추출 (여러 개일 수 있음)
                var definitions: [String] = []
                let defPattern = "<definition>(.*?)</definition>"
                let defRegex = try? NSRegularExpression(pattern: defPattern, options: .dotMatchesLineSeparators)
                let defMatches = defRegex?.matches(in: itemXML, range: NSRange(itemXML.startIndex..., in: itemXML)) ?? []
                
                for defMatch in defMatches {
                    if let defRange = Range(defMatch.range(at: 1), in: itemXML) {
                        definitions.append(String(itemXML[defRange]))
                    }
                }
                
                let definition = definitions.isEmpty ? "정의 없음" : definitions.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                
                if !word.isEmpty {
                    words.append(WordItem(word: word, definition: definition))
                }
            }
        }
        
        return words
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
