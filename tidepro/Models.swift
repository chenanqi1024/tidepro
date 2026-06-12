//
//  Models.swift
//  tidepro
//

import Foundation

struct SoundResponse: Decodable {
    let alarm: SoundItem
    let sounds: [SoundItem]
}

struct SoundItem: Identifiable, Decodable, Hashable {
    let id: String
    let name: String
    let url: String
    let cover: String

    var audioURL: URL? {
        URL(string: url)
    }

    var coverURL: URL? {
        guard !cover.isEmpty else { return nil }
        return URL(string: cover)
    }
}

enum LoadState: Equatable {
    case idle
    case loading
    case loaded
    case failed(String)
}

enum PlaybackContext: String {
    case sleep
    case focus
    case alarm
}

struct BreathingExercise: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let phases: [BreathingPhase]
}

struct BreathingPhase: Identifiable, Hashable {
    let id = UUID()
    let kind: BreathingPhaseKind
    let duration: Int
}

enum BreathingPhaseKind: String, Hashable {
    case inhale = "吸气"
    case hold = "屏息"
    case exhale = "呼气"
}

struct MeditationItem: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let systemImage: String
    let minutes: Int
    let paragraphs: [String]
}
