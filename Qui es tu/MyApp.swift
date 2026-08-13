//
//  Qui_es_tuApp.swift
//  Qui es tu
//
//  Created by Lucas on 20/12/2024.
//

import FirebaseCore
import Foundation
import SwiftUI

@MainActor
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        return true
    }
}

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    @State private var quizzStore: QuizzStore

    init() {
#if DEBUG
        let usesPreviewCatalog = ProcessInfo.processInfo.arguments.contains("-uiTesting")
        _quizzStore = State(
            initialValue: QuizzStore(
                quizzes: usesPreviewCatalog ? Quizz.previewCatalog : []
            )
        )
#else
        _quizzStore = State(initialValue: QuizzStore())
#endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(quizzStore)
        }
    }
}
