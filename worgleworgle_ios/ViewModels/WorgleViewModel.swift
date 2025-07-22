import Foundation
import SwiftUI
import Combine

class WorgleViewModel: ObservableObject {
    @Published var todayWord: String?
    @Published var wordDefinition: String = ""
    @Published var inputCount: Int = 0
    @Published var hintCount: Int = 0
    @Published var correctWordCount: Int = 0
    @Published var hintList: [String] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let networkService = NetworkService.shared
    private let storageService = StorageService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        print("🎮 WorgleViewModel init called")
        loadStoredData()
        fetchTodayWord()
    }
    
    private func loadStoredData() {
        inputCount = storageService.inputCount
        hintCount = storageService.hintCount
        correctWordCount = storageService.correctWordCount
        hintList = storageService.hintList
        
        if let storedWord = storageService.todayWord {
            todayWord = storedWord.word
            wordDefinition = storedWord.definition
        }
    }
    
    func fetchTodayWord(forceRefresh: Bool = false, fullReset: Bool = false) {
        print("🔍 fetchTodayWord called - ALWAYS fetching new word from API")
        
        // 항상 새로운 단어를 가져옴 (캐시 사용하지 않음)
        print("🌐 Starting API call...")
        isLoading = true
        errorMessage = nil
        
        networkService.fetchRandomWord()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        print("❌ API Error: \(error.localizedDescription)")
                        // API 실패 시 재시도하지 않고 에러 표시
                    }
                },
                receiveValue: { [weak self] wordItem in
                    self?.todayWord = wordItem.word
                    self?.wordDefinition = wordItem.definition
                    self?.storageService.todayWord = wordItem
                    self?.storageService.updateLastWordDate()
                    
                    if fullReset {
                        self?.resetDailyStats()
                    } else if forceRefresh {
                        self?.resetRoundStats()
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func useDefaultWord() {
        let defaultWords = [
            WordItem(word: "사과", definition: "배와 함께 대표적인 과일의 하나."),
            WordItem(word: "컴퓨터", definition: "전자 회로를 이용하여 자동으로 계산이나 정보를 처리하는 기계."),
            WordItem(word: "책상", definition: "책을 읽거나 글을 쓸 때에 쓰는 상."),
            WordItem(word: "하늘", definition: "지구를 둘러싼 무한대의 공간."),
            WordItem(word: "바다", definition: "지구 표면에서 육지를 제외한 짠물이 차 있는 부분.")
        ]
        
        if let randomWord = defaultWords.randomElement() {
            todayWord = randomWord.word
            wordDefinition = randomWord.definition
            storageService.todayWord = randomWord
            storageService.updateLastWordDate()
            
            if storageService.isNewDay() {
                resetDailyStats()
            } else {
                resetRoundStats()
            }
        }
    }
    
    func increaseInputCount() {
        inputCount += 1
        storageService.inputCount = inputCount
    }
    
    func increaseHintCount() {
        hintCount += 1
        storageService.hintCount = hintCount
    }
    
    func increaseCorrectWordCount() {
        correctWordCount += 1
        storageService.correctWordCount = correctWordCount
    }
    
    func addHint(_ hint: String) {
        hintList.append(hint)
        storageService.addHint(hint)
    }
    
    func resetRoundStats() {
        inputCount = 0
        hintCount = 0
        hintList = []
        storageService.resetRoundStats()
    }
    
    func resetDailyStats() {
        inputCount = 0
        hintCount = 0
        correctWordCount = 0
        hintList = []
        storageService.resetDailyStats()
    }
    
    func isNewDay() -> Bool {
        return storageService.isNewDay()
    }
}