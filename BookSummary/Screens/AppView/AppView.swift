//
//  AppView.swift
//  BookSummary
//
//  Created by Olya Lutsyk on 15.09.2024.
//

import Foundation
import ComposableArchitecture
import SwiftUI

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
                state.player = BookPlayerFeature.State(bookSummary: state.book)
                return .none

            case .onAppear, .retryButtonTapped:
                state.errorMessage = nil
                state.isLoading = true
                return .run { [book = state.book] send in
                    do {
                        // Simulate data loading (Replace this with actual logic)
                        await Task.sleep(1_000_000_000)  // Simulate loading delay
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

struct AppView: View {
    let store: StoreOf<AppFeature>
    @ObservedObject var viewStore: ViewStore<ViewState, AppFeature.Action>

    struct ViewState: Equatable {
        let isLoading: Bool
        let errorMessage: String?

        init(state: AppFeature.State) {
            self.isLoading = state.isLoading
            self.errorMessage = state.errorMessage
        }
    }

    public init(store: StoreOf<AppFeature>) {
        self.store = store
        self.viewStore = ViewStore(self.store, observe: ViewState.init)

        let thumbImage = UIImage(systemName: "circle.fill")
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            if let errorMessage = viewStore.errorMessage {
                VStack {
                    Text(errorMessage)
                    Button("Retry", action: { viewStore.send(.retryButtonTapped) })
                }
            } else {
                if viewStore.isLoading {
                    ProgressView()
                } else {
                    IfLetStore(
                        self.store.scope(state: \.player, action: AppFeature.Action.player),
                        then: BookPlayerView.init(store:)
                    )
                }
            }
        }
        .onAppear {
            viewStore.send(.onAppear)
        }
        .onDisappear {
            viewStore.send(.onDisappear)
        }
    }
}

#Preview {
    AppView(store: Store(initialState: AppFeature.State(book: Book.mockData)) {
        AppFeature()
            ._printChanges()
    })
}
