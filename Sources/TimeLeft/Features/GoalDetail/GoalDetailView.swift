import SwiftUI

struct GoalDetailView: View {
    @Binding var goal: CountdownGoal
    @State private var newTaskTitle = ""
    @FocusState private var titleFieldFocused: Bool
    @State private var now = Date.now

    let onAddTask: (String) -> Void
    let onToggleTask: (UUID) -> Void
    let onDeleteTask: (UUID) -> Void
    let onTaskTitleChange: (UUID, String) -> Void
    let onTaskNoteChange: (UUID, String) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                header
                countdownCard
                timelineCard
                tasksCard
                remindersCard
            }
            .padding(16)
        }
        .background(detailBackground.ignoresSafeArea())
        .navigationTitle(goal.title)
        .task {
            while !Task.isCancelled {
                now = .now
                try? await Task.sleep(for: .seconds(1))
            }
        }
        .onChange(of: goal.endDate) { _, _ in
            if goal.endDate < now {
                goal.endDate = now.addingTimeInterval(60)
            }
            goal.touch()
        }
        .onChange(of: goal.remainingTimeDisplayMode) { _, _ in
            goal.touch()
        }
        .onChange(of: goal.colorName) { _, _ in
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
                TimeLeftDetailBrandBadge(palette: goal.palette)

                Spacer()
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
        }
    }

    private var countdownCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                timelinePill(label: "Now", value: now.formatted(date: .abbreviated, time: .shortened))
                timelinePill(label: "Ends", value: goal.endDate.formatted(date: .abbreviated, time: .shortened))
            }

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
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack {
                stat(label: "Progress", value: goal.progress.formatted(.percent.precision(.fractionLength(0))), emphasized: true)
                stat(label: "Completed", value: "\(goal.completedTaskCount)", emphasized: false)
                stat(label: "Remaining", value: "\(goal.incompleteTaskCount)", emphasized: false)
            }

            HStack {
                Spacer()

                Picker("Remaining Mode", selection: $goal.remainingTimeDisplayMode) {
                    ForEach(RemainingTimeDisplayMode.allCases) { mode in
                        Text(mode.shortTitle).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 180)

                Spacer()
            }

            CountdownColorPicker(selection: $goal.colorName)
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
            sectionHeader("Deadline")

            HStack {
                Spacer()
                DatePicker("", selection: $goal.endDate, in: now..., displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
                    .tint(.red)
                Spacer()
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
            sectionHeader("Reminder Plan")

            HStack {
                Text(goal.reminderSettings.summary)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
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
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Tasks")

            HStack {
                Text("\(goal.completedTaskCount)/\(goal.tasks.count) complete")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
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
                    description: Text("Break the deadline into smaller steps so the pressure becomes something you can act on.")
                )
            } else {
                ForEach(goal.tasks) { task in
                    TaskRowView(
                        task: task,
                        palette: goal.palette,
                        onToggle: { onToggleTask(task.id) },
                        onDelete: { onDeleteTask(task.id) },
                        onTitleChange: { onTaskTitleChange(task.id, $0) },
                        onNoteChange: { onTaskNoteChange(task.id, $0) }
                    )
                }
            }
        }
        .padding(16)
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

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title3.weight(.bold))
            .foregroundStyle(Color.black.opacity(0.82))
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(goal.palette.accent.opacity(0.85), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
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
    let onTitleChange: (String) -> Void
    let onNoteChange: (String) -> Void

    @State private var titleText: String = ""
    @State private var noteText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Button(action: onToggle) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(task.isCompleted ? palette.primary : palette.secondary)
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 2) {
                    TextField("Task Title", text: $titleText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .font(.body.weight(.medium))
                        .strikethrough(task.isCompleted)
                        .foregroundStyle(task.isCompleted ? .secondary : .primary)
                        .onAppear {
                            titleText = task.title
                        }
                        .onSubmit {
                            commitTitle()
                        }

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

            TextField("Add a note", text: $noteText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .onAppear {
                    if noteText.isEmpty {
                        noteText = task.note
                    }
                }
                .onSubmit {
                    onNoteChange(noteText)
                }
        }
        .padding(11)
        .background(task.isCompleted ? palette.accent.opacity(0.28) : .white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(task.isCompleted ? palette.secondary.opacity(0.35) : Color.secondary.opacity(0.20), lineWidth: 1)
        )
        .onDisappear {
            commitTitle()
            commitNote()
        }
        .onChange(of: task.title) { _, newValue in
            if newValue != titleText {
                titleText = newValue
            }
        }
        .onChange(of: task.note) { _, newValue in
            if newValue != noteText {
                noteText = newValue
            }
        }
    }

    private func commitTitle() {
        let cleaned = titleText
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else {
            titleText = task.title
            return
        }
        titleText = cleaned
        onTitleChange(cleaned)
    }

    private func commitNote() {
        let cleaned = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned != noteText {
            noteText = cleaned
        }
        onNoteChange(cleaned)
    }
}

private struct CountdownColorPicker: View {
    @Binding var selection: String

    var body: some View {
        HStack(spacing: 10) {
            Spacer()

            ForEach(GoalPalette.all) { palette in
                Button {
                    selection = palette.id
                } label: {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [palette.primary, palette.secondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(selection == palette.id ? Color.primary : Color.clear, lineWidth: 2)
                        )
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
    }
}
