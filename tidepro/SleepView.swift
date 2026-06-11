//
//  SleepView.swift
//  tidepro
//

import SwiftUI

struct SleepView: View {
    @EnvironmentObject private var soundStore: SoundLibraryStore

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
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
            .navigationTitle("睡眠")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: SoundItem.self) { sound in
                SleepPlayerView(sound: sound)
            }
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 20) {
                DreamHeader(title: "睡眠", subtitle: "选一段柔软的白噪音，让夜晚慢慢安静下来。")

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(soundStore.sounds) { sound in
                        NavigationLink(value: sound) {
                            SoundGridCard(sound: sound)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
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
            VStack(spacing: 24) {
                SquareCoverView(sound: sound, cornerRadius: 32)
                    .overlay(AppTheme.dreamOverlay.opacity(0.22))
                    .padding(.horizontal)
                    .padding(.top, 12)

                VStack(spacing: 12) {
                    Text(sound.name)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.ink)
                        .multilineTextAlignment(.center)

                    ControlButton(
                        isPlayingThisSound ? "暂停" : "播放",
                        systemImage: isPlayingThisSound ? "pause.fill" : "play.fill"
                    ) {
                        audioManager.toggle(sound, context: .sleep, loop: true)
                    }
                }
                .glassPanel()
                .padding(.horizontal)

                timerPanel
                    .padding(.horizontal)
                    .padding(.bottom, 28)
            }
        }
        .dreamBackground()
        .navigationTitle("播放")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var timerPanel: some View {
        VStack(alignment: .leading, spacing: 18) {
            Label("睡眠定时", systemImage: "alarm.fill")
                .font(.headline)
                .foregroundStyle(AppTheme.ink)

            DatePicker("醒来时间", selection: $wakeTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.compact)
                .tint(AppTheme.lavender)

            if sleepTimer.isCountingDown {
                VStack(alignment: .leading, spacing: 6) {
                    Text("剩余时间")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.ink.opacity(0.64))
                    Text(formattedTime(sleepTimer.remainingSeconds))
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.lavender)
                }
            }

            HStack(spacing: 12) {
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
