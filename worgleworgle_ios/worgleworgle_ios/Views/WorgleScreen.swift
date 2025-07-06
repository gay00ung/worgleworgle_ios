import SwiftUI

struct WorgleScreen: View {
    @StateObject private var viewModel = WorgleViewModel()
    @State private var userInput = ""
    @State private var similarity: Int?
    @State private var showingHint = false
    @State private var showingConfetti = false
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        ZStack {
            Color(red: 1.0, green: 0.98, blue: 0.8) // Lemon color
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Title
                    Text("🤪 워글워글 🤪")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.3)) // Green
                        .padding(.top, 40)
                    
                    // Word length
                    if viewModel.isLoading {
                        Text("단어를 불러오는 중입니다...")
                            .font(.system(size: 16))
                    } else {
                        Text("오늘의 단어 글자 수 : \(viewModel.todayWord?.count ?? 0)")
                            .font(.system(size: 16))
                    }
                    
                    // Word definition
                    WordDefinitionView(definition: viewModel.wordDefinition, isLoading: viewModel.isLoading)
                        .padding(.horizontal)
                    
                    // Input section
                    InputSection(
                        userInput: $userInput,
                        isInputFocused: _isInputFocused,
                        onSubmit: {
                            handleSubmit()
                        }
                    )
                    .padding(.horizontal)
                    
                    // Stats
                    HStack(spacing: 20) {
                        Text("입력 횟수: \(viewModel.inputCount)")
                        Text("힌트 사용 횟수: \(viewModel.hintCount)")
                    }
                    .font(.system(size: 14))
                    
                    Text("오늘 맞힌 단어 수: \(viewModel.correctWordCount)")
                        .font(.system(size: 14))
                    
                    // Similarity result
                    if let similarity = similarity {
                        SimilarityView(
                            similarity: similarity,
                            inputCount: viewModel.inputCount,
                            onNewWord: {
                                viewModel.fetchTodayWord(forceRefresh: true)
                                userInput = ""
                                self.similarity = nil
                            }
                        )
                    }
                    
                    // Hint section
                    HintSection(
                        todayWord: viewModel.todayWord,
                        hintCount: viewModel.hintCount,
                        hintList: viewModel.hintList,
                        showingHint: $showingHint,
                        onHintUsed: {
                            viewModel.increaseHintCount()
                        },
                        onAddHint: { hint in
                            viewModel.addHint(hint)
                        }
                    )
                    .padding(.horizontal)
                    
                    Spacer(minLength: 50)
                    
                    // Give up button
                    Button(action: {
                        if let word = viewModel.todayWord {
                            showToast("정답은: \(word) 입니다!")
                        }
                    }) {
                        Text("정답을 알려주세요😭")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 40)
                }
            }
            
            // Confetti effect
            if showingConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            checkForNewDay()
        }
    }
    
    private func handleSubmit() {
        guard let todayWord = viewModel.todayWord else { return }
        
        viewModel.increaseInputCount()
        similarity = calculateSimilarity(userInput, todayWord)
        
        if userInput == todayWord {
            showToast("정답입니다!🎉")
            viewModel.increaseCorrectWordCount()
            showingConfetti = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showingConfetti = false
                viewModel.fetchTodayWord(forceRefresh: true)
                userInput = ""
                similarity = nil
            }
        } else {
            showToast("오답입니다!😩")
        }
    }
    
    private func checkForNewDay() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            if viewModel.isNewDay() {
                viewModel.fetchTodayWord(forceRefresh: true, fullReset: true)
            }
        }
    }
    
    private func showToast(_ message: String) {
        // iOS에서는 Toast 대신 다른 방식으로 알림 표시
        // 실제 구현시 Alert 또는 커스텀 Toast 뷰 사용
        print(message)
    }
}
