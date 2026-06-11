//
//  BreatheView.swift
//  tidepro
//

import Combine
import SwiftUI

@MainActor
final class BreathingTrainerController: ObservableObject {
    @Published private(set) var phaseIndex = 0
    @Published private(set) var remainingSeconds: Int
    @Published private(set) var elapsedSeconds = 0
    @Published private(set) var isRunning = false

    let exercise: BreathingExercise
    private var timer: Timer?

    init(exercise: BreathingExercise) {
        self.exercise = exercise
        self.remainingSeconds = exercise.phases.first?.duration ?? 0
    }

    var currentPhase: BreathingPhase {
        exercise.phases[phaseIndex]
    }

    var circleScale: CGFloat {
        let duration = max(1, currentPhase.duration)
        let elapsedInPhase = CGFloat(duration - remainingSeconds)
        let progress = min(max(elapsedInPhase / CGFloat(duration), 0), 1)

        switch currentPhase.kind {
        case .inhale:
            return 0.72 + progress * 0.34
        case .hold:
            return phaseIndex > 0 && exercise.phases[phaseIndex - 1].kind == .inhale ? 1.06 : 0.72
        case .exhale:
            return 1.06 - progress * 0.34
        }
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        scheduleTimer()
    }

    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    func finish() {
        pause()
        phaseIndex = 0
        elapsedSeconds = 0
        remainingSeconds = exercise.phases.first?.duration ?? 0
    }

    private func scheduleTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let controller = self else { return }
            Task { @MainActor in
                controller.tick()
            }
        }
    }

    private func tick() {
        guard isRunning else { return }
        elapsedSeconds += 1

        if remainingSeconds > 1 {
            remainingSeconds -= 1
        } else {
            advancePhase()
        }
    }

    private func advancePhase() {
        phaseIndex = (phaseIndex + 1) % exercise.phases.count
        remainingSeconds = currentPhase.duration
    }
}

struct BreatheView: View {
    private let exercises: [BreathingExercise] = [
        BreathingExercise(
            id: "box",
            title: "4-4-4-4",
            subtitle: "适合紧张、焦虑、需要快速冷静或稳住情绪。",
            phases: [
                BreathingPhase(kind: .inhale, duration: 4),
                BreathingPhase(kind: .hold, duration: 4),
                BreathingPhase(kind: .exhale, duration: 4),
                BreathingPhase(kind: .hold, duration: 4)
            ]
        ),
        BreathingExercise(
            id: "sleep",
            title: "4-7-8",
            subtitle: "适合睡前放松，帮助身体更快进入入眠状态。",
            phases: [
                BreathingPhase(kind: .inhale, duration: 4),
                BreathingPhase(kind: .hold, duration: 7),
                BreathingPhase(kind: .exhale, duration: 8)
            ]
        ),
        BreathingExercise(
            id: "balance",
            title: "5-5",
            subtitle: "适合日常减压、恢复平静与专注，随时可做。",
            phases: [
                BreathingPhase(kind: .inhale, duration: 5),
                BreathingPhase(kind: .exhale, duration: 5)
            ]
        )
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    DreamHeader(title: "呼吸", subtitle: "跟着缓慢的节奏，把注意力放回身体。")

                    ForEach(exercises) { exercise in
                        NavigationLink(value: exercise) {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text(exercise.title)
                                        .font(.title3.bold())
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.subheadline.weight(.semibold))
                                }
                                .foregroundStyle(AppTheme.ink)

                                Text(exercise.subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(AppTheme.ink.opacity(0.68))
                                    .multilineTextAlignment(.leading)
                            }
                            .glassPanel()
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 28)
            }
            .dreamBackground()
            .navigationTitle("呼吸")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: BreathingExercise.self) { exercise in
                BreathingTrainingView(exercise: exercise)
            }
        }
    }
}

struct BreathingTrainingView: View {
    @StateObject private var trainer: BreathingTrainerController

    init(exercise: BreathingExercise) {
        _trainer = StateObject(wrappedValue: BreathingTrainerController(exercise: exercise))
    }

    var body: some View {
        VStack(spacing: 30) {
            Spacer(minLength: 12)

            VStack(spacing: 8) {
                Text(trainer.exercise.title)
                    .font(.title.bold())
                    .foregroundStyle(AppTheme.ink)
                Text(trainer.currentPhase.kind.rawValue)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppTheme.lavender)
            }

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.lavender.opacity(0.76), AppTheme.mint.opacity(0.62)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: AppTheme.lavender.opacity(0.26), radius: 24, x: 0, y: 16)
                    .scaleEffect(trainer.circleScale)
                    .animation(.easeInOut(duration: 1), value: trainer.circleScale)

                Text("\(trainer.remainingSeconds)")
                    .font(.system(size: 58, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
            }
            .frame(width: 220, height: 220)

            VStack(spacing: 8) {
                Text("本次训练已进行")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.ink.opacity(0.64))
                Text(formattedTime(trainer.elapsedSeconds))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(AppTheme.ink)
            }
            .glassPanel()
            .padding(.horizontal)

            HStack(spacing: 12) {
                ControlButton(
                    trainer.isRunning ? "暂停" : "开始",
                    systemImage: trainer.isRunning ? "pause.fill" : "play.fill"
                ) {
                    trainer.isRunning ? trainer.pause() : trainer.start()
                }

                ControlButton("结束", systemImage: "stop.fill", isProminent: false) {
                    trainer.finish()
                }
            }

            Spacer(minLength: 24)
        }
        .padding(.horizontal)
        .dreamBackground()
        .navigationTitle("训练")
        .navigationBarTitleDisplayMode(.inline)
    }
}
