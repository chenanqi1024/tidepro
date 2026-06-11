//
//  SleepTimerController.swift
//  tidepro
//

import Combine
import Foundation

@MainActor
final class SleepTimerController: ObservableObject {
    @Published private(set) var wakeDate: Date?
    @Published private(set) var remainingSeconds = 0
    @Published private(set) var isCountingDown = false
    @Published var shouldShowAlarm = false

    private var timer: Timer?
    private var alarmStopDate: Date?

    func start(wakeTime: Date, alarm: SoundItem?, audioManager: AudioManager) {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: wakeTime)
        let minute = calendar.component(.minute, from: wakeTime)
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        components.second = 0

        var nextWakeDate = calendar.date(from: components) ?? Date()
        if nextWakeDate <= Date() {
            nextWakeDate = calendar.date(byAdding: .day, value: 1, to: nextWakeDate) ?? nextWakeDate.addingTimeInterval(24 * 60 * 60)
        }

        wakeDate = nextWakeDate
        alarmStopDate = nil
        isCountingDown = true
        shouldShowAlarm = false
        tick(alarm: alarm, audioManager: audioManager)
        scheduleTimer(alarm: alarm, audioManager: audioManager)
    }

    func cancel() {
        timer?.invalidate()
        timer = nil
        wakeDate = nil
        alarmStopDate = nil
        remainingSeconds = 0
        isCountingDown = false
        shouldShowAlarm = false
    }

    func stopAlarm(audioManager: AudioManager) {
        audioManager.stop(context: .alarm)
        cancel()
    }

    private func scheduleTimer(alarm: SoundItem?, audioManager: AudioManager) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self, weak audioManager] _ in
            guard let controller = self, let audioManager else { return }
            Task { @MainActor in
                controller.tick(alarm: alarm, audioManager: audioManager)
            }
        }
    }

    private func tick(alarm: SoundItem?, audioManager: AudioManager) {
        if let alarmStopDate {
            if Date() >= alarmStopDate {
                stopAlarm(audioManager: audioManager)
            }
            return
        }

        guard let wakeDate else { return }
        remainingSeconds = max(0, Int(wakeDate.timeIntervalSinceNow.rounded(.up)))

        if Date() >= wakeDate {
            triggerAlarm(alarm: alarm, audioManager: audioManager)
        }
    }

    private func triggerAlarm(alarm: SoundItem?, audioManager: AudioManager) {
        isCountingDown = false
        remainingSeconds = 0
        shouldShowAlarm = true
        alarmStopDate = Date().addingTimeInterval(20 * 60)

        audioManager.stop()
        if let alarm {
            audioManager.play(alarm, context: .alarm, loop: true)
        }
    }
}
