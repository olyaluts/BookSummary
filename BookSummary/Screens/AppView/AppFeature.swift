//
//  AppFeature.swift
//  BookSummary
//
//  Created by Olya Lutsyk on 15.09.2024.
//

import Foundation
import ComposableArchitecture


struct AppFeature: Reducer {
    struct State {
        var book: Book
        var errorMessage: String?
        var isLoading: Bool = false
        var player: BookPlayerFeature.State?
    }

    enum Action {
        case player(BookPlayerFeature.Action)

        case onAppear
        case onDisappear
        case retryButtonTapped

        case finishLoading
        case loadError(Error)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .player: return .none

            case .finishLoading:
                state.isLoading = false
                state.player = BookPlayerFeature.State(book: state.book)
                return .none

            case .onAppear, .retryButtonTapped:
                state.errorMessage = nil
                state.isLoading = true
                return .run { [book = state.book] send in
                    do {
                        // Simulate data loading (Replace this with actual logic)
                        try await Task.sleep(nanoseconds: 1_000_000_000)  // Simulate loading delay
                        await send(.finishLoading)
                    } catch {
                        await send(.loadError(error))
                    }
                }

            case .onDisappear:
                return .none

            case .loadError:
                state.isLoading = false
                state.errorMessage = "Error loading data. Please retry."
                return .none
            }
        }
        .ifLet(\.player, action: /Action.player) {
            BookPlayerFeature()
        }
    }
}
