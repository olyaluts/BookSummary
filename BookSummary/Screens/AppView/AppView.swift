//
//  AppView.swift
//  BookSummary
//
//  Created by Olya Lutsyk on 15.09.2024.
//

import Foundation
import ComposableArchitecture
import SwiftUI
import CasePaths

struct AppView: View {
    let store: StoreOf<AppFeature>
    @ObservedObject var viewStore: ViewStore<ViewState, AppFeature.Action>
    
    struct ViewState: Equatable {
        let isLoading: Bool
        let errorMessage: String?
        let showPlayer: Bool
        
        init(state: AppFeature.State) {
            self.isLoading = state.isLoading
            self.errorMessage = state.errorMessage
            self.showPlayer = state.showPlayer
        }
    }
    
    public init(store: StoreOf<AppFeature>) {
        self.store = store
        self.viewStore = ViewStore(self.store, observe: ViewState.init)
        
        let thumbImage = UIImage(systemName: "circle.fill")
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }
    
    var body: some View {
        VStack {
            if let errorMessage = viewStore.errorMessage {
                VStack {
                    Text(errorMessage)
                    Button("Retry", action: { viewStore.send(.retryButtonTapped) })
                }
            } else {
                if viewStore.isLoading {
                    ProgressView()
                } else {
                    if viewStore.showPlayer {
                        IfLetStore(
                            store.scope(
                                state: \.player,
                                action: \AppFeature.Action.Cases.player
                            ),
                            then: BookPlayerView.init(store:)
                        )
                    } else {
                        Text("Current Chapter: Chapter 1")
                            .padding()
                    }
                    
                    Spacer()
              
                    CustomToggle(isOn: viewStore.binding(
                        get: \.showPlayer,
                        send: AppFeature.Action.toggleChanged
                    ))
                    .padding(.bottom, 20)
                }
            }
        }
        .background(Color(
            red: 255 / 255,
            green: 248 / 255,
            blue: 243 / 255)
        )
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
    })
}
