import SwiftUI

struct SettingsView: View {
    @Bindable var appState: AppState

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 14) {
                    TimeLeftBrandHeader()

                    Text("Time Left stores goals locally on your iPhone and keeps deadlines visible through native reminders and focused task tracking.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }

            Section("App") {
                Text("Local-first data, focused countdowns, and lightweight reminders.")
                    .foregroundStyle(.secondary)
            }

            Section("Email") {
                Text("Provider")
                Text(appState.emailSenderName)
                    .foregroundStyle(.secondary)

                Text("First implementation status")
                Text("UI and data model are ready. Provider wiring is the next milestone.")
                    .foregroundStyle(.secondary)
            }

            Section("SMS") {
                Text("Provider")
                Text(appState.smsProviderName)
                    .foregroundStyle(.secondary)

                Text("Status")
                Text("Reserved in the architecture for phase two.")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
