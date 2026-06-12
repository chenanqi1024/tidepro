//
//  ContentView.swift
//  tidepro
//
//  Created by chenanqi on 2026/6/4.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var soundStore = SoundLibraryStore()
    @StateObject private var audioManager = AudioManager()
    @StateObject private var sleepTimer = SleepTimerController()

    var body: some View {
        TabView {
            SleepView()
                .tabItem {
                    Label("睡眠", systemImage: "moon.stars.fill")
                }

            FocusView()
                .tabItem {
                    Label("专注", systemImage: "scope")
                }

            BreatheView()
                .tabItem {
                    Label("呼吸", systemImage: "wind")
                }

            MeditateView()
                .tabItem {
                    Label("冥想", systemImage: "sparkles")
                }
        }
        .tint(AppTheme.ocean)
        .toolbarBackground(AppTheme.surface, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .environmentObject(soundStore)
        .environmentObject(audioManager)
        .environmentObject(sleepTimer)
        .alert("该起床了", isPresented: $sleepTimer.shouldShowAlarm) {
            Button("停止闹钟") {
                sleepTimer.stopAlarm(audioManager: audioManager)
            }
        }
        .task {
            await soundStore.loadIfNeeded()
        }
    }
}

#Preview {
    ContentView()
}
