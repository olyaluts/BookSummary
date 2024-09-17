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
    
    public init(store: StoreOf<AppFeature>) {
        self.store = store
        
        let thumbImage = UIImage(systemName: "circle.fill")
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                if let errorMessage = store.errorMessage {
                    VStack {
                        Text(errorMessage)
                        Button("Retry", action: { store.send(.retryButtonTapped) })
                    }
                } else {
                    if store.isLoading {
                        ProgressView()
                    } else {
                        if store.showPlayer {
                            IfLetStore(
                                store.scope(
                                    state: \.player,
                                    action: \AppFeature.Action.Cases.player
                                ),
                                then: BookPlayerView.init(store:)
                            )
                        } else {
                            if let currentChapterText = store.player?.currentChapter?.title
                            {
                                Text(currentChapterText)
                                    .padding()
                            }
                        }
                        
                        Spacer()
                        CustomToggle(isOn: Binding(
                            get: { store.showPlayer },
                            set: { store.send(.toggleChanged($0)) }
                        ))
                        .padding(.bottom, 20)
                    }
                }
            }
            .background(store.showPlayer ? Color(red: 255 / 255, green: 248 / 255, blue: 243 / 255) : .white
            )
            .onAppear {
                store.send(.onAppear)
            }
            .onDisappear {
                store.send(.onDisappear)
            }
        }
    }
}

#Preview {
    AppView(store: Store(initialState: AppFeature.State(book: Book.mockData)) {
        AppFeature()
    })
}
