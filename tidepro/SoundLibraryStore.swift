//
//  SoundLibraryStore.swift
//  tidepro
//

import Combine
import Foundation

@MainActor
final class SoundLibraryStore: ObservableObject {
    @Published private(set) var alarm: SoundItem?
    @Published private(set) var sounds: [SoundItem] = []
    @Published private(set) var state: LoadState = .idle

    private let apiURL = URL(string: "https://zzz-pet.oss-cn-hangzhou.aliyuncs.com/api/sounds.json")!

    func loadIfNeeded() async {
        guard state == .idle || sounds.isEmpty else { return }
        await load()
    }

    func load() async {
        state = .loading

        do {
            var request = URLRequest(url: apiURL)
            request.timeoutInterval = 20

            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                throw URLError(.badServerResponse)
            }

            let payload = try JSONDecoder().decode(SoundResponse.self, from: data)
            alarm = payload.alarm
            sounds = payload.sounds
            state = .loaded
        } catch {
            state = .failed("声音加载失败，请检查网络后重试。")
        }
    }
}
