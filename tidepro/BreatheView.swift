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
                VStack(spacing: 0) {
                    DreamHeader(
                        title: "呼吸",
                        subtitle: "跟着缓慢的节奏，把注意力放回身体。",
                        systemImage: "wind"
                    )

                    VStack(alignment: .leading, spacing: 14) {
                        SectionLabel(title: "选择节奏", detail: "\(exercises.count) 种练习", systemImage: "lungs.fill")

                        ForEach(exercises) { exercise in
                            NavigationLink(value: exercise) {
                                HStack(spacing: 15) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .fill(exercise.accentGradient)
                                        Image(systemName: exercise.systemImage)
                                            .font(.system(size: 25, weight: .semibold))
                                            .foregroundStyle(.white)
                                    }
                                    .frame(width: 64, height: 72)

                                    VStack(alignment: .leading, spacing: 7) {
                                        Text(exercise.title)
                                            .font(.headline)
                                            .foregroundStyle(AppTheme.ink)
                                        Text(exercise.subtitle)
                                            .font(.subheadline)
                                            .foregroundStyle(AppTheme.secondaryText)
                                            .lineLimit(2)

                                        Text(exercise.phaseSummary)
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(AppTheme.ocean)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                    Image(systemName: "chevron.right")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(AppTheme.secondaryText.opacity(0.72))
                                }
                                .padding(14)
                                .surfacePanel()
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: 680)
                    .frame(maxWidth: .infinity)
                }
                .padding(.bottom, 28)
            }
            .dreamBackground()
            .toolbar(.hidden, for: .navigationBar)
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
        ScrollView {
            VStack(spacing: 22) {
                VStack(spacing: 7) {
                    Text(trainer.exercise.title)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.ink)
                    Text(trainer.exercise.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText)
                        .multilineTextAlignment(.center)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(trainer.exercise.phases.enumerated()), id: \.offset) { index, phase in
                            Text("\(phase.kind.rawValue) \(phase.duration)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(index == trainer.phaseIndex ? .white : AppTheme.secondaryText)
                                .padding(.horizontal, 11)
                                .frame(minHeight: 32)
                                .background(
                                    index == trainer.phaseIndex ? AppTheme.ocean : AppTheme.surface,
                                    in: Capsule()
                                )
                        }
                    }
                }

                ZStack {
                    Circle()
                        .stroke(AppTheme.border.opacity(0.70), lineWidth: 1)
                        .frame(width: 238, height: 238)

                    Circle()
                        .fill(trainer.exercise.accentGradient)
                        .shadow(color: AppTheme.ocean.opacity(0.22), radius: 24, x: 0, y: 14)
                        .scaleEffect(trainer.circleScale)
                        .animation(.easeInOut(duration: 1), value: trainer.circleScale)

                    VStack(spacing: 4) {
                        Text(trainer.currentPhase.kind.rawValue)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white.opacity(0.86))
                        Text("\(trainer.remainingSeconds)")
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .monospacedDigit()
                    }
                }
                .frame(width: 220, height: 220)

                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("本次训练")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.secondaryText)
                        Text(formattedTime(trainer.elapsedSeconds))
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(AppTheme.ink)
                    }
                    Spacer()
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 28))
                        .foregroundStyle(AppTheme.ocean)
                }
                .glassPanel()

                HStack(spacing: 10) {
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
            }
            .padding(16)
            .frame(maxWidth: 620)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 28)
        }
        .dreamBackground()
        .toolbar(.visible, for: .navigationBar)
        .navigationTitle("训练")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension BreathingExercise {
    var systemImage: String {
        switch id {
        case "box": return "square.grid.2x2.fill"
        case "sleep": return "moon.fill"
        default: return "heart.fill"
        }
    }

    var accentColors: [Color] {
        switch id {
        case "box": return [AppTheme.ocean, AppTheme.indigo]
        case "sleep": return [AppTheme.indigo, AppTheme.coral]
        default: return [AppTheme.mint, AppTheme.ocean]
        }
    }

    var accentGradient: LinearGradient {
        LinearGradient(colors: accentColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var phaseSummary: String {
        phases.map { "\($0.kind.rawValue.prefix(1)) \($0.duration)" }.joined(separator: "  ·  ")
    }
}
