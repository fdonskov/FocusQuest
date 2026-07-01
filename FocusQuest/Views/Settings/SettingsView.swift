import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(AppSettings.self) private var settings
    @Query private var characters: [Character]

    private var character: Character? { characters.first }

    var body: some View {
        @Bindable var settings = settings
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    statsLink
                    nameField
                    defaultSession
                    VStack(spacing: 12) {
                        // Demo mode toggle hidden for now (demoMode setting kept for later use).
//                         SettingToggle(icon: "forward.fill", title: settings.t("set.demo"),
//                                       subtitle: settings.t("set.demoH"), isOn: $settings.demoMode)
                        SettingToggle(icon: "speaker.wave.2.fill", title: settings.t("set.sound"),
                                      subtitle: settings.t("set.soundH"), isOn: $settings.sound)
                        SettingToggle(icon: "bell.fill", title: settings.t("set.notif"),
                                      subtitle: settings.t("set.notifH"), isOn: $settings.notifications)
                        SettingToggle(icon: "wind", title: settings.t("set.motion"),
                                      subtitle: settings.t("set.motionH"), isOn: $settings.reduceMotion)
                    }
                    language
                    appCard
                }
                .padding(20)
            }
            .screenBackground()
            .navigationTitle(settings.t("set.title"))
        }
    }

    private var statsLink: some View {
        NavigationLink {
            StatsView()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Theme.accentText)
                    .frame(width: 40, height: 40)
                    .background(Theme.purple.opacity(0.18), in: RoundedRectangle(cornerRadius: 12))
                Text(settings.t("stats.title"))
                    .font(.ui(15, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Theme.textMuted)
            }
            .padding(14)
            .glassCard(cornerRadius: 16)
        }
        .buttonStyle(.plain)
    }

    private var nameField: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.fill").foregroundStyle(Theme.accentText)
            TextField(settings.t("set.namePh"), text: nameBinding)
                .font(.ui(16, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
            Image(systemName: "pencil").foregroundStyle(Theme.textMuted)
        }
        .padding(16)
        .glassCard(cornerRadius: 16)
    }

    private var nameBinding: Binding<String> {
        Binding(get: { character?.name ?? "" },
                set: { character?.name = $0 })
    }

    private var defaultSession: some View {
        @Bindable var settings = settings
        return VStack(alignment: .leading, spacing: 10) {
            Text(settings.t("set.defSession").uppercased())
                .font(.ui(11, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(Theme.textMuted)
            HStack(spacing: 10) {
                ForEach([15, 25, 50], id: \.self) { minutes in
                    Button { settings.defaultPresetMinutes = minutes } label: {
                        Text("\(minutes) \(settings.t("unit.min"))")
                            .font(.ui(15, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .foregroundStyle(settings.defaultPresetMinutes == minutes ? .white : Theme.textSecondary)
                    }
                    .buttonStyle(.plain)
                    .glassCard(cornerRadius: 14,
                               tint: settings.defaultPresetMinutes == minutes ? Theme.purpleDeep : nil)
                }
            }
        }
    }

    private var language: some View {
        @Bindable var settings = settings
        return VStack(alignment: .leading, spacing: 10) {
            Text(settings.t("set.language").uppercased())
                .font(.ui(11, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(Theme.textMuted)
            Picker("", selection: $settings.language) {
                Text("Русский").tag("ru")
                Text("English").tag("en")
            }
            .pickerStyle(.segmented)
        }
    }

    private var appCard: some View {
        VStack(spacing: 4) {
            Text("FocusQuest")
                .font(.display(17))
                .foregroundStyle(Theme.textPrimary)
            Text(settings.t("set.version"))
                .font(.ui(12))
                .foregroundStyle(Theme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(18)
        .glassCard(cornerRadius: 16)
    }
}

private struct SettingToggle: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Theme.accentText)
                .frame(width: 40, height: 40)
                .background(Theme.purple.opacity(0.18), in: RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.ui(15, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                Text(subtitle)
                    .font(.ui(12))
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Theme.purpleDeep)
        }
        .padding(14)
        .glassCard(cornerRadius: 16)
    }
}

#Preview {
    SettingsView()
        .environment(AppSettings())
        .modelContainer(for: [Character.self, FocusSession.self, InventoryItem.self,
                              Achievement.self, Location.self], inMemory: true)
}
