//
//  FocusView.swift
//  tidepro
//

import Combine
import SwiftUI

enum FocusMode: String, CaseIterable, Identifiable {
    case short = "25/5"
    case long = "50/10"

    var id: String { rawValue }

    var focusDuration: Int {
        switch self {
        case .short: 25 * 60
        case .long: 50 * 60
        }
    }

    var restDuration: Int {
        switch self {
        case .short: 5 * 60
        case .long: 10 * 60
        }
    }
}

enum FocusStage: String {
    case focus = "专注"
    case rest = "休息"
}

@MainActor
final class FocusTimerController: ObservableObject {
    @Published var mode: FocusMode = .short {
        didSet { resetForMode() }
    }
    @Published private(set) var stage: FocusStage = .focus
    @Published private(set) var remainingSeconds = FocusMode.short.focusDuration
    @Published private(set) var isRunning = false
    @Published private(set) var failedMessage: String?

    private var timer: Timer?

    var totalSeconds: Int {
        stage == .focus ? mode.focusDuration : mode.restDuration
    }

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1 - Double(remainingSeconds) / Double(totalSeconds)
    }

    func start(sound: SoundItem?, audioManager: AudioManager) {
        guard !isRunning else { return }
        isRunning = true
        failedMessage = nil
        playFocusSoundIfNeeded(sound: sound, audioManager: audioManager)
        scheduleTimer(sound: sound, audioManager: audioManager)
    }

    func pause(audioManager: AudioManager) {
        isRunning = false
        timer?.invalidate()
        timer = nil
        audioManager.stop(context: .focus)
    }

    func finish(audioManager: AudioManager) {
        pause(audioManager: audioManager)
        stage = .focus
        remainingSeconds = mode.focusDuration
    }

    func failForImmersion(audioManager: AudioManager) {
        guard isRunning, stage == .focus else { return }
        failedMessage = "沉浸模式已开启，本次专注因进入后台而失败。"
        finish(audioManager: audioManager)
    }

    func clearFailure() {
        failedMessage = nil
    }

    private func scheduleTimer(sound: SoundItem?, audioManager: AudioManager) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self, weak audioManager] _ in
            guard let controller = self, let audioManager else { return }
            Task { @MainActor in
                controller.tick(sound: sound, audioManager: audioManager)
            }
        }
    }

    private func tick(sound: SoundItem?, audioManager: AudioManager) {
        guard isRunning else { return }

        if remainingSeconds > 0 {
            remainingSeconds -= 1
            return
        }

        switch stage {
        case .focus:
            stage = .rest
            remainingSeconds = mode.restDuration
            audioManager.stop(context: .focus)
        case .rest:
            stage = .focus
            remainingSeconds = mode.focusDuration
            playFocusSoundIfNeeded(sound: sound, audioManager: audioManager)
        }
    }

    private func playFocusSoundIfNeeded(sound: SoundItem?, audioManager: AudioManager) {
        guard stage == .focus, let sound else { return }
        audioManager.play(sound, context: .focus, loop: true)
    }

    private func resetForMode() {
        guard !isRunning else { return }
        stage = .focus
        remainingSeconds = mode.focusDuration
    }
}

struct FocusView: View {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var soundStore: SoundLibraryStore
    @EnvironmentObject private var audioManager: AudioManager

    @StateObject private var timer = FocusTimerController()
    @State private var selectedSound: SoundItem?
    @State private var immersionMode = false
    @State private var showFailureAlert = false

