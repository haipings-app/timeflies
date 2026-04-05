import SwiftUI

struct SettingsView: View {
    @Bindable var appState: AppState
    private let feedbackEmail = "haipings@gmail.com"
    private let feedbackSubject = "Timeflies Feedback"
    private let currentBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "2"

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

            Section("Feedback") {
                Text("Share suggestions, bugs, or feature ideas to help improve Timeflies.")
                    .foregroundStyle(.secondary)

                Link(destination: feedbackURL) {
                    Label("Send Feedback", systemImage: "bubble.left.and.text.bubble.right.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Text(feedbackEmail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Version") {
                LabeledContent("App Version", value: appState.currentVersion)
                LabeledContent("Build", value: currentBuild)
            }
        }
    }

    private var feedbackURL: URL {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = feedbackEmail
        components.queryItems = [
            URLQueryItem(name: "subject", value: feedbackSubject)
        ]
        return components.url ?? URL(string: "mailto:\(feedbackEmail)")!
    }
}
