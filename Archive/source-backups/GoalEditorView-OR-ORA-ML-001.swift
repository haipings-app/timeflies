import SwiftUI

struct GoalDraft {
    var title: String = ""
    var note: String = ""
    var colorName: String = GoalPalette.fallback.id
    var scheduleMode: GoalScheduleMode = .fixedDates
    var remainingTimeDisplayMode: RemainingTimeDisplayMode = .day
    var startDate: Date = .now
    var endDate: Date = Calendar.current.date(byAdding: .day, value: 30, to: .now) ?? .now
    var durationDays: Int = 30
    var reminderSettings = ReminderSettings()
    var taskLines: String = ""

    func makeGoal() -> CountdownGoal {
        let resolvedEndDate: Date
        if scheduleMode == .duration {
            resolvedEndDate = Calendar.current.date(byAdding: .day, value: durationDays, to: startDate) ?? endDate
        } else {
            resolvedEndDate = max(endDate, startDate.addingTimeInterval(60))
        }

        let tasks = taskLines
            .split(whereSeparator: \.isNewline)
            .map { TaskItem(title: String($0).trimmingCharacters(in: .whitespacesAndNewlines)) }
            .filter { !$0.title.isEmpty }

        return CountdownGoal(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            note: note,
            colorName: colorName,
            scheduleMode: scheduleMode,
            remainingTimeDisplayMode: remainingTimeDisplayMode,
            startDate: startDate,
            endDate: resolvedEndDate,
            reminderSettings: reminderSettings,
            tasks: tasks
        )
    }
}

struct GoalEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft = GoalDraft()
    @FocusState private var focusedField: EditorField?

    let onSave: (GoalDraft) -> Void

    private enum EditorField {
        case title
        case note
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $draft.title)
                        .focused($focusedField, equals: .title)
                        .textInputAutocapitalization(.words)

                    TextField("Notes", text: $draft.note, axis: .vertical)
                        .focused($focusedField, equals: .note)

                    Picker("Schedule", selection: $draft.scheduleMode) {
                        ForEach(GoalScheduleMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }

                    DatePicker("Start", selection: $draft.startDate)

                    if draft.scheduleMode == .fixedDates {
                        DatePicker("End", selection: $draft.endDate)
                    } else {
                        Stepper(value: $draft.durationDays, in: 1...365) {
                            Text("Duration: \(draft.durationDays) days")
                        }
                    }

                    GoalPalettePicker(selection: $draft.colorName)

                    Picker("Time Remaining", selection: $draft.remainingTimeDisplayMode) {
                        ForEach(RemainingTimeDisplayMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                } header: {
                    GoalPreviewCard(draft: draft)
                        .textCase(nil)
                        .padding(.bottom, 8)
                }

                Section("Reminders") {
                    ReminderSettingsFields(settings: $draft.reminderSettings)
                }

                Section("Initial Tasks") {
                    Text("One task per line")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TextEditor(text: $draft.taskLines)
                        .frame(minHeight: 120)
                }
            }
            .scrollContentBackground(.hidden)
            .background(
                LinearGradient(
                    colors: [Color.white, GoalPalette.all.first(where: { $0.id == draft.colorName })?.accent.opacity(0.35) ?? .white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        onSave(draft)
                    }
                    .disabled(draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    focusedField = .title
                }
            }
        }
    }
}

struct ReminderSettingsFields: View {
    @Binding var settings: ReminderSettings

    var body: some View {
        Toggle("Mac Notification", isOn: $settings.localNotificationsEnabled)
        Toggle("Email", isOn: $settings.emailEnabled)
        if settings.emailEnabled {
            TextField("Email Address", text: $settings.emailAddress)
        }

        Toggle("SMS", isOn: $settings.smsEnabled)
        if settings.smsEnabled {
            TextField("Phone Number", text: $settings.phoneNumber)
        }

        Picker("Frequency", selection: $settings.frequency) {
            ForEach(ReminderFrequency.allCases) { frequency in
                Text(frequency.title).tag(frequency)
            }
        }

        if settings.frequency == .customDays {
            Stepper(value: $settings.customIntervalDays, in: 1...30) {
                Text("Every \(settings.customIntervalDays) days")
            }
        }

        Stepper(value: $settings.preferredHour, in: 0...23) {
            Text("Preferred Hour: \(settings.preferredHour):00")
        }

        Toggle("Increase pressure near deadline", isOn: $settings.smartEscalation)
    }
}

private struct GoalPalettePicker: View {
    @Binding var selection: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Mood")
                .font(.subheadline.weight(.semibold))

            HStack(spacing: 10) {
                ForEach(GoalPalette.all) { palette in
                    Button {
                        selection = palette.id
                    } label: {
                        VStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(LinearGradient(colors: [palette.primary, palette.secondary], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(height: 44)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(selection == palette.id ? Color.primary : Color.clear, lineWidth: 2)
                                )

                            Text(palette.name)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 6)
    }
}

private struct GoalPreviewCard: View {
    let draft: GoalDraft

    var palette: GoalPalette {
        GoalPalette.all.first(where: { $0.id == draft.colorName }) ?? .fallback
    }

    var previewTitle: String {
        let trimmed = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Your Next Countdown" : trimmed
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Live Preview")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.76))

            Text(previewTitle)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(draft.scheduleMode == .duration ? "A focused interval with visible urgency." : "A fixed deadline with a clear finish line.")
                .foregroundStyle(.white.opacity(0.78))

            HStack {
                previewMetric(label: "Start", value: draft.startDate.formatted(date: .abbreviated, time: .omitted))
                previewMetric(label: "Mode", value: draft.scheduleMode.title)
                previewMetric(label: "Remain", value: draft.remainingTimeDisplayMode.title)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .timeLeftCardStyle(
            fill: LinearGradient(colors: [palette.primary, palette.secondary], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
    }

    private func previewMetric(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.headline.monospacedDigit())
                .foregroundStyle(.white)
            Text(label.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white.opacity(0.72))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
