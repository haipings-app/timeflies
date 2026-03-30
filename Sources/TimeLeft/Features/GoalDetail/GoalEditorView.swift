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

    private var palette: GoalPalette {
        GoalPalette.all.first(where: { $0.id == draft.colorName }) ?? .fallback
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $draft.title)
                        .focused($focusedField, equals: .title)
                        .titleAutocapitalization()

                    TextField("Notes or context", text: $draft.note, axis: .vertical)
                        .focused($focusedField, equals: .note)

                    Picker("Schedule", selection: $draft.scheduleMode) {
                        ForEach(GoalScheduleMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }

                    DatePicker("Start", selection: $draft.startDate)

                    if draft.scheduleMode == .fixedDates {
                        DatePicker("Deadline", selection: $draft.endDate)
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
                    VStack(alignment: .leading, spacing: 10) {
                        GoalPreviewCard(draft: draft)
                            .textCase(nil)

                        editorSectionHeader("Deadline")
                    }
                    .padding(.bottom, 8)
                }

                Section {
                    ReminderSettingsFields(settings: $draft.reminderSettings)
                } header: {
                    editorSectionHeader("Reminder Plan")
                        .textCase(nil)
                }

                Section {
                    Text("Enter one task per line")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TextEditor(text: $draft.taskLines)
                        .frame(minHeight: 120)
                } header: {
                    editorSectionHeader("Tasks")
                        .textCase(nil)
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
            .navigationTitle("New Countdown")
            .compactNavigationTitleDisplayMode()
            .toolbar {
                ToolbarItem(placement: editorCancelToolbarPlacement) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: editorConfirmToolbarPlacement) {
                    Button("Create") {
                        onSave(draft)
                    }
                    .disabled(draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                #if os(iOS)
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
                #endif
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    focusedField = .title
                }
            }
        }
    }

    private func editorSectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title3.weight(.bold))
            .foregroundStyle(Color.black.opacity(0.82))
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(palette.accent.opacity(0.85), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var editorCancelToolbarPlacement: ToolbarItemPlacement {
        #if os(iOS)
        .cancellationAction
        #else
        .navigation
        #endif
    }

    private var editorConfirmToolbarPlacement: ToolbarItemPlacement {
        #if os(iOS)
        .confirmationAction
        #else
        .automatic
        #endif
    }
}

private extension View {
    @ViewBuilder
    func titleAutocapitalization() -> some View {
        #if os(iOS)
        textInputAutocapitalization(.words)
        #else
        self
        #endif
    }

    @ViewBuilder
    func compactNavigationTitleDisplayMode() -> some View {
        #if os(iOS)
        navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }
}

struct ReminderSettingsFields: View {
    @Binding var settings: ReminderSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    compactToggle("iPhone", isOn: $settings.localNotificationsEnabled)
                    compactToggle("Email", isOn: $settings.emailEnabled)
                    compactToggle("SMS", isOn: $settings.smsEnabled)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }

            if settings.emailEnabled || settings.smsEnabled {
                VStack(alignment: .leading, spacing: 10) {
                    if settings.emailEnabled {
                        TextField("Email address", text: $settings.emailAddress)
                            .textFieldStyle(.roundedBorder)
                    }

                    if settings.smsEnabled {
                        TextField("Phone number", text: $settings.phoneNumber)
                            .textFieldStyle(.roundedBorder)
                    }
                }
            }

            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Frequency")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Picker("Frequency", selection: $settings.frequency) {
                        ForEach(ReminderFrequency.allCases) { frequency in
                            Text(frequency.title).tag(frequency)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Time")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Picker("Preferred time", selection: $settings.preferredHour) {
                        ForEach(0..<24, id: \.self) { hour in
                            Text(String(format: "%02d:00", hour)).tag(hour)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(.quaternary.opacity(0.55), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }

            if settings.frequency == .customDays {
                HStack {
                    Text("Repeat every \(settings.customIntervalDays) days")
                        .font(.subheadline)
                    Spacer()
                    Stepper("", value: $settings.customIntervalDays, in: 1...30)
                        .labelsHidden()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(.quaternary.opacity(0.35), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

            Toggle("Increase urgency near the deadline", isOn: $settings.smartEscalation)
                .font(.subheadline)
        }
    }

    private func compactToggle(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .toggleStyle(.button)
        .buttonStyle(.bordered)
        .frame(maxWidth: .infinity, minHeight: 36, alignment: .center)
    }
}

private struct GoalPalettePicker: View {
    @Binding var selection: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Style")
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

            Text(draft.scheduleMode == .duration ? "A focused time window with visible urgency." : "A fixed deadline with a clear finish line.")
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