    var body: some View {
        LoadingStateView(
            state: soundStore.state,
            retry: {
                Task { await soundStore.load() }
            },
            content: {
                AnyView(content)
            }
        )
        .dreamBackground()
        .onAppear(perform: ensureSelectedSound)
        .onChange(of: soundStore.sounds) { _, _ in
            ensureSelectedSound()
        }
        .onChange(of: scenePhase) { _, phase in
            guard immersionMode, phase != .active else { return }
            timer.failForImmersion(audioManager: audioManager)
            showFailureAlert = timer.failedMessage != nil
        }
        .alert("专注失败", isPresented: $showFailureAlert) {
            Button("知道了") {
                timer.clearFailure()
            }
        } message: {
            Text(timer.failedMessage ?? "")
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                DreamHeader(
                    title: "专注",
                    subtitle: "用节奏和背景声，守住一段完整心流。",
                    systemImage: "scope"
                )

                VStack(spacing: 16) {
                    timerPanel
                    soundPanel
                }
                .padding(16)
                .frame(maxWidth: 680)
                .frame(maxWidth: .infinity)
            }
            .padding(.bottom, 28)
        }
    }

    private var timerPanel: some View {
        VStack(spacing: 22) {
            SectionLabel(title: "番茄钟", detail: timer.mode.rawValue, systemImage: "timer")

            Picker("番茄钟模式", selection: $timer.mode) {
                ForEach(FocusMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            ZStack {
                Circle()
                    .stroke(AppTheme.border.opacity(0.72), lineWidth: 12)

                Circle()
                    .trim(from: 0, to: max(0.012, timer.progress))
                    .stroke(
                        timer.stage == .focus ? AppTheme.ocean : AppTheme.mint,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.35), value: timer.progress)

                VStack(spacing: 8) {
                    Text(timer.stage.rawValue)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(timer.stage == .focus ? AppTheme.ocean : AppTheme.mint)

                    Text(formattedTime(timer.remainingSeconds))
                        .font(.system(size: 46, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(AppTheme.ink)
                        .minimumScaleFactor(0.70)
                }
            }
            .frame(width: 220, height: 220)

            Toggle(isOn: $immersionMode) {
                VStack(alignment: .leading, spacing: 3) {
                    Label("沉浸模式", systemImage: "lock.fill")
                        .font(.headline)
                        .foregroundStyle(AppTheme.ink)
                    Text("专注期间离开 App 将结束本次计时")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
            .tint(AppTheme.ocean)

            HStack(spacing: 10) {
                ControlButton(
                    timer.isRunning ? "暂停" : "开始",
                    systemImage: timer.isRunning ? "pause.fill" : "play.fill"
                ) {
                    timer.isRunning
                    ? timer.pause(audioManager: audioManager)
                    : timer.start(sound: selectedSound, audioManager: audioManager)
                }

                ControlButton("结束", systemImage: "stop.fill", isProminent: false) {
                    timer.finish(audioManager: audioManager)
                }
            }
        }
        .glassPanel()
    }

    private var soundPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionLabel(
                title: "背景音",
                detail: selectedSound?.name ?? "未选择",
                systemImage: "waveform"
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(soundStore.sounds) { sound in
                        Button {
                            selectedSound = sound
                        } label: {
                            VStack(spacing: 8) {
                                SquareCoverView(sound: sound, cornerRadius: 18)
                                    .frame(width: 72, height: 72)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .stroke(selectedSound == sound ? AppTheme.ocean : .clear, lineWidth: 3)
                                    )
                                    .overlay(alignment: .topTrailing) {
                                        if selectedSound == sound {
                                            Image(systemName: "checkmark")
                                                .font(.caption.bold())
                                                .foregroundStyle(.white)
                                                .frame(width: 24, height: 24)
                                                .background(AppTheme.ocean, in: Circle())
                                                .offset(x: 5, y: -5)
                                        }
                                    }

                                Text(sound.name)
                                    .font(.caption)
                                    .foregroundStyle(selectedSound == sound ? AppTheme.ink : AppTheme.secondaryText)
                                    .lineLimit(1)
                                    .frame(width: 78)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .glassPanel()
    }

    private func ensureSelectedSound() {
        if selectedSound == nil {
            selectedSound = soundStore.sounds.first
        }
    }
}
