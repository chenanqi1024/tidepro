//
//  AppTheme.swift
//  tidepro
//

import SwiftUI

enum AppTheme {
    static let ocean = Color(red: 0.08, green: 0.52, blue: 0.61)
    static let indigo = Color(red: 0.32, green: 0.37, blue: 0.78)
    static let mint = Color(red: 0.16, green: 0.69, blue: 0.57)
    static let coral = Color(red: 0.94, green: 0.48, blue: 0.42)
    static let gold = Color(red: 0.95, green: 0.67, blue: 0.28)
    static let ink = Color(red: 0.08, green: 0.14, blue: 0.22)
    static let secondaryText = Color(red: 0.34, green: 0.40, blue: 0.48)
    static let canvas = Color(red: 0.96, green: 0.98, blue: 0.99)
    static let surface = Color.white.opacity(0.94)
    static let border = Color(red: 0.84, green: 0.89, blue: 0.92)

    // Kept for existing playback and timer logic.
    static let lavender = indigo
    static let lavenderSoft = indigo.opacity(0.28)
    static let paper = canvas
    static let rose = coral

    static var background: LinearGradient {
        LinearGradient(
            colors: [
                canvas,
                Color(red: 0.92, green: 0.98, blue: 0.98),
                Color(red: 0.95, green: 0.96, blue: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var heroGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.20, blue: 0.29),
                ocean,
                indigo
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var dreamOverlay: LinearGradient {
        LinearGradient(
            colors: [
                ink.opacity(0.18),
                ocean.opacity(0.18),
                indigo.opacity(0.60)
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

    func surfacePanel(cornerRadius: CGFloat = 20) -> some View {
        background(AppTheme.surface, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppTheme.border.opacity(0.78), lineWidth: 1)
            )
            .shadow(color: AppTheme.ink.opacity(0.07), radius: 18, x: 0, y: 8)
    }

    func glassPanel(cornerRadius: CGFloat = 20) -> some View {
        padding(18)
            .surfacePanel(cornerRadius: cornerRadius)
    }

    func primaryCapsule() -> some View {
        font(.headline)
            .lineLimit(1)
            .minimumScaleFactor(0.78)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 50)
            .padding(.horizontal, 14)
            .background(AppTheme.heroGradient, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
            .shadow(color: AppTheme.ocean.opacity(0.20), radius: 12, x: 0, y: 7)
    }

    func secondaryCapsule() -> some View {
        font(.headline)
            .lineLimit(1)
            .minimumScaleFactor(0.78)
            .foregroundStyle(AppTheme.ink)
            .frame(maxWidth: .infinity, minHeight: 50)
            .padding(.horizontal, 12)
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
    }
}
