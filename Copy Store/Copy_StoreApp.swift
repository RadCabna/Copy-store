//
//  Copy_StoreApp.swift
//  Copy Store
//
//  Created by Алкександр Степанов on 23.12.2025.
//

import SwiftUI

@main
struct Copy_StoreApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return OrientationManager.shared.isHorizontalLock ? .portrait : .allButUpsideDown
    }
}
