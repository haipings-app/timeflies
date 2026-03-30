import SwiftUI

struct GoalDetailView: View {
    @Binding var goal: CountdownGoal
    @State private var newTaskTitle = ""
    @FocusState private var titleFieldFocused: Bool

    let onAddTask: (String) -> Void
    let onToggleTask: (UUID) -> Void
    let onDeleteTask: (UUID) -> Void
    let onTaskNoteChange: (UUID, String) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                countdownCard
                timelineCard
                tasksCard
                remindersCard
            }
            .padding(20)
        }
        .background(detailBackground.ignoresSafeArea())
        .navigationTitle(goal.title)
        .onChange(of: goal.startDate) { _, _ in
            if goal.endDate < goal.startDate {
                goal.endDate = goal.startDate.addingTimeInterval(60)
            }
            goal.touch()
        }
        .onChange(of: goal.endDate) { _, _ in
            if goal.endDate < goal.startDate {
                goal.endDate = goal.startDate.addingTimeInterval(60)
            }
            goal.touch()
        }
        .onChange(of: goal.remainingTimeDisplayMode) { _, _ in
            goal.touch()
        }
        .onDisappear {
            goal.title = goal.title.trimmingCharacters(in: .whitespacesAndNewlines)
            goal.touch()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                TimeLeftCompactBrandBadge()

                Spacer()
            }

            HStack {
                Text(goal.urgencyLabel.uppercased())
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(goal.palette.accent.opacity(0.9), in: Capsule())

                Spacer()

                Text(goal.completionRate.formatted(.percent.precision(.fractionLength(0))))
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(goal.palette.primary)
            }

            TextField("Countdown Title", text: $goal.title)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .textFieldStyle(.plain)
                .focused($titleFieldFocused)
                .submitLabel(.done)
                .onSubmit {
                    goal.title = goal.title.trimmingCharacters(in: .whitespacesAndNewlines)
                    goal.touch()
                    titleFieldFocused = false
                }
                .onChange(of: goal.title) { _, newValue in
                    if newValue.contains("\n") {
                        goal.title = newValue.replacingOccurrences(of: "\n", with: " ").trimmingCharacters(in: .whitespacesAndNewlines)
                        goal.touch()
                        titleFieldFocused = false
                    }
                }

            Text(goal.note.isEmpty ? "Add context so future you knows what matters here." : goal.note)
                .font(.title3)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                Label(goal.startDate.formatted(date: .abbreviated, time: .omitted), systemImage: "play.circle")
                Label(goal.endDate.formatted(date: .abbreviated, time: .omitted), systemImage: "flag.checkered")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Text("Stay aware of the remaining time, then convert it into the next completed action.")
                .font(.footnote)
                .foregroundStyle(goal.palette.primary.opacity(0.78))
        }
    }

    private var countdownCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.18), lineWidth: 12)
                        .frame(width: 104, height: 104)

                    Circle()
                        .trim(from: 0, to: goal.progress)
                        .stroke(
                            AngularGradient(colors: [goal.palette.accent, .white, goal.palette.secondary], center: .center),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 104, height: 104)

                    VStack(spacing: 2) {
                        Text(goal.progress.formatted(.percent.precision(.fractionLength(0))))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .monospacedDigit()
                        Text("done")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.75))
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(goal.isOverdue ? "Deadline Passed" : "Time Remaining")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.78))

                    Text(goal.statusLine)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .monospacedDigit()
                        .lineLimit(1)

                    Text("Display: \(goal.remainingTimeDisplayMode.title)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.78))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Text(goal.isOverdue ? "The window closed. Capture what was finished and decide the next move." : "Switch the countdown between years, months, days, or seconds depending on how much urgency you want to feel.")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.80))

            HStack {
                stat(label: "Progress", value: goal.progress.formatted(.percent.precision(.fractionLength(0))), emphasized: true)
                stat(label: "Completed", value: "\(goal.completedTaskCount)", emphasized: false)
                stat(label: "Remaining", value: "\(goal.incompleteTaskCount)", emphasized: false)
            }
        }
        .padding(20)
        .timeLeftCardStyle(
            fill: LinearGradient(
                colors: [
                    goal.palette.primary,
                    goal.palette.secondary,
                    goal.palette.secondary.opacity(0.72)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            stroke: .white.opacity(0.22)
        )
    }

    private var timelineCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Timeline")
                    .font(.headline)
                Spacer()
                Picker("Remaining Mode", selection: $goal.remainingTimeDisplayMode) {
                    ForEach(RemainingTimeDisplayMode.allCases) { mode in
                        Text(mode.shortTitle).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 180)
            }

            DatePicker("Start Date", selection: $goal.startDate, displayedComponents: [.date, .hourAndMinute])
            DatePicker("Deadline", selection: $goal.endDate, in: goal.startDate..., displayedComponents: [.date, .hourAndMinute])

            HStack(spacing: 10) {
                timelinePill(label: "Starts", value: goal.startDate.formatted(date: .abbreviated, time: .shortened))
                timelinePill(label: "Ends", value: goal.endDate.formatted(date: .abbreviated, time: .shortened))
            }
        }
        .padding(18)
        .background(.white.opacity(0.86), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(goal.palette.accent.opacity(0.8), lineWidth: 1)
        )
    }

    private func timelinePill(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.weight(.semibold))
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(goal.palette.accent.opacity(0.22), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var remindersCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Reminder Plan")
                    .font(.headline)
                Spacer()
                Text(goal.reminderSettings.summary)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)
            }

            ReminderSettingsFields(settings: $goal.reminderSettings)
        }
        .padding(20)
        .background(.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(goal.palette.accent.opacity(0.8), lineWidth: 1)
        )
    }

    private var tasksCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Tasks")
                    .font(.headline)
                Spacer()
                Text("\(goal.completedTaskCount)/\(goal.tasks.count) complete")
                    .foregroundStyle(.secondary)
            }

            HStack {
                TextField("Add a task", text: $newTaskTitle)
                    .textFieldStyle(.roundedBorder)

                Button("Add") {
                    onAddTask(newTaskTitle)
                    newTaskTitle = ""
                }
                .buttonStyle(.borderedProminent)
                .tint(goal.palette.primary)
                .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            if goal.tasks.isEmpty {
                ContentUnavailableView(
                    "No Tasks Yet",
                    systemImage: "checklist",
                    description: Text("Break the deadline into smaller steps to make the time pressure actionable.")
                )
            } else {
                ForEach(goal.tasks) { task in
                    TaskRowView(
                        task: task,
                        palette: goal.palette,
                        onToggle: { onToggleTask(task.id) },
                        onDelete: { onDeleteTask(task.id) },
                        onNoteChange: { onTaskNoteChange(task.id, $0) }
                    )
                }
            }
        }
        .padding(20)
        .background(.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(goal.palette.accent.opacity(0.8), lineWidth: 1)
        )
    }

    private func stat(label: String, value: String, emphasized: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.title3.weight(.semibold))
                .foregroundStyle(emphasized ? .white : .white.opacity(0.90))
            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.72))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var detailBackground: some View {
        LinearGradient(
            colors: [
                goal.palette.accent.opacity(0.50),
                .white,
                goal.palette.secondary.opacity(0.16)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private struct TaskRowView: View {
    let task: TaskItem
    let palette: GoalPalette
    let onToggle: () -> Void
    let onDelete: () -> Void
    let onNoteChange: (String) -> Void

    @State private var noteText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Button(action: onToggle) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(task.isCompleted ? palette.primary : palette.secondary)
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .strikethrough(task.isCompleted)
                        .foregroundStyle(task.isCompleted ? .secondary : .primary)

                    if let completedAt = task.completedAt {
                        Text("Completed \(completedAt.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.borderless)
            }

            TextField("Add note", text: $noteText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .onAppear {
                    noteText = task.note
                }
                .onSubmit {
                    onNoteChange(noteText)
                }
        }
        .padding(14)
        .background(task.isCompleted ? palette.accent.opacity(0.28) : .white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(task.isCompleted ? palette.secondary.opacity(0.35) : Color.secondary.opacity(0.20), lineWidth: 1)
        )
    }
}
