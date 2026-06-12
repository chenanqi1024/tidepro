//
//  SleepView.swift
//  tidepro
//

import SwiftUI

struct SleepView: View {
    @EnvironmentObject private var soundStore: SoundLibraryStore

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
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
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: SoundItem.self) { sound in
                SleepPlayerView(sound: sound)
            }
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                DreamHeader(
                    title: "睡眠",
                    subtitle: "选一段柔软的声音，让夜晚慢慢安静下来。",
                    systemImage: "moon.stars.fill"
                )

                VStack(alignment: .leading, spacing: 14) {
                    SectionLabel(title: "环境声音", detail: "\(soundStore.sounds.count) 种", systemImage: "waveform")

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(soundStore.sounds) { sound in
                            NavigationLink(value: sound) {
                                SoundGridCard(sound: sound)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
            }
            .padding(.bottom, 28)
        }
    }
}

struct SleepPlayerView: View {
    @EnvironmentObject private var soundStore: SoundLibraryStore
    @EnvironmentObject private var audioManager: AudioManager
    @EnvironmentObject private var sleepTimer: SleepTimerController

    let sound: SoundItem

    @State private var wakeTime = Calendar.current.date(byAdding: .hour, value: 8, to: Date()) ?? Date()

    private var isPlayingThisSound: Bool {
        audioManager.isCurrent(sound, context: .sleep) && audioManager.isPlaying
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                SquareCoverView(sound: sound, cornerRadius: 24)
                    .overlay {
                        LinearGradient(
                            colors: [.clear, AppTheme.ink.opacity(0.46)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                    .overlay(alignment: .bottomLeading) {
                        Label(isPlayingThisSound ? "正在播放" : "准备播放", systemImage: "waveform")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 11)
                            .frame(minHeight: 30)
                            .background(.ultraThinMaterial, in: Capsule())
                            .padding(14)
                    }
                    .frame(maxWidth: 420)
                    .shadow(color: AppTheme.ink.opacity(0.18), radius: 20, x: 0, y: 12)

                VStack(spacing: 16) {
                    VStack(spacing: 6) {
                        Text(sound.name)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.ink)
                            .multilineTextAlignment(.center)

                        Text("循环播放 · 切换页面后仍会继续")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.secondaryText)
                            .multilineTextAlignment(.center)
                    }

                    RoundControlButton(
                        systemImage: isPlayingThisSound ? "pause.fill" : "play.fill",
                        accessibilityLabel: isPlayingThisSound ? "暂停" : "播放"
                    ) {
                        audioManager.toggle(sound, context: .sleep, loop: true)
                    }
                }
                .glassPanel()

                timerPanel
            }
            .padding(16)
            .frame(maxWidth: 620)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 28)
        }
        .dreamBackground()
        .toolbar(.visible, for: .navigationBar)
        .navigationTitle("睡眠播放")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var timerPanel: some View {
        VStack(alignment: .leading, spacing: 18) {
            SectionLabel(title: "睡眠定时", detail: "按醒来时间", systemImage: "alarm.fill")

            VStack(alignment: .leading, spacing: 8) {
                Text("醒来时间")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.secondaryText)

                DatePicker("醒来时间", selection: $wakeTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .tint(AppTheme.ocean)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if sleepTimer.isCountingDown {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("距离醒来还有")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.secondaryText)
                        Text(formattedTime(sleepTimer.remainingSeconds))
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(AppTheme.ocean)
                            .minimumScaleFactor(0.72)
                    }
                    Spacer()
                    Image(systemName: "moon.zzz.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(AppTheme.indigo)
                }
                .padding(14)
                .background(AppTheme.canvas, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            HStack(spacing: 10) {
                ControlButton(
                    sleepTimer.isCountingDown ? "重新开始" : "开始倒计时",
                    systemImage: "timer"
                ) {
                    sleepTimer.start(wakeTime: wakeTime, alarm: soundStore.alarm, audioManager: audioManager)
                }

                if sleepTimer.isCountingDown {
                    ControlButton("取消", systemImage: "xmark", isProminent: false) {
                        sleepTimer.cancel()
                    }
                }
            }
        }
        .glassPanel()
    }
}
