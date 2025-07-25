import SwiftUI

struct InputSection: View {
    @Binding var userInput: String
    @FocusState var isInputFocused: Bool
    let onSubmit: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .leading) {
                if userInput.isEmpty {
                    Text("단어를 입력하세요!")
                        .foregroundColor(Color(UIColor.lightGray))  // placeholder 색상
                        .padding(.horizontal)
                }
                
                TextField("", text: $userInput)
                    .textFieldStyle(.plain)
                    .foregroundColor(.black)  // 입력 텍스트 색상
                    .accentColor(Color(red: 0.2, green: 0.6, blue: 0.3))  // 커서 색상
                    .padding()
            }
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(red: 0.2, green: 0.6, blue: 0.3), lineWidth: 2)
            )
            .focused($isInputFocused)
            .onSubmit {
                onSubmit()
            }
            
            Button(action: onSubmit) {
                Text("입력")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 1.0, green: 0.98, blue: 0.8))
                    .frame(width: 80, height: 48)
                    .background(Color(red: 0.2, green: 0.6, blue: 0.3))
                    .cornerRadius(12)
            }
        }
    }
}