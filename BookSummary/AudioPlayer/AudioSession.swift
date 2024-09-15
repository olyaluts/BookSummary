//
//  AudioSession.swift
//  BookSummary
//
//  Created by Olya Lutsyk on 15.09.2024.
//

import Foundation
import AVFoundation
import ComposableArchitecture

struct AudioSession: DependencyKey {
    var enablePlayback: @Sendable (_ updateActivation: Bool) throws -> Void
    var disablePlayback: @Sendable (_ updateActivation: Bool) throws -> Void
    
    static var liveValue: AudioSession = {
        let isPlaybackActive = LockIsolated(false)
        
        return AudioSession(
            enablePlayback: { updateActivation in
                isPlaybackActive.setValue(true)
                if AVAudioSession.sharedInstance().category != .playAndRecord {
                    try AVAudioSession.sharedInstance().setCategory(.playAndRecord,
                                                                    mode: .default,
                                                                    options: [.allowBluetooth])
                }
                
                if updateActivation, isPlaybackActive.value {
                    try AVAudioSession.sharedInstance().setActive(true)
                }
            },
            disablePlayback: { updateActivation in
                isPlaybackActive.setValue(false)
                if AVAudioSession.sharedInstance().category == .playAndRecord {
                    try AVAudioSession.sharedInstance().setCategory(.record,
                                                                    mode: .default,
                                                                    options: [.allowBluetooth])
                }
                
                if updateActivation, !isPlaybackActive.value {
                    try AVAudioSession.sharedInstance().setActive(false)
                }
            }
        )
    }()
}

extension DependencyValues {
    var audioSession: AudioSession {
        get { self[AudioSession.self] }
        set { self[AudioSession.self] = newValue }
    }
}
