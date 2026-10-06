import SwiftUI

// Colors from the Claude Design mock.
enum Palette {
    static let bg = Color(hex: 0x0a0a0b)
    static let text = Color(hex: 0xf2efe8)
    static let bright = Color(hex: 0xf6f3ec)
    static let muted = Color(hex: 0x8e8b85)
    static let dim = Color(hex: 0x6b6964)
    static let faint = Color(hex: 0x4a4946)
    static let ghost = Color(hex: 0x3a3937)
    static let yen = Color(hex: 0xa9a6a0)
    static let key = Color(hex: 0x161618)
    static let keyPressed = Color(hex: 0x333337)
    static let card = Color(hex: 0x141415)
    static let cardBorder = Color(hex: 0x232325)
    static let menu = Color(hex: 0x1a1a1c)
    static let menuBorder = Color(hex: 0x2c2c2f)
    static let selected = Color(hex: 0x2a2a2d)
    static let accent = Color(hex: 0xff6a3d)
    static let live = Color(hex: 0x34c759)
    static let offline = Color(hex: 0xff453a)
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255
        )
    }
}

struct ContentView: View {
    var model: ConverterModel

    var body: some View {
        VStack(spacing: 0) {
            header
            Spacer(minLength: 0)
            amounts
            splitCard
                .zIndex(1)
            Keypad(model: model)
        }
        .foregroundStyle(Palette.text)
        .background {
            // Tapping anywhere empty closes the split menu.
            if model.menuOpen {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { setMenu(false) }
            }
        }
        .background(Palette.bg.ignoresSafeArea())
    }

    // MARK: Header

    private var header: some View {
        HStack {
            Text("JPY → USD")
                .font(.system(size: 13, weight: .medium))
                .kerning(0.26)
                .foregroundStyle(Palette.muted)
            Spacer()
            RatePill(model: model)
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
    }

    // MARK: Amounts

    private var amounts: some View {
        let hasValue = model.yenValue > 0
        let usdLabel = model.usd.money
        let usdSize = Self.usdFontSize(for: usdLabel)

        return VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                Text("¥\(model.yenValue.grouped)")
                    .font(.system(size: 28, design: .monospaced))
                    .kerning(-0.28)
                    .foregroundStyle(hasValue ? Palette.yen : Palette.faint)
                    .lineLimit(1)
                Spacer()
                if hasValue {
                    Button("Clear") { model.clear() }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color(hex: 0xb5b2ab))
                        .padding(.vertical, 7)
                        .padding(.horizontal, 12)
                        .background(Color(hex: 0x1d1d1f), in: Capsule())
                }
            }
            .frame(minHeight: 34)

