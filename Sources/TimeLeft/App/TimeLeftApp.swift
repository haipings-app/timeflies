import SwiftUI

@main
struct TimeLeftApp: App {
    @State private var appState = AppState()
    @State private var showingSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                DashboardView(appState: appState)

                if showingSplash {
                    LaunchSplashView()
                        .transition(.opacity.combined(with: .scale(scale: 1.02)))
                        .zIndex(1)
                }
            }
            .task {
                guard showingSplash else { return }
                try? await Task.sleep(for: .seconds(1.8))
                withAnimation(.easeInOut(duration: 0.35)) {
                    showingSplash = false
                }
            }
        }
    }
}
