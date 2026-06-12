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
                    .controlSize(.large)
                    .tint(AppTheme.ocean)
                Text("正在准备声音")
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)
                Text("让潮汐慢慢靠近")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .failed(let message):
            VStack(spacing: 18) {
                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(AppTheme.ocean)
                    .frame(width: 76, height: 76)
                    .background(AppTheme.ocean.opacity(0.10), in: Circle())
                Text(message)
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)
                    .multilineTextAlignment(.center)
                Button(action: retry) {
                    Label("重新加载", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.plain)
                .primaryCapsule()
            }
            .glassPanel()
            .padding()
            .frame(maxWidth: 460)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .loaded:
            content()
        }
    }
}

struct DreamHeader: View {
    let title: String
    let subtitle: String
    var systemImage: String = "sparkles"

    var body: some View {
        HStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.78))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Image(systemName: systemImage)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 62, height: 62)
                .background(.white.opacity(0.14), in: Circle())
                .overlay(Circle().stroke(.white.opacity(0.22), lineWidth: 1))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.heroGradient)
    }
}

struct SectionLabel: View {
    let title: String
    var detail: String?
    var systemImage: String?

    var body: some View {
        HStack(spacing: 9) {
            if let systemImage {
                Image(systemName: systemImage)
                    .foregroundStyle(AppTheme.ocean)
            }
            Text(title)
                .font(.headline)
                .foregroundStyle(AppTheme.ink)
            Spacer()
            if let detail {
                Text(detail)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
        }
    }
}

struct SquareCoverView: View {
    let sound: SoundItem
    var cornerRadius: CGFloat = 18

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
                                Image(systemName: "waveform")
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
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    private var placeholder: some View {
        LinearGradient(
            colors: [AppTheme.ocean, AppTheme.indigo, AppTheme.coral],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct SoundGridCard: View {
    let sound: SoundItem

    var body: some View {
        SquareCoverView(sound: sound)
            .overlay {
                LinearGradient(
                    colors: [.clear, AppTheme.ink.opacity(0.72)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .overlay(alignment: .topTrailing) {
                Image(systemName: "play.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(.ultraThinMaterial, in: Circle())
                    .padding(10)
            }
            .overlay {
                Text(sound.name)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
                    .multilineTextAlignment(.center)
                    .padding(12)
                    .shadow(color: .black.opacity(0.26), radius: 5, x: 0, y: 2)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(.white.opacity(0.42), lineWidth: 1)
            )
            .shadow(color: AppTheme.ink.opacity(0.13), radius: 14, x: 0, y: 8)
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
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .modifier(ControlButtonModifier(isProminent: isProminent))
    }
}

private struct ControlButtonModifier: ViewModifier {
    let isProminent: Bool

    func body(content: Content) -> some View {
        if isProminent {
            content.primaryCapsule()
        } else {
            content.secondaryCapsule()
        }
    }
}

struct RoundControlButton: View {
    let systemImage: String
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 66, height: 66)
                .background(AppTheme.heroGradient, in: Circle())
                .shadow(color: AppTheme.ocean.opacity(0.24), radius: 14, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

struct MetricPill: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .foregroundStyle(AppTheme.secondaryText)
            .padding(.horizontal, 11)
            .frame(minHeight: 30)
            .background(AppTheme.canvas, in: Capsule())
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
