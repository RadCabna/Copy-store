import SwiftUI

class OrientationManager: ObservableObject {
    @Published var isHorizontalLock = true
    
    static var shared: OrientationManager = .init()
    
    func lockToPortrait() {
        isHorizontalLock = true
    }
    
    func unlockAllOrientations() {
        isHorizontalLock = false
    }
}

struct RootView: View {
    @State private var status: LoaderStatus = .LOADING
    @ObservedObject private var nav: NavGuard = NavGuard.shared
    let url: URL = URL(string: "https://copystorewarr.pro/log")!
    
    @ObservedObject private var orientationManager: OrientationManager = OrientationManager.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                switch status {
                case .LOADING, .ERROR:
                    switch nav.currentScreen {
                    case .LOADING:
                        Loading()
                            .edgesIgnoringSafeArea(.all)
                    case .MAIN:
                        ContentView()
                    }
                case .DONE:
                    ZStack {
                        Color.black
                            .edgesIgnoringSafeArea(.all)
                        
                        GameLoader_1E6704B4Overlay(data: .init(url: url))
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .onAppear {
            Task {
                let result = await GameLoader_1E6704B4StatusChecker().checkStatus(url: url)
                if result {
                    orientationManager.unlockAllOrientations()
                    self.status = .DONE
                } else {
                    orientationManager.lockToPortrait()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            nav.currentScreen = .MAIN
                        }
                    }
                    self.status = .ERROR
                }
                print(result)
            }
        }
    }
}

#Preview {
    RootView()
}
