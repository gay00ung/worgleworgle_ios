import SwiftUI

struct WordDefinitionView: View {
    let definition: String
    let isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("📘 단어의 뜻")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.3))
                Spacer()
            }
            
            if isLoading {
                Text("단어의 의미를 불러오는 중입니다...")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            } else {
                Text(definition)
                    .font(.system(size: 14))
                    .foregroundColor(.black.opacity(0.8))
                    .lineSpacing(4)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}