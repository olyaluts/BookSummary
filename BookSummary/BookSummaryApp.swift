//
//  BookSummaryApp.swift
//  BookSummary
//
//  Created by Olya Lutsyk on 15.09.2024.
//

import SwiftUI
import ComposableArchitecture

@main
struct SummaryPlayerTCAApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(initialState: AppFeature.State(book: Book.mockData)) {
                    AppFeature()
                }
            )
        }
    }
}
