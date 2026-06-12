//
//  MeditateView.swift
//  tidepro
//

import SwiftUI

enum MeditationRoute: Hashable {
    case detail(MeditationItem)
    case guide(MeditationItem)
}

struct MeditateView: View {
    private let items: [MeditationItem] = [
        MeditationItem(
            id: "sleep-fast",
            title: "快速入眠",
            subtitle: "放慢呼吸，松开一天的紧绷。",
            systemImage: "moon.stars.fill",
            minutes: 6,
            paragraphs: [
                "找一个舒服的姿势，让肩膀自然下沉。",
                "把注意力放到呼吸上，不需要改变它，只是轻轻观察。",
                "每一次呼气时，想象身体多放松一点。",
                "如果有念头经过，知道它来过，然后把注意力带回呼吸。",
                "让眼皮、下颌和双手都慢慢变轻。"
            ]
        ),
        MeditationItem(
            id: "exam-stress",
            title: "考试压力",
            subtitle: "给紧张留出位置，也把注意力带回当下。",
            systemImage: "book.closed.fill",
            minutes: 5,
            paragraphs: [
                "先感受双脚和地面的接触，确认自己此刻是安全的。",
                "吸气时默念“我在这里”，呼气时默念“慢一点”。",
                "把压力想象成胸口的一团云，不推开，也不追着它走。",
                "回想一件你已经准备过的小事，给自己一点确定感。",
                "最后做一次深呼吸，把注意力放回下一步。"
            ]
        ),
        MeditationItem(
            id: "breath-practice",
            title: "呼吸练习",
            subtitle: "用短短几分钟重建节奏。",
            systemImage: "wind",
            minutes: 4,
            paragraphs: [
                "保持脊柱自然伸展，双手放在身体两侧或腿上。",
                "吸气时感受胸腔和腹部慢慢展开。",
                "呼气时让气息自然流出，不需要用力。",
                "试着让呼气稍微比吸气长一点。",
                "重复几轮后，留意身体有没有更安稳。"
            ]
        ),
        MeditationItem(
            id: "body-scan",
            title: "身体扫描",
            subtitle: "从头到脚，温柔地检查身体信号。",
            systemImage: "figure.stand",
            minutes: 8,
            paragraphs: [
                "把注意力放在头顶，感受那里有没有紧绷或温度。",
                "慢慢移动到额头、眼睛和脸颊，允许它们放松。",
                "继续扫过肩膀、手臂和指尖，不急着改变任何感觉。",
                "把注意力带到胸口、腹部和背部，感受呼吸的起伏。",
                "最后来到双腿和脚掌，让整个身体被安稳地承托。"
            ]
        )
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    DreamHeader(
                        title: "冥想",
                        subtitle: "给自己几分钟，让思绪慢慢落下来。",
                        systemImage: "sparkles"
                    )

                    VStack(alignment: .leading, spacing: 14) {
                        SectionLabel(title: "今日练习", detail: "\(items.count) 个引导", systemImage: "headphones")

                        ForEach(items) { item in
                            NavigationLink(value: MeditationRoute.detail(item)) {
                                MeditationCard(item: item)
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
            .navigationDestination(for: MeditationRoute.self) { route in
                switch route {
                case .detail(let item):
                    MeditationDetailView(item: item)
                case .guide(let item):
                    MeditationGuideView(item: item)
                }
            }
        }
    }
}

struct MeditationCard: View {
    let item: MeditationItem

    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(item.accentGradient)
                Image(systemName: item.systemImage)
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 68, height: 78)
            .shadow(color: item.accentColors.last?.opacity(0.22) ?? .clear, radius: 9, x: 0, y: 5)

            VStack(alignment: .leading, spacing: 7) {
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)

                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    MetricPill(title: "\(item.minutes) 分钟", systemImage: "clock")
                    MetricPill(title: "\(item.paragraphs.count) 段", systemImage: "text.alignleft")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(AppTheme.secondaryText.opacity(0.72))
        }
        .padding(14)
        .surfacePanel()
    }
}

