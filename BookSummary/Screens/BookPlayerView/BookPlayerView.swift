//
//  PlayerView.swift
//  BookSummary
//
//  Created by Olya Lutsyk on 15.09.2024.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct BookPlayerView: View {
    let store: StoreOf<BookPlayerFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            let duration = viewStore.state.playbackPosition.duration
            let currentTime = viewStore.state.playbackPosition.currentTime
            let timeLeft = viewStore.state.playbackPosition.duration - currentTime
            
            VStack(alignment: .center) {
                Image(viewStore.bookSummary.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.vertical, 24)
                    .padding(.horizontal, 65)
                    .cornerRadius(5.0)
                
                Text("KEY POINT \(viewStore.currentChapterIndex + 1) OF \(viewStore.bookSummary.chapters.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(6)
                
                Text((viewStore.currentChapter?.title).orEmpty())
                    .font(.callout)
                    .fontWeight(.light)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .frame(height: 80)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                Spacer(minLength: 24)
                HStack(spacing: 12) {
                    dateComponentsFormatter.string(from: currentTime)
                        .map {
                            Text($0)
                                .font(.footnote.monospacedDigit())
                                .foregroundColor(Color(.systemGray))
                        }
                    Slider(
                        value: viewStore.binding(
                            get: { $0.playbackPosition.progress },
                            send: BookPlayerFeature.Action.progressSliderMoved
                        )
                    )
                    .disabled(duration == 0)
                    
                    dateComponentsFormatter
                        .string(from: timeLeft)
                        .map {
                            Text($0)
                                .font(.footnote.monospacedDigit())
                                .foregroundColor(Color(.systemGray))
                        }
                }
                .buttonStyle(.borderless)
                .padding()
                
                Button(action: {
                    viewStore.send(.speedButtonTapped)
                }, label: {
                    Text("Speed \(viewStore.state.playbackSpeed.title)")
                })
                .font(.callout)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .buttonStyle(.bordered)
                
                Spacer(minLength: 32)
            
                HStack(spacing: 24) {
                    Button {
                        viewStore.send(.previousChapterButtonTapped)
                    } label: {
                        Image(systemName: "backward.end.fill")
                            .font(.system(size: 24))
                    }
                    .tint(.primary)
                    .disabled(viewStore.currentChapterIndex == 0)
                    
                    Button {
                        viewStore.send(.rewindButtonTapped)
                    } label: {
                        Image(systemName: "gobackward.5")
                            .font(.system(size: 32))
                    }
                    .tint(.primary)
                    
                    Button {
                        if viewStore.state.isPlaying {
                            viewStore.send(.pauseButtonTapped)
                        } else {
                            viewStore.send(.playButtonTapped)
                        }
                    } label: {
                        Image(systemName: viewStore.state.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 32))
                    }
                    .tint(.primary)
                    
                    Button {
                        viewStore.send(.fastForwardButtonTapped)
                    } label: {
                        Image(systemName: "goforward.10")
                            .font(.system(size: 32))
                    }
                    .tint(.primary)
                    
                    Button {
                        viewStore.send(.nextChapterButtonTapped)
                    } label: {
                        Image(systemName: "forward.end.fill")
                            .font(.system(size: 24))
                    }
                    .tint(.primary)
                    .disabled(viewStore.currentChapterIndex == (viewStore.bookSummary.chapters.count - 1))
                }
                
                Spacer(minLength: 70)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(
                red: 255 / 255,
                green: 248 / 255,
                blue: 243 / 255)
            )
        }
    }
}

// MARK: Preview

#Preview {
    MainActor.assumeIsolated {
        NavigationStack {
            BookPlayerView(
                store: Store(initialState: BookPlayerFeature.State(
                    bookSummary: Book.mockData)) {
                        BookPlayerFeature()
                    }
            )
        }
    }
}
