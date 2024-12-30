//
//  Qui_es_tuApp.swift
//  Qui es tu
//
//  Created by Lucas on 20/12/2024.
//

import Firebase
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var quizzStore = QuizzStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(quizzStore)
        }
    }
}
