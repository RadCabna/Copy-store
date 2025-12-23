import SwiftUI

class OrientationManager: ObservableObject  {
    @Published var isHorizontalLock = true
    
    static var shared: OrientationManager = .init()
}

struct RootView: View {
    @ObservedObject private var nav: NavGuard = NavGuard.shared
    @ObservedObject private var orientationManager: OrientationManager = OrientationManager.shared
    
    var body: some View {
        ZStack {
            switch nav.currentScreen {
            case .LOADING:
                Loading()
            case .ONBOARDING:
                Onboarding()
            case .MAIN:
                ContentView()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    nav.currentScreen = .MAIN
                }
            }
        }
    }
}

#Preview {
    RootView()
}
