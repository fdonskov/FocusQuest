import SwiftUI
import SwiftData

struct TimerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(AppSettings.self) private var settings
    @Query private var characters: [Character]
    @Query private var sessions: [FocusSession]
    @State private var viewModel = TimerViewModel()

    private var character: Character? { characters.first }
    private var locationID: String {
        let id = character?.currentLocationID ?? ""
        return id.isEmpty ? "meadow" : id
    }
    private var streak: Int { StatsCalculator.stats(from: sessions).streakDays }
    private var reduceMotion: Bool { settings.reduceMotion || systemReduceMotion }

    var body: some View {
        VStack(spacing: 0) {
                header
                Spacer(minLength: 12)
                TimerRingView(progress: viewModel.progress,
                              timeText: viewModel.remainingText,
                              focusLabel: settings.t("timer.focus"),
                              statusLabel: statusLabel,
                              isRunning: viewModel.isRunning,
                              reduceMotion: reduceMotion)
                Spacer(minLength: 12)
                VStack(spacing: 14) {
                    if let character {
                        CharacterBar(character: character, reduceMotion: reduceMotion)
                    }
                    PresetChips(presets: viewModel.presets,
                                selected: viewModel.selectedMinutes,
                                unit: settings.t("unit.min"),
                                action: viewModel.selectPreset)
                    controls
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 4)
            .padding(.bottom, 6)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                SceneBackground(locationID: locationID, reduceMotion: reduceMotion)
                    .ignoresSafeArea()
            }
            .overlay {
                if let reward = viewModel.lastReward {
                    RewardOverlay(reward: reward) { viewModel.clearReward() }
                }
            }
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: viewModel.lastReward?.id)
        .onAppear { viewModel.attach(context: modelContext, settings: settings) }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { viewModel.refresh() }
        }
        .onChange(of: settings.sound) { _, _ in viewModel.syncAmbient() }
    }

    private var statusLabel: String {
        switch viewModel.state {
        case .idle, .finished: return settings.t("timer.idle")
        case .running: return settings.t("timer.running")
        case .paused: return settings.t("timer.paused")
        }
    }

    private var header: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 4) {
                Text("\(settings.t("timer.locPrefix")) \(character?.level ?? 1)")
                    .font(.ui(11, weight: .bold))
                    .tracking(1.5)
                    .textCase(.uppercase)
                    .foregroundStyle(Theme.accentText)
                Text(settings.t(LocationCatalog.localizationKey(for: locationID)))
                    .font(.display(26))
                    .foregroundStyle(Theme.textPrimary)
            }
            .frame(maxWidth: .infinity)

            if streak > 0 {
                StreakPill(days: streak)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(settings.t("stats.streak")): \(streak)")
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
    }

    private var primaryLabel: String {
        switch viewModel.state {
        case .idle, .finished: return settings.t("timer.start")
        case .running: return settings.t("timer.pause")
        case .paused: return settings.t("timer.resume")
        }
    }

    private var controls: some View {
        HStack(spacing: 14) {
            if viewModel.canReset {
                Button { viewModel.reset() } label: {
                    Image(systemName: "stop.fill")
                        .font(.title3)
                        .frame(width: 56, height: 56)
                }
                .buttonStyle(.glass)
                .accessibilityLabel(settings.t("timer.reset"))
            }
            Button { viewModel.primaryAction() } label: {
                Label(primaryLabel, systemImage: viewModel.isRunning ? "pause.fill" : "play.fill")
                    .font(.ui(17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
            }
            .buttonStyle(.glassProminent)
            .tint(Theme.purpleDeep)
        }
    }
}

private struct SceneBackground: View {
    let locationID: String
    let reduceMotion: Bool

    @State private var drift = false

    private var hue: Double { LocationCatalog.seed(for: locationID).hue }
    private var glow1: Color { Color(hue: hue / 360, saturation: 0.82, brightness: 0.58) }
    private var glow2: Color {
        Color(hue: (hue + 38).truncatingRemainder(dividingBy: 360) / 360, saturation: 0.82, brightness: 0.58)
    }

    var body: some View {
        ZStack {
            Theme.void
            Image(LocationCatalog.sceneName(for: locationID))
                .resizable()
                .scaledToFill()
            Circle().fill(glow1.opacity(0.5)).frame(width: 320, height: 320).blur(radius: 80)
                .offset(x: drift ? -80 : -40, y: drift ? -190 : -150)
            Circle().fill(glow2.opacity(0.4)).frame(width: 300, height: 300).blur(radius: 90)
                .offset(x: drift ? 90 : 60, y: drift ? 130 : 170)
            if !reduceMotion {
                LocationAmbianceView(locationID: locationID)
            }
            LinearGradient(stops: [
                .init(color: Theme.void.opacity(0.32), location: 0),
                .init(color: .clear, location: 0.22),
                .init(color: Theme.void.opacity(0.22), location: 0.54),
                .init(color: Theme.void.opacity(0.85), location: 1),
            ], startPoint: .top, endPoint: .bottom)
        }
        .ignoresSafeArea()
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 28).repeatForever(autoreverses: true)) { drift = true }
        }
    }
}

