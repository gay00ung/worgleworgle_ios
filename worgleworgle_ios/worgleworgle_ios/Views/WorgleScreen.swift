import SwiftUI

struct WorgleScreen: View {
    @StateObject private var viewModel = WorgleViewModel()
    @State private var userInput = ""
    @State private var similarity: Int?
    @State private var showingHint = false
    @State private var showingConfetti = false
    @FocusState private var isInputFocused: Bool
    
    @State private var showToast = false
    @State private var toastMessage = ""
    
    // MARK: - Body
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
                            .foregroundColor(Color.gray)
                    } else {
                        Text("오늘의 단어 글자 수 : \(viewModel.todayWord?.count ?? 0)")
                            .font(.system(size: 16))
                            .foregroundColor(Color.gray)
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
                            .foregroundColor(Color.gray)
                        Text("힌트 사용 횟수: \(viewModel.hintCount)")
                            .foregroundColor(Color.gray)
                    }
                    .font(.system(size: 14))
                    
                    Text("오늘 맞힌 단어 수: \(viewModel.correctWordCount)")
                        .font(.system(size: 14))
                        .foregroundColor(Color.gray)
                    
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
            
            // Toast overlay
            VStack {
                if showToast {
                    Text(toastMessage)
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.3), value: showToast)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 50)
        }
        .onAppear {
            checkForNewDay()
        }
    }
    
    // MARK: - Utils
    
    // MARK: submit
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
    
    // MARK: CheckForNewDay
    private func checkForNewDay() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            if viewModel.isNewDay() {
                viewModel.fetchTodayWord(forceRefresh: true, fullReset: true)
            }
        }
    }
    
    // MARK: Toast
    private func showToast(_ message: String) {
        toastMessage = message
        showToast = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showToast = false
        }
    }
}
