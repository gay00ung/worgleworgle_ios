import SwiftUI

struct SimilarityView: View {
    let similarity: Int
    let inputCount: Int
    let onNewWord: () -> Void
    
    @State private var countdown = 3
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 8) {
            if similarity == 100 {
                Text("🎉\(inputCount) 번 만에 정답을 맞추셨습니다!🎉")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.3))
                
                Text("\(countdown) 초 뒤에 새로운 단어로 갱신됩니다.")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.3))
            } else {
                Text("유사도는 \(similarity) 입니다.")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(similarity < 50 ? .red : .blue)
            }
        }
        .padding()
        .onAppear {
            if similarity == 100 {
                startCountdown()
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startCountdown() {
        countdown = 3
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer?.invalidate()
                onNewWord()
            }
        }
    }
}