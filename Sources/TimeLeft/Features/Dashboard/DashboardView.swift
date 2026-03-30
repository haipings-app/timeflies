import SwiftUI

struct DashboardView: View {
    @Bindable var appState: AppState
    @State private var showingNewGoalSheet = false
    @State private var showingSettingsSheet = false
    @State private var goalPendingDeletion: CountdownGoal?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    heroCard
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 8, trailing: 0))
                        .listRowBackground(Color.clear)

                    quickStats
                        .listRowInsets(.init(top: 0, leading: 20, bottom: 10, trailing: 20))
                        .listRowBackground(Color.clear)
                }

                Section {
                    Text("Your Countdowns")
                        .font(.title2.weight(.bold))
                        .padding(.top, 2)
                        .listRowInsets(.init(top: 0, leading: 14, bottom: 6, trailing: 14))
                        .listRowBackground(Color.clear)

                    sortBar
                        .listRowInsets(.init(top: 0, leading: 14, bottom: 4, trailing: 14))
                        .listRowBackground(Color.clear)

                    ForEach(appState.sortedGoals) { goal in
                        NavigationLink {
                            if let index = appState.goals.firstIndex(where: { $0.id == goal.id }) {
                                GoalDetailView(
                                    goal: $appState.goals[index],
                                    onAddTask: { title in
                                        appState.addTask(to: appState.goals[index].id, title: title)
                                    },
                                    onToggleTask: { taskID in
                                        appState.toggleTask(goalID: appState.goals[index].id, taskID: taskID)
                                    },
                                    onDeleteTask: { taskID in
                                        appState.deleteTask(goalID: appState.goals[index].id, taskID: taskID)
                                    },
                                    onTaskTitleChange: { taskID, title in
                                        appState.updateTaskTitle(goalID: appState.goals[index].id, taskID: taskID, title: title)
                                    },
                                    onTaskNoteChange: { taskID, note in
                                        appState.updateTaskNote(goalID: appState.goals[index].id, taskID: taskID, note: note)
                                    }
                                )
                            }
                        } label: {
                            GoalRowView(goal: goal)
                        }
                        .buttonStyle(.plain)
                        .listRowInsets(.init(top: 8, leading: 14, bottom: 8, trailing: 14))
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                goalPendingDeletion = goal
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .contextMenu {
                            Button {
                                appState.selectedGoalID = goal.id
                                appState.duplicateSelectedGoal()
                            } label: {
                                Label("Duplicate", systemImage: "square.on.square")
                            }
                        }
                    }

                    if appState.goals.isEmpty {
                        ContentUnavailableView(
                            "Create Your First Countdown",
                            systemImage: "hourglass",
                            description: Text("Add a deadline, break it into tasks, and keep the remaining time in view.")
                        )
                        .padding(.top, 40)
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.98, blue: 0.99),
                        Color(red: 0.93, green: 0.95, blue: 0.98)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .compactNavigationTitleDisplayMode()
            .toolbar {
                ToolbarItem(placement: dashboardLeadingToolbarPlacement) {
                    Button {
                        showingSettingsSheet = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }

                ToolbarItem(placement: .principal) {
                    TimeLeftNavigationBrand()
                }

                ToolbarItem(placement: dashboardTrailingToolbarPlacement) {
                    Button {
                        showingNewGoalSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
        }
        .sheet(isPresented: $showingNewGoalSheet) {
            GoalEditorView { draft in
                appState.createGoal(from: draft)
                showingNewGoalSheet = false
            }
        }
        .sheet(isPresented: $showingSettingsSheet) {
            NavigationStack {
                SettingsView(appState: appState)
                    .navigationTitle("Settings")
                    .toolbar {
                        ToolbarItem(placement: dashboardTrailingToolbarPlacement) {
                            Button("Done") {
                                showingSettingsSheet = false
                            }
                        }
                    }
            }
        }
        .alert(
            "Delete Countdown?",
            isPresented: Binding(
                get: { goalPendingDeletion != nil },
                set: { if !$0 { goalPendingDeletion = nil } }
            ),
            presenting: goalPendingDeletion
        ) { goal in
            Button("Delete", role: .destructive) {
                appState.deleteGoal(goal.id)
                goalPendingDeletion = nil
            }
            Button("Cancel", role: .cancel) {
                goalPendingDeletion = nil
            }
        } message: { goal in
            Text("\"\(goal.title)\" will be removed from your countdowns.")
        }
    }

    private var dashboardLeadingToolbarPlacement: ToolbarItemPlacement {
        #if os(iOS)
        .topBarLeading
        #else
        .navigation
        #endif
    }

    private var dashboardTrailingToolbarPlacement: ToolbarItemPlacement {
        #if os(iOS)
        .topBarTrailing
        #else
        .automatic
        #endif
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                TimeLeftBrandMark(size: 42)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Timeflies")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Feel the countdown")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.74))
                }

                Spacer()
            }

            Text("Make every deadline feel real.")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Track what matters, keep the remaining time visible, and turn pressure into progress.")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.82))
                .lineLimit(2)

            HStack(spacing: 12) {
                heroMetric(value: "\(appState.goals.count)", label: "Goals")
                heroMetric(value: "\(appState.goals.reduce(0) { $0 + $1.incompleteTaskCount })", label: "Tasks Left")
            }
        }
        .padding(18)
        .timeLeftCardStyle(
            fill: LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.22, blue: 0.48),
                    Color(red: 0.21, green: 0.46, blue: 0.76),
                    Color(red: 0.42, green: 0.66, blue: 0.72),
                    Color(red: 0.93, green: 0.64, blue: 0.28)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private var quickStats: some View {
        HStack(spacing: 12) {
            quickStatTile(
                title: "Most urgent",
                value: appState.goals.sorted { $0.remainingDuration < $1.remainingDuration }.first?.title ?? "None yet",
                icon: "bolt.fill"
            )
            quickStatTile(
                title: "Completed",
                value: "\(appState.goals.reduce(0) { $0 + $1.completedTaskCount }) tasks done",
                icon: "checkmark.seal.fill"
            )
        }
        .padding(.horizontal, 20)
    }

    private var sortBar: some View {
        HStack {
            Label("Sort by", systemImage: "arrow.up.arrow.down.circle")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Spacer()

            Menu {
                Picker("Sort Countdowns", selection: $appState.goalSortOption) {
                    ForEach(GoalSortOption.allCases) { option in
                        Label(option.title, systemImage: option.systemImage)
                            .tag(option)
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: appState.goalSortOption.systemImage)
                    Text(appState.goalSortOption.title)
                        .lineLimit(1)
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color(red: 0.11, green: 0.20, blue: 0.36))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.white.opacity(0.95), in: Capsule())
            }
        }
    }

    private func heroMetric(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .monospacedDigit()
            Text(label.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white.opacity(0.70))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func quickStatTile(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline.weight(.semibold))
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private extension View {
    @ViewBuilder
    func compactNavigationTitleDisplayMode() -> some View {
        #if os(iOS)
        navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }
}

private struct GoalRowView: View {
    let goal: CountdownGoal

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Circle()
                            .fill(goal.palette.secondary)
                            .frame(width: 10, height: 10)

                        Text(goal.urgencyLabel)
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(goal.palette.accent.opacity(0.9), in: Capsule())
                    }

                    Text(goal.title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.primary)
                }
                Spacer()
            }

            Text(goal.statusLine)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(goal.isOverdue ? .red : goal.palette.primary)
                .monospacedDigit()

            ProgressView(value: goal.progress)
                .tint(goal.isOverdue ? .red : goal.palette.secondary)

            HStack {
                Label("\(goal.completedTaskCount)/\(goal.tasks.count) complete", systemImage: "checkmark.circle.fill")
                Spacer()
                Text(goal.endDate.formatted(date: .abbreviated, time: .omitted))
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [goal.palette.accent.opacity(0.92), .white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(goal.palette.secondary.opacity(0.50), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 10, y: 6)
    }
}
