//
//  AppTheme.swift
//  tidepro
//

import SwiftUI

enum AppTheme {
    static let lavender = Color(red: 0.55, green: 0.36, blue: 0.96)
    static let lavenderSoft = Color(red: 0.77, green: 0.71, blue: 0.99)
    static let mint = Color(red: 0.06, green: 0.73, blue: 0.51)
    static let ink = Color(red: 0.18, green: 0.10, blue: 0.38)
    static let paper = Color(red: 0.98, green: 0.96, blue: 1.0)
    static let rose = Color(red: 1.0, green: 0.72, blue: 0.78)

    static var background: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.98, green: 0.96, blue: 1.0),
                Color(red: 0.91, green: 0.96, blue: 1.0),
                Color(red: 0.93, green: 0.89, blue: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var dreamOverlay: LinearGradient {
        LinearGradient(
            colors: [
                lavender.opacity(0.82),
                Color(red: 0.28, green: 0.40, blue: 0.85).opacity(0.62),
                mint.opacity(0.54)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension View {
    func dreamBackground() -> some View {
        background(AppTheme.background.ignoresSafeArea())
    }

    func glassPanel(cornerRadius: CGFloat = 24) -> some View {
        padding()
            .background(.white.opacity(0.62), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(.white.opacity(0.78), lineWidth: 1)
            )
            .shadow(color: AppTheme.lavender.opacity(0.14), radius: 20, x: 0, y: 12)
    }

    func primaryCapsule() -> some View {
        font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 22)
            .padding(.vertical, 13)
            .background(AppTheme.lavender, in: Capsule())
    }

    func secondaryCapsule() -> some View {
        font(.headline)
            .foregroundStyle(AppTheme.ink)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.white.opacity(0.75), in: Capsule())
            .overlay(Capsule().stroke(AppTheme.lavenderSoft.opacity(0.8), lineWidth: 1))
    }
}
