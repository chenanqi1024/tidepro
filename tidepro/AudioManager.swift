//
//  AudioManager.swift
//  tidepro
//

import AVFoundation
import Combine
import MediaPlayer
import UIKit

@MainActor
final class AudioManager: ObservableObject {
    @Published private(set) var currentTrack: SoundItem?
    @Published private(set) var currentContext: PlaybackContext?
    @Published private(set) var isPlaying = false

    private var player: AVPlayer?
    private var endObserver: NSObjectProtocol?
    private var shouldLoop = false

    init() {
        configureAudioSession()
        configureRemoteCommands()
    }

    deinit {
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
    }

    func play(_ sound: SoundItem, context: PlaybackContext, loop: Bool = true) {
        guard let url = sound.audioURL else { return }

        if currentTrack == sound, currentContext == context {
            player?.play()
            isPlaying = true
            updateNowPlayingInfo(for: sound, isPlaying: true)
            return
        }

        removeEndObserver()
        shouldLoop = loop

        let item = AVPlayerItem(url: url)
        let nextPlayer = AVPlayer(playerItem: item)
        player = nextPlayer
        currentTrack = sound
        currentContext = context

        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                guard self.shouldLoop else {
                    self.stop()
                    return
                }
                self.player?.seek(to: .zero)
                self.player?.play()
                self.isPlaying = true
            }
        }

        nextPlayer.play()
        isPlaying = true
        updateNowPlayingInfo(for: sound, isPlaying: true)
    }

    func toggle(_ sound: SoundItem, context: PlaybackContext, loop: Bool = true) {
        if currentTrack == sound, currentContext == context {
            isPlaying ? pause() : resume()
        } else {
            play(sound, context: context, loop: loop)
        }
    }

    func pause() {
        player?.pause()
        isPlaying = false
        if let currentTrack {
            updateNowPlayingInfo(for: currentTrack, isPlaying: false)
        }
    }

    func resume() {
        guard player != nil else { return }
        player?.play()
        isPlaying = true
        if let currentTrack {
            updateNowPlayingInfo(for: currentTrack, isPlaying: true)
        }
    }

    func stop() {
        player?.pause()
        player = nil
        removeEndObserver()
        currentTrack = nil
        currentContext = nil
        isPlaying = false
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    func stop(context: PlaybackContext) {
        guard currentContext == context else { return }
        stop()
    }

    func isCurrent(_ sound: SoundItem, context: PlaybackContext) -> Bool {
        currentTrack == sound && currentContext == context
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.allowAirPlay])
            try session.setActive(true)
            UIApplication.shared.beginReceivingRemoteControlEvents()
        } catch {
            assertionFailure("Audio session setup failed: \(error.localizedDescription)")
        }
    }

    private func configureRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.isEnabled = true

        commandCenter.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.resume()
            }
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.pause()
            }
            return .success
        }

        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.isPlaying ? self.pause() : self.resume()
            }
            return .success
        }
    }

    private func updateNowPlayingInfo(for sound: SoundItem, isPlaying: Bool) {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: sound.name,
            MPMediaItemPropertyArtist: "潮汐pro",
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]
    }

    private func removeEndObserver() {
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
            self.endObserver = nil
        }
    }
}
