//
//  PlayerFeature.swift
//  BookSummary
//
//  Created by Olya Lutsyk on 15.09.2024.
//

import Foundation
import ComposableArchitecture
import Combine

@Reducer
struct BookPlayerFeature {
    @ObservableState
    struct State: Equatable {
        enum PlaybackSpeed: CaseIterable, Equatable {
            case x05
            case x075
            case x1
            case x15
            case x2
            
            var title: String {
                switch self {
                case .x05: return "x0.5"
                case .x075: return "x0.75"
                case .x1: return "x1"
                case .x15: return "x1.5"
                case .x2: return "x2"
                }
            }
            
            var speedMultiplier: Float {
                switch self {
                case .x05: return 0.5
                case .x075: return 0.75
                case .x1: return 1
                case .x15: return 1.5
                case .x2: return 2.0
                }
            }
        }
        
        let book: Book
        var currentChapterIndex = 0
        var currentChapter: BookChapter? {
            guard currentChapterIndex < book.chapters.count
            else { return nil }
            return book.chapters[currentChapterIndex]
        }
        
        var isPlaying: Bool = false
        var playbackPosition: PlaybackPosition
        var playbackSpeed: PlaybackSpeed = .x1
        
        init(book: Book) {
            self.book = book
            if let firstChapter = book.chapters.first {
                playbackPosition = .init(currentTime: 0, duration: firstChapter.duration)
            } else {
                playbackPosition = .init(currentTime: 0, duration: 0)
            }
        }
    }
    
    enum Action: Equatable {
        case audioPlayerClient(PlaybackState)
        case playButtonTapped
        case pauseButtonTapped
        case fastForwardButtonTapped
        case rewindButtonTapped
        case progressSliderMoved(Double)
        case nextChapterButtonTapped
        case previousChapterButtonTapped
        case speedButtonTapped
        case updateChapterIfNeeded
    }
    
    @Dependency(\.audioPlayer) var audioPlayer
    @Dependency(\.continuousClock) var clock
    private enum CancelID { case play, seek }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .audioPlayerClient(playback):
                switch playback {
                case let .playing(position):
                    state.playbackPosition = position
                    return .send(.updateChapterIfNeeded, animation: .default)
                case let .pause(position):
                    state.playbackPosition = position
                    return .none
                case .stop:
                    return .none
                case let .error(message):
                    print("Playback error: \(message.orEmpty())")
                    return .none
                case .finish:
                    state.playbackPosition = .init(
                        currentTime: state.currentChapter?.duration ?? 0,
                        duration: state.currentChapter?.duration ?? 0
                    )
                    return .send(.updateChapterIfNeeded, animation: .default)
                }
                
            case .playButtonTapped:
                state.isPlaying = true
                
                return .run { [fileName = state.currentChapter?.audioFileName,
                               playbackPosition = state.playbackPosition,
                               speed = state.playbackSpeed] send in
                    guard let fileName = fileName else {
                        print("Error: fileName is nil")
                        return
                    }
                    
                    guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
                        print("Error: Unable to find file with name \(fileName).mp3 in the bundle")
                        return
                    }
                    
                    do {
                        for await playback in try await self.audioPlayer.play(playbackPosition, url, speed.speedMultiplier) {
                            await send(.audioPlayerClient(playback))
                        }
                    } catch {
                        print("Error: Audio playback failed with error \(error.localizedDescription)")
                        await send(.audioPlayerClient(.error(error.localizedDescription)))
                    }
                }
                .cancellable(id: CancelID.play, cancelInFlight: true)
                
            case .pauseButtonTapped:
                state.isPlaying = false
                return .run { _ in
                    await audioPlayer.pause()
                }
                .merge(with: .cancel(id: CancelID.play))
                
            case .fastForwardButtonTapped:
                var playbackPosition = state.playbackPosition
                playbackPosition.currentTime += 10
                if playbackPosition.currentTime > playbackPosition.duration {
                    playbackPosition.currentTime = playbackPosition.duration
                }
                return .send(.progressSliderMoved(playbackPosition.progress))
            case .rewindButtonTapped:
                var playbackPosition = state.playbackPosition
                playbackPosition.currentTime -= 5
                if playbackPosition.currentTime < 0 {
                    playbackPosition.currentTime = 0
                }
                return .send(.progressSliderMoved(playbackPosition.progress))
            case let .progressSliderMoved(progress):
                var playbackPosition = state.playbackPosition
                playbackPosition.currentTime = progress * playbackPosition.duration
                state.playbackPosition = playbackPosition
                return .run { [playbackPosition] _ in
                    await audioPlayer.seekProgress(playbackPosition.progress)
                }
                .cancellable(id: CancelID.seek, cancelInFlight: true)
            case .nextChapterButtonTapped:
                state.playbackPosition = .init(
                    currentTime: state.currentChapter?.duration ?? 0,
                    duration: state.currentChapter?.duration ?? 0
                )
                return .send(.updateChapterIfNeeded)
            case .previousChapterButtonTapped:
                guard state.currentChapterIndex > 0 else { return .none }
                state.currentChapterIndex -= 1
                state.playbackPosition = .init(currentTime: 0, duration: state.currentChapter?.duration ?? 0)
                if state.isPlaying {
                    return .send(.playButtonTapped)
                }
                return .none
            case .speedButtonTapped:
                state.playbackSpeed = state.playbackSpeed == State.PlaybackSpeed.allCases.last
                    ? State.PlaybackSpeed.allCases.first ?? state.playbackSpeed
                    : State.PlaybackSpeed.allCases.first { $0.speedMultiplier > state.playbackSpeed.speedMultiplier }
                    ?? state.playbackSpeed

                return .run { [speed = state.playbackSpeed.speedMultiplier] send in
                    await audioPlayer.speed(speed)
                }

            case .updateChapterIfNeeded:
                if state.playbackPosition.progress == 1 {
                    state.currentChapterIndex = (state.currentChapterIndex + 1) % state.book.chapters.count
                    if state.currentChapterIndex == 0 {
                        state.isPlaying = false
                    }
                    state.playbackPosition = .init(currentTime: 0, duration: state.currentChapter?.duration ?? 0)
                    if state.isPlaying {
                        return .send(.playButtonTapped)
                    }
                }
                
                return .none
            }
        }
    }
}