private struct TimerRingView: View {
    let progress: Double
    let timeText: String
    let focusLabel: String
    let statusLabel: String
    let isRunning: Bool
    let reduceMotion: Bool

    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle().stroke(Color.white.opacity(0.08), lineWidth: 16)
            Circle()
                .trim(from: 0, to: min(1, max(0, progress)))
                .stroke(
                    AngularGradient(gradient: Gradient(colors: [Theme.purpleDeep, Theme.cyan]),
                                    center: .center, startAngle: .degrees(-90), endAngle: .degrees(270)),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: Theme.purple.opacity(isRunning ? 0.7 : 0.3), radius: isRunning ? 16 : 6)
                .animation(.linear(duration: 0.25), value: progress)
            Circle()
                .fill(.ultraThinMaterial)
                .overlay(Circle().stroke(Color.white.opacity(0.06), lineWidth: 1))
                .padding(26)
            VStack(spacing: 6) {
                Text(focusLabel.uppercased())
                    .font(.ui(12, weight: .bold))
                    .tracking(3)
                    .foregroundStyle(Theme.textMuted)
                Text(timeText)
                    .font(.display(58))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .foregroundStyle(Theme.textPrimary)
                Text(statusLabel)
                    .font(.ui(13))
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .frame(width: 280, height: 280)
        .scaleEffect(pulse ? 1.018 : 1.0)
        .onAppear { update(isRunning) }
        .onChange(of: isRunning) { _, running in update(running) }
    }

    private func update(_ running: Bool) {
        if running && !reduceMotion {
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) { pulse = true }
        } else {
            withAnimation(.easeOut(duration: 0.3)) { pulse = false }
        }
    }
}

private struct CharacterBar: View {
    let character: Character
    let reduceMotion: Bool

    private var xpFraction: Double {
        character.xpToNextLevel > 0 ? Double(character.currentXP) / Double(character.xpToNextLevel) : 0
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                PulsingAura(color: Theme.purple, reduceMotion: reduceMotion).frame(width: 70, height: 70)
                Circle()
                    .fill(AngularGradient(gradient: Gradient(colors: [Theme.purple, Theme.cyan, Theme.purple]),
                                          center: .center))
                    .frame(width: 50, height: 50)
                Circle().fill(Theme.void).frame(width: 42, height: 42)
                Image(systemName: "person.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Theme.textPrimary)
                Text("\(character.level)")
                    .font(.display(10))
                    .foregroundStyle(.white)
                    .frame(width: 18, height: 18)
                    .background(Theme.purpleDeep, in: Circle())
                    .overlay(Circle().stroke(Theme.void, lineWidth: 2))
                    .offset(x: 18, y: 16)
            }
            .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    Text(character.name)
                        .font(.ui(15, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Text("\(character.currentXP) / \(character.xpToNextLevel) XP")
                        .font(.ui(11))
                        .foregroundStyle(Theme.textSecondary)
                }
                XPBar(fraction: xpFraction, reduceMotion: reduceMotion).frame(height: 8)
            }
        }
        .padding(14)
        .glassCard(cornerRadius: 18)
    }
}

private struct XPBar: View {
    let fraction: Double
    let reduceMotion: Bool

    @State private var shimmer = false

    private var clamped: Double { min(1, max(0, fraction)) }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.1))
                Capsule()
                    .fill(Theme.xpGradient)
                    .frame(width: geo.size.width * clamped)
                    .overlay {
                        Capsule()
                            .fill(LinearGradient(colors: [.clear, .white.opacity(0.55), .clear],
                                                 startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * clamped * 0.5)
                            .offset(x: shimmer ? geo.size.width * clamped : -geo.size.width * clamped)
                    }
                    .clipShape(Capsule())
                    .shadow(color: Theme.purple.opacity(0.6), radius: 5)
            }
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.linear(duration: 2.4).repeatForever(autoreverses: false)) { shimmer = true }
        }
        .animation(.easeOut(duration: 0.5), value: fraction)
    }
}