            Text("$\(usdLabel)")
                .font(.system(size: usdSize, weight: .light))
                .kerning(-0.04 * usdSize)
                .foregroundStyle(hasValue ? Palette.bright : Palette.ghost)
                .lineLimit(1)
                .minimumScaleFactor(0.4)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 18)
    }

    /// Same steps as the design's `renderVals`.
    private static func usdFontSize(for label: String) -> CGFloat {
        switch label.count {
        case ...6: 88
        case ...8: 76
        case ...10: 62
        case ...12: 52
        default: 44
        }
    }

    // MARK: Split

    private var splitCard: some View {
        let splitting = model.split > 1

        return HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(splitting ? "Each of \(model.split) pays" : "Split the bill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Palette.muted)
                Text("$\(model.perPerson.money)")
                    .font(.system(size: 22, weight: .medium, design: .monospaced))
                    .kerning(-0.44)
                    .foregroundStyle(splitting ? Palette.accent : Palette.faint)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            Spacer(minLength: 8)
            Button { setMenu(!model.menuOpen) } label: {
                HStack(spacing: 8) {
                    Text("Split")
                    Text("÷\(model.split)").font(.system(size: 15, weight: .medium, design: .monospaced))
                    Image(systemName: "chevron.up")
                        .font(.system(size: 11, weight: .semibold))
                        .rotationEffect(.degrees(model.menuOpen ? 0 : 180))
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(splitting ? Palette.bg : Palette.text)
                .padding(.leading, 16)
                .padding(.trailing, 14)
                .frame(height: 44)
                .background(splitting ? Palette.accent : Color(hex: 0x232326), in: RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 10)
        .padding(.leading, 18)
        .padding(.trailing, 10)
        .frame(minHeight: 64)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Palette.cardBorder, lineWidth: 1))
        .overlay(alignment: .bottomTrailing) {
            if model.menuOpen {
                splitMenu
                    .offset(y: -74)
                    .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .bottomTrailing)))
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }

    private var splitMenu: some View {
        VStack(spacing: 2) {
            ForEach(1...4, id: \.self) { ways in
                let selected = ways == model.split
                Button {
                    model.split = ways
                    setMenu(false)
                } label: {
                    HStack {
                        Text(ways == 1 ? "No split" : "\(ways) ways")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Palette.text)
                        Spacer()
                        Text(selected ? "✓" : "$\((model.usd / Double(ways)).money)")
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundStyle(selected ? Palette.accent : Palette.dim)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 46)
                    .background(selected ? Palette.selected : .clear, in: RoundedRectangle(cornerRadius: 12))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .frame(width: 200)
        .background(Palette.menu, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Palette.menuBorder, lineWidth: 1))
        .shadow(color: .black.opacity(0.7), radius: 25, y: 20)
    }

    private func setMenu(_ open: Bool) {
        withAnimation(.easeOut(duration: 0.2)) { model.menuOpen = open }
    }
}

// MARK: - Rate pill (green = live, red = static fallback)

struct RatePill: View {
    var model: ConverterModel

    var body: some View {
        Button {
            Task { await model.refreshRate() }
        } label: {
            HStack(spacing: 6) {
                Circle()
                    .fill(dotColor)
                    .frame(width: 8, height: 8)
                Text("$1 = ¥\(model.rate.money)")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(Palette.muted)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Palette.card, in: Capsule())
            .overlay(Capsule().stroke(Palette.cardBorder, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.2), value: model.rateStatus)
        .accessibilityLabel(accessibilityText)
        .accessibilityHint("Tap to refresh the rate")
    }

    private var dotColor: Color {
        switch model.rateStatus {
        case .loading: Palette.dim
        case .live: Palette.live
        case .fallback: Palette.offline
        }
    }

    private var accessibilityText: String {
        switch model.rateStatus {
        case .loading: "Loading rate"
        case .live: "Live rate, 1 dollar equals \(model.rate.money) yen"
        case .fallback: "Offline, using fixed rate of \(model.rate.money) yen"
        }
    }
}

// MARK: - Keypad

struct Keypad: View {
    var model: ConverterModel
    @State private var taps = 0

    private let keys = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "000", "0", "back"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(keys, id: \.self) { key in
                Button {
                    taps += 1
                    model.press(key)
                } label: {
                    if key == "back" {
                        Image(systemName: "delete.left")
                            .font(.system(size: 24, weight: .light))
                    } else {
                        Text(key)
                            .font(.system(size: key == "000" ? 24 : 32))
                    }
                }
                .buttonStyle(KeyStyle(filled: key != "000" && key != "back"))
                .accessibilityLabel(key == "back" ? "Delete" : key)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .sensoryFeedback(.impact(weight: .light), trigger: taps)
    }
}

struct KeyStyle: ButtonStyle {
    let filled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Palette.text)
            .frame(maxWidth: .infinity)
            .frame(height: 74)
            .background(
                configuration.isPressed ? Palette.keyPressed : (filled ? Palette.key : .clear),
                in: RoundedRectangle(cornerRadius: 22)
            )
            .contentShape(RoundedRectangle(cornerRadius: 22))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }
}

#Preview {
    ContentView(model: ConverterModel())
        .preferredColorScheme(.dark)
}
