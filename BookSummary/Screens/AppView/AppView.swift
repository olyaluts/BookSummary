//
//  AppView.swift
//  BookSummary
//
//  Created by Olya Lutsyk on 15.09.2024.
//

import Foundation
import ComposableArchitecture
import SwiftUI


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
