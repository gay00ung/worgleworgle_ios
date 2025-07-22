import SwiftUI

@main
struct worgleworgle_iosApp: App {
    init() {
        print("🚀 Worgle App Started!")
    }
    
    var body: some Scene {
        WindowGroup {
            WorgleScreen()
                .onAppear {
                    print("📱 WorgleScreen appeared")
                }
        }
    }
}