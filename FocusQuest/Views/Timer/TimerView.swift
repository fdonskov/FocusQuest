import SwiftUI
import SwiftData

struct TimerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var characters: [Character]
    @State private var viewModel = TimerViewModel()

    private var character: Character? { characters.first }

    var body: some View {
        ZStack {
            backgroundGradient
            VStack(spacing: 36) {
                if let character {
                    CharacterBadge(character: character)
                }
                TimerRing(progress: viewModel.progress, timeText: viewModel.remainingText)
                controls
            }
            .padding(24)
        }
        .onAppear { viewModel.attach(modelContext) }
        .onChange(of: scenePhase) { _, phase in
            // The ticker is suspended in the background; recompute once on return.
            if phase == .active { viewModel.refresh() }
        }
    }

    private var controls: some View {
        HStack(spacing: 16) {
            if viewModel.canReset {
                Button {
                    viewModel.reset()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .frame(width: 60, height: 60)
                        .background(.ultraThinMaterial, in: Circle())
                }
            }
            Button {
                viewModel.primaryAction()
            } label: {
                Text(viewModel.primaryButtonTitle)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.accentColor, in: Capsule())
            }
        }
        .padding(.horizontal, 8)
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color(red: 0.06, green: 0.07, blue: 0.12),
                     Color(red: 0.10, green: 0.08, blue: 0.18)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

private struct CharacterBadge: View {
    let character: Character

    private var xpFraction: Double {
        guard character.xpToNextLevel > 0 else { return 0 }
        return Double(character.currentXP) / Double(character.xpToNextLevel)
    }

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.accentColor)
            Text(character.name)
                .font(.title3.weight(.semibold))
            Text("Уровень \(character.level)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            XPBar(fraction: xpFraction)
                .frame(maxWidth: 220)
                .frame(height: 8)
            Text("\(character.currentXP) / \(character.xpToNextLevel) XP")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
    }
}

private struct XPBar: View {
    let fraction: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(.quaternary)
                Capsule()
                    .fill(Color.accentColor)
                    .frame(width: geo.size.width * min(1, max(0, fraction)))
            }
        }
        .animation(.easeOut(duration: 0.3), value: fraction)
    }
}

private struct TimerRing: View {
    let progress: Double
    let timeText: String

    var body: some View {
        ZStack {
            Circle()
                .stroke(.quaternary, lineWidth: 14)
            Circle()
                .trim(from: 0, to: min(1, max(0, progress)))
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.25), value: progress)
            Text(timeText)
                .font(.system(size: 60, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
        }
        .frame(width: 260, height: 260)
    }
}

#Preview {
    TimerView()
        .modelContainer(for: [Character.self, FocusSession.self, InventoryItem.self,
                              Achievement.self, Location.self], inMemory: true)
}
