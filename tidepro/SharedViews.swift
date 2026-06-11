//
//  SharedViews.swift
//  tidepro
//

import SwiftUI

struct LoadingStateView: View {
    let state: LoadState
    let retry: () -> Void
    let content: () -> AnyView

    var body: some View {
        switch state {
        case .idle, .loading:
            VStack(spacing: 14) {
                ProgressView()
                    .tint(AppTheme.lavender)
                Text("声音加载中")
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .failed(let message):
            VStack(spacing: 18) {
                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(AppTheme.lavender)
                Text(message)
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)
                    .multilineTextAlignment(.center)
                Button(action: retry) {
                    Label("重试", systemImage: "arrow.clockwise")
                }
                .primaryCapsule()
            }
            .glassPanel()
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .loaded:
            content()
        }
    }
}

struct DreamHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.ink)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(AppTheme.ink.opacity(0.68))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top, 14)
    }
}

struct SquareCoverView: View {
    let sound: SoundItem
    var cornerRadius: CGFloat = 24

    var body: some View {
        ZStack {
            if let coverURL = sound.coverURL {
                AsyncImage(url: coverURL) { phase in
                    switch phase {
                    case .empty:
                        placeholder
                            .overlay(ProgressView().tint(.white))
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        placeholder
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.title2)
                                    .foregroundStyle(.white.opacity(0.86))
                            )
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    private var placeholder: some View {
        LinearGradient(
            colors: [AppTheme.lavender, AppTheme.mint, AppTheme.rose],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct SoundGridCard: View {
    let sound: SoundItem

    var body: some View {
        SquareCoverView(sound: sound, cornerRadius: 24)
            .overlay(AppTheme.dreamOverlay.opacity(0.58))
            .overlay {
                Text(sound.name)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
                    .padding(12)
                    .shadow(color: .black.opacity(0.24), radius: 8, x: 0, y: 4)
            }
            .shadow(color: AppTheme.lavender.opacity(0.18), radius: 16, x: 0, y: 10)
    }
}

struct ControlButton: View {
    let title: String
    let systemImage: String
    let isProminent: Bool
    let action: () -> Void

    init(_ title: String, systemImage: String, isProminent: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.isProminent = isProminent
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
        }
        .buttonStyle(.plain)
        .modifier(CapsuleButtonModifier(isProminent: isProminent))
    }
}

private struct CapsuleButtonModifier: ViewModifier {
    let isProminent: Bool

    func body(content: Content) -> some View {
        if isProminent {
            content.primaryCapsule()
        } else {
            content.secondaryCapsule()
        }
    }
}

func formattedTime(_ seconds: Int) -> String {
    let clamped = max(0, seconds)
    let hours = clamped / 3600
    let minutes = (clamped % 3600) / 60
    let remainingSeconds = clamped % 60

    if hours > 0 {
        return String(format: "%d:%02d:%02d", hours, minutes, remainingSeconds)
    } else {
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}
