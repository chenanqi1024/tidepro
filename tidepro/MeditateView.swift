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
                VStack(spacing: 18) {
                    DreamHeader(title: "冥想", subtitle: "选择一个简短练习，让注意力慢慢回到自己身上。")

                    ForEach(items) { item in
                        NavigationLink(value: MeditationRoute.detail(item)) {
                            MeditationCard(item: item)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 28)
            }
            .dreamBackground()
            .navigationTitle("冥想")
            .navigationBarTitleDisplayMode(.inline)
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
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppTheme.dreamOverlay)
                Image(systemName: "sparkle.magnifyingglass")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)
                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.ink.opacity(0.68))
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.ink.opacity(0.48))
        }
        .glassPanel()
    }
}

struct MeditationDetailView: View {
    let item: MeditationItem

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 12) {
                Text(item.title)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.ink)
                Text(item.subtitle)
                    .font(.title3)
                    .foregroundStyle(AppTheme.ink.opacity(0.68))
            }

            Text("跟随几段简短引导，把注意力慢慢放稳。")
                .font(.body)
                .foregroundStyle(AppTheme.ink.opacity(0.72))

            NavigationLink(value: MeditationRoute.guide(item)) {
                Label("开始", systemImage: "play.fill")
            }
            .buttonStyle(.plain)
            .primaryCapsule()

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .dreamBackground()
        .navigationTitle("详情")
        .navigationBarTitleDisplayMode(.inline)
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
        VStack(spacing: 26) {
            Spacer(minLength: 20)

            VStack(spacing: 16) {
                Text("\(index + 1) / \(item.paragraphs.count)")
                    .font(.headline)
                    .foregroundStyle(AppTheme.lavender)

                Text(item.paragraphs[index])
                    .font(.system(size: 25, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.ink)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .minimumScaleFactor(0.78)
            }
            .frame(maxWidth: .infinity, minHeight: 250)
            .glassPanel(cornerRadius: 32)

            HStack(spacing: 12) {
                ControlButton("上一段", systemImage: "chevron.left", isProminent: false) {
                    guard canGoBack else { return }
                    index -= 1
                }
                .opacity(canGoBack ? 1 : 0.45)

                ControlButton(canGoForward ? "下一段" : "结束", systemImage: canGoForward ? "chevron.right" : "checkmark") {
                    if canGoForward {
                        index += 1
                    } else {
                        dismiss()
                    }
                }
            }

            Button {
                dismiss()
            } label: {
                Label("结束", systemImage: "xmark")
            }
            .buttonStyle(.plain)
            .foregroundStyle(AppTheme.ink.opacity(0.7))
            .font(.headline)

            Spacer(minLength: 24)
        }
        .padding(.horizontal)
        .dreamBackground()
        .navigationTitle(item.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