struct MeditationDetailView: View {
    let item: MeditationItem

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(spacing: 18) {
                    Image(systemName: item.systemImage)
                        .font(.system(size: 42, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 96, height: 96)
                        .background(.white.opacity(0.14), in: Circle())
                        .overlay(Circle().stroke(.white.opacity(0.24), lineWidth: 1))

                    VStack(spacing: 8) {
                        Text(item.title)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text(item.subtitle)
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.78))
                            .multilineTextAlignment(.center)
                    }

                    HStack(spacing: 10) {
                        detailPill("\(item.minutes) 分钟", systemImage: "clock.fill")
                        detailPill("\(item.paragraphs.count) 段引导", systemImage: "text.alignleft")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 34)
                .frame(maxWidth: .infinity)
                .background(item.accentGradient)

                VStack(alignment: .leading, spacing: 22) {
                    SectionLabel(title: "开始之前", systemImage: "leaf.fill")

                    Text("找一个不会被打扰的位置，把手机调至舒适亮度。跟随几段简短引导，不需要努力清空思绪。")
                        .font(.body)
                        .foregroundStyle(AppTheme.secondaryText)
                        .lineSpacing(5)
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .surfacePanel()

                    NavigationLink(value: MeditationRoute.guide(item)) {
                        Label("开始冥想", systemImage: "play.fill")
                    }
                    .buttonStyle(.plain)
                    .primaryCapsule()
                }
                .padding(16)
                .frame(maxWidth: 620)
                .frame(maxWidth: .infinity)
            }
            .padding(.bottom, 28)
        }
        .dreamBackground()
        .toolbar(.visible, for: .navigationBar)
        .navigationTitle("冥想详情")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailPill(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .frame(minHeight: 32)
            .background(.white.opacity(0.14), in: Capsule())
    }
}

struct MeditationGuideView: View {
    @Environment(\.dismiss) private var dismiss
    let item: MeditationItem

    @State private var index = 0

    private var canGoBack: Bool {
        index > 0
    }

    private var canGoForward: Bool {
        index < item.paragraphs.count - 1
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    HStack {
                        Label(item.title, systemImage: item.systemImage)
                            .font(.headline)
                            .foregroundStyle(AppTheme.ink)
                        Spacer()
                        Text("\(index + 1) / \(item.paragraphs.count)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppTheme.ocean)
                    }

                    ProgressView(value: Double(index + 1), total: Double(item.paragraphs.count))
                        .tint(AppTheme.ocean)
                }

                VStack(spacing: 22) {
                    Image(systemName: item.systemImage)
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 82, height: 82)
                        .background(item.accentGradient, in: Circle())

                    Text(item.paragraphs[index])
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.ink)
                        .multilineTextAlignment(.center)
                        .lineSpacing(7)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(22)
                .frame(maxWidth: .infinity, minHeight: 300)
                .surfacePanel(cornerRadius: 24)

                HStack(spacing: 10) {
                    ControlButton("上一段", systemImage: "chevron.left", isProminent: false) {
                        guard canGoBack else { return }
                        index -= 1
                    }
                    .opacity(canGoBack ? 1 : 0.42)
                    .disabled(!canGoBack)

                    ControlButton(canGoForward ? "下一段" : "完成", systemImage: canGoForward ? "chevron.right" : "checkmark") {
                        if canGoForward {
                            index += 1
                        } else {
                            dismiss()
                        }
                    }
                }

                Button("结束练习") {
                    dismiss()
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.secondaryText)
                .frame(minHeight: 44)
            }
            .padding(16)
            .frame(maxWidth: 620)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 28)
        }
        .dreamBackground()
        .toolbar(.visible, for: .navigationBar)
        .navigationTitle("引导")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension MeditationItem {
    var accentColors: [Color] {
        switch id {
        case "sleep-fast":
            return [Color(red: 0.18, green: 0.29, blue: 0.55), AppTheme.indigo]
        case "exam-stress":
            return [AppTheme.coral, AppTheme.gold]
        case "breath-practice":
            return [AppTheme.ocean, AppTheme.mint]
        default:
            return [AppTheme.indigo, AppTheme.coral]
        }
    }

    var accentGradient: LinearGradient {
        LinearGradient(colors: accentColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