private struct PresetChips: View {
    let presets: [Int]
    let selected: Int
    let unit: String
    let action: (Int) -> Void

    var body: some View {
        HStack(spacing: 10) {
            ForEach(presets, id: \.self) { minutes in
                Button { action(minutes) } label: {
                    Text("\(minutes) \(unit)")
                        .font(.ui(15, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .foregroundStyle(selected == minutes ? .white : Theme.textSecondary)
                }
                .buttonStyle(.plain)
                .glassCard(cornerRadius: 14, tint: selected == minutes ? Theme.purpleDeep : nil)
            }
        }
    }
}

private struct StreakPill: View {
    let days: Int

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "flame.fill")
                .font(.caption)
                .foregroundStyle(Color(hex: 0xFF9A52))
            Text("\(days)")
                .font(.ui(12, weight: .bold))
                .foregroundStyle(Color(hex: 0xFFB27A))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(hex: 0xFF783C).opacity(0.16), in: Capsule())
        .overlay(Capsule().stroke(Color(hex: 0xFF8C46).opacity(0.4), lineWidth: 1))
    }
}

private struct RewardOverlay: View {
    let reward: SessionReward
    let onDismiss: () -> Void

    @Environment(AppSettings.self) private var settings
    @State private var shown = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)

            if let drop = reward.drop {
                RadialGradient(colors: [drop.rarity.color.opacity(0.35), .clear],
                               center: .center, startRadius: 2, endRadius: 260)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            VStack(spacing: 14) {
                Text(settings.t("reward.done").uppercased())
                    .font(.ui(12, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(Theme.textMuted)

                Text("+\(reward.xpEarned)")
                    .font(.display(52, weight: .heavy))
                    .foregroundStyle(Theme.mainGradient)
                    .scaleEffect(shown ? 1 : 0.5)
                    .opacity(shown ? 1 : 0)

                Text(settings.t("reward.xp"))
                    .font(.ui(13))
                    .foregroundStyle(Theme.textSecondary)

                if reward.leveledUp {
                    Text("\(settings.t("reward.level")) \(reward.newLevel)")
                        .font(.ui(15, weight: .bold))
                        .foregroundStyle(.yellow)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(.yellow.opacity(0.15), in: Capsule())
                }

                if let loc = reward.unlockedLocationID {
                    Text("\(settings.t("reward.unlock")) \(settings.t(LocationCatalog.localizationKey(for: loc)))")
                        .font(.ui(13, weight: .semibold))
                        .foregroundStyle(Theme.cyan)
                }

                if let drop = reward.drop {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(RadialGradient(colors: [drop.rarity.color.opacity(0.55), .clear],
                                                     center: .center, startRadius: 2, endRadius: 46))
                                .frame(width: 92, height: 92)
                            Image(systemName: drop.iconName)
                                .font(.system(size: 42))
                                .foregroundStyle(drop.rarity.color)
                                .symbolEffect(.bounce, value: shown)
                        }
                        Text(settings.t("item.\(drop.itemID)"))
                            .font(.ui(17, weight: .semibold))
                            .foregroundStyle(Theme.textPrimary)
                        Text(settings.t("rarity.\(drop.rarity.rawValue)").lowercased())
                            .font(.ui(12))
                            .foregroundStyle(drop.rarity.color)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .glassCard(cornerRadius: 18)
                    .overlay(RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(drop.rarity.color.opacity(0.6), lineWidth: 1))
                    .scaleEffect(shown ? 1 : 0.7)
                    .opacity(shown ? 1 : 0)
                }

                Button(action: onDismiss) {
                    Text(settings.t("reward.claim"))
                        .font(.ui(17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
                .buttonStyle(.glassProminent)
                .tint(Theme.purpleDeep)
                .padding(.top, 4)
            }
            .padding(24)
            .frame(maxWidth: 340)
            .glassCard(cornerRadius: 28)
            .padding(40)
            .scaleEffect(shown ? 1 : 0.9)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { shown = true }
        }
    }
}

#Preview {
    TimerView()
        .environment(AppSettings())
        .modelContainer(for: [Character.self, FocusSession.self, InventoryItem.self,
                              Achievement.self, Location.self], inMemory: true)
}
