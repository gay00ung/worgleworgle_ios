import SwiftUI

struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confettiPieces) { piece in
                    Circle()
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size)
                        .position(x: piece.x, y: piece.y)
                        .opacity(piece.opacity)
                        .rotationEffect(.degrees(piece.rotation))
                        .animation(
                            .easeOut(duration: piece.animationDuration)
                                .repeatCount(1, autoreverses: false),
                            value: piece.y
                        )
                }
            }
            .onAppear {
                createConfetti(in: geometry.size)
            }
        }
    }
    
    private func createConfetti(in size: CGSize) {
        confettiPieces = (0..<100).map { _ in
            ConfettiPiece(
                x: CGFloat.random(in: 0...size.width),
                y: -50,
                size: CGFloat.random(in: 8...16),
                color: [Color.red, Color.blue, Color.green, Color.yellow, Color.purple, Color.orange].randomElement()!,
                rotation: Double.random(in: 0...360),
                animationDuration: Double.random(in: 2...4),
                opacity: 1.0
            )
        }
        
        // Animate falling
        withAnimation {
            for index in confettiPieces.indices {
                confettiPieces[index].y = size.height + 100
                confettiPieces[index].x += CGFloat.random(in: -50...50)
                confettiPieces[index].rotation += Double.random(in: 180...720)
                confettiPieces[index].opacity = 0
            }
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let color: Color
    var rotation: Double
    let animationDuration: Double
    var opacity: Double
}