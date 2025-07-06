import SwiftUI

struct HintSection: View {
    let todayWord: String?
    let hintCount: Int
    let hintList: [String]
    @Binding var showingHint: Bool
    let onHintUsed: () -> Void
    let onAddHint: (String) -> Void
    
    @State private var currentHint = ""
    @State private var showToast = false
    @State private var toastMessage = ""
    
    var body: some View {
        VStack(spacing: 16) {
            // Hint button
            Button(action: {
                if let word = todayWord, hintCount < word.count {
                    onHintUsed()
                    let hint = generateHint(for: word, at: hintCount)
                    currentHint = hint
                    onAddHint(hint)
                    showingHint = true
                } else {
                    let hint = generateHint(for: todayWord ?? "", at: hintCount)
                        toastMessage = hint
                        showToast = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            showToast = false
                        }
                }
            }) {
                Text("🔎 힌트")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 1.0, green: 0.98, blue: 0.8))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0.2, green: 0.6, blue: 0.3))
                    .cornerRadius(8)
            }
            
            // Hint list
            if !hintList.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("🔍 힌트 목록")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.3))
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(Color(red: 0.2, green: 0.6, blue: 0.3).opacity(0.1))
                        .cornerRadius(8)
                    
                    ForEach(hintList.indices, id: \.self) { index in
                        Text(hintList[index])
                            .font(.system(size: 14))
                            .foregroundColor(.black.opacity(0.8))
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 0.2, green: 0.6, blue: 0.3), lineWidth: 1)
                            )
                    }
                }
            }
        }
        .alert("힌트 도착! 🎁", isPresented: $showingHint) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(currentHint)
        }
        .overlay(
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
        )
    }
    
    private func generateHint(for word: String, at index: Int) -> String {
        guard index < word.count else {
            return "✅ 오늘의 힌트가 모두 공개되었습니다!"
        }
        
        let character = word[word.index(word.startIndex, offsetBy: index)]
        let chosung = getChosung(character)
        
        if chosung == " " {
            return "📌 \(index + 1)번째 힌트 (\(index + 1)번째 글자의 초성): 띄어쓰기"
        } else {
            return "📌 \(index + 1)번째 힌트 (\(index + 1)번째 글자의 초성): \(chosung)"
        }
    }
}
