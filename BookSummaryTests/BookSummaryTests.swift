//
//  BookSummaryTests.swift
//  BookSummaryTests
//
//  Created by Olya Lutsyk on 15.09.2024.
//

import XCTest
import ComposableArchitecture
@testable import BookSummary


final class AppFeatureTests: XCTestCase {
    let store = TestStore(
        initialState: AppFeature.State(book: Book.mockData),
        reducer: { AppFeature() }
    )

    func testOnAppearLoadsDataSuccessfully() async {
        await store.send(.onAppear) {
            $0.isLoading = true
            $0.errorMessage = nil
        }
        
        await store.receive(.finishLoading) {
            $0.isLoading = false
            $0.player = BookPlayerFeature.State(book: $0.book)
        }
        await store.finish()
    }
}
