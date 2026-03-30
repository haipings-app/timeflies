import SwiftUI

struct SettingsView: View {
    @Bindable var appState: AppState

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 14) {
                    TimeLeftBrandHeader()

                    Text("Timeflies stores your countdowns locally on your iPhone and helps keep important deadlines visible through reminders and focused task tracking.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }

            Section("App") {
                Text("Local-first countdowns, focused task tracking, and lightweight reminders.")
                    .foregroundStyle(.secondary)
            }

            Section("Email") {
                Text("Provider")
                Text(appState.emailSenderName)
                    .foregroundStyle(.secondary)

                Text("Current status")
                Text("The UI and data model are ready. Connecting a real provider is the next step.")
                    .foregroundStyle(.secondary)
            }

            Section("SMS") {
                Text("Provider")
                Text(appState.smsProviderName)
                    .foregroundStyle(.secondary)

                Text("Current status")
                Text("Reserved in the architecture for a later phase.")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
