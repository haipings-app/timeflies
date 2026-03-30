import Foundation

enum GoalScheduleMode: String, Codable, CaseIterable, Identifiable {
    case fixedDates
    case duration

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fixedDates:
            return "Start + End"
        case .duration:
            return "Time Interval"
        }
    }
}

enum ReminderFrequency: String, Codable, CaseIterable, Identifiable {
    case daily
    case weekly
    case customDays

    var id: String { rawValue }

    var title: String {
        switch self {
        case .daily:
            return "Daily"
        case .weekly:
            return "Weekly"
        case .customDays:
            return "Every N Days"
        }
    }
}

enum GoalSortOption: String, CaseIterable, Identifiable {
    case urgency
    case newest
    case alphabetical
    case progress

    var id: String { rawValue }

    var title: String {
        switch self {
        case .urgency:
            return "Most Urgent"
        case .newest:
            return "Newest"
        case .alphabetical:
            return "Title A-Z"
        case .progress:
            return "Most Complete"
        }
    }

    var systemImage: String {
        switch self {
        case .urgency:
            return "flame.fill"
        case .newest:
            return "clock.arrow.circlepath"
        case .alphabetical:
            return "textformat.abc"
        case .progress:
            return "chart.bar.fill"
        }
    }
}

enum RemainingTimeDisplayMode: String, Codable, CaseIterable, Identifiable {
    case year
    case month
    case day
    case second

    var id: String { rawValue }

    var title: String {
        switch self {
        case .year:
            return "Year"
        case .month:
            return "Month"
        case .day:
            return "Day"
        case .second:
            return "Second"
        }
    }

    var shortTitle: String {
        switch self {
        case .year:
            return "Y"
        case .month:
            return "M"
        case .day:
            return "D"
        case .second:
            return "S"
        }
    }
}

struct ReminderSettings: Codable, Equatable {
    var localNotificationsEnabled: Bool = true
    var emailEnabled: Bool = false
    var smsEnabled: Bool = false
    var frequency: ReminderFrequency = .daily
    var customIntervalDays: Int = 3
    var preferredHour: Int = 9
    var emailAddress: String = ""
    var phoneNumber: String = ""
    var smartEscalation: Bool = true

    var summary: String {
        let channels = [
            localNotificationsEnabled ? "Mac notification" : nil,
            emailEnabled ? "Email" : nil,
            smsEnabled ? "SMS" : nil
        ]
        .compactMap { $0 }
        .joined(separator: ", ")

        let frequencyText: String
        switch frequency {
        case .daily:
            frequencyText = "every day"
        case .weekly:
            frequencyText = "every week"
        case .customDays:
            frequencyText = "every \(customIntervalDays) days"
        }

        if channels.isEmpty {
            return "No reminders"
        }

        return "\(channels), \(frequencyText) at \(preferredHour):00"
    }
}

struct TaskItem: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var title: String
    var note: String = ""
    var isCompleted: Bool = false
    var completedAt: Date?
    var createdAt: Date = .now

    mutating func toggleCompleted() {
        isCompleted.toggle()
        completedAt = isCompleted ? .now : nil
    }
}

struct CountdownGoal: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var title: String
    var note: String = ""
    var colorName: String = "Blue"
    var scheduleMode: GoalScheduleMode = .fixedDates
    var remainingTimeDisplayMode: RemainingTimeDisplayMode = .day
    var startDate: Date
    var endDate: Date
    var reminderSettings: ReminderSettings = ReminderSettings()
    var tasks: [TaskItem] = []
    var createdAt: Date = .now
    var updatedAt: Date = .now

    var totalDuration: TimeInterval {
        max(endDate.timeIntervalSince(startDate), 1)
    }

    var remainingDuration: TimeInterval {
        endDate.timeIntervalSinceNow
    }

    var elapsedDuration: TimeInterval {
        Date.now.timeIntervalSince(startDate)
    }

    var progress: Double {
        let value = elapsedDuration / totalDuration
        return min(max(value, 0), 1)
    }

    var isOverdue: Bool {
        remainingDuration <= 0
    }

    var completedTaskCount: Int {
        tasks.filter(\.isCompleted).count
    }

    var incompleteTaskCount: Int {
        tasks.count - completedTaskCount
    }

    var completionRate: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(completedTaskCount) / Double(tasks.count)
    }

    var statusLine: String {
        if isOverdue {
            return "Deadline passed"
        }
        return RelativeTimeFormatter.timeLeft(until: endDate, mode: remainingTimeDisplayMode)
    }

    mutating func touch() {
        updatedAt = .now
    }

    mutating func addTask(title: String) {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        tasks.append(TaskItem(title: title.trimmingCharacters(in: .whitespacesAndNewlines)))
        touch()
    }
}

enum RelativeTimeFormatter {
    static func timeLeft(
        until targetDate: Date,
        mode: RemainingTimeDisplayMode,
        relativeTo now: Date = .now
    ) -> String {
        let interval = targetDate.timeIntervalSince(now)
        let absInterval = max(abs(interval), 0)

        let body: String
        switch mode {
        case .year:
            let years = absInterval / (86_400 * 365.25)
            body = "\(formatted(years)) years"
        case .month:
            let months = absInterval / (86_400 * 30.44)
            body = "\(formatted(months)) months"
        case .day:
            let days = absInterval / 86_400
            body = "\(formatted(days)) days"
        case .second:
            body = "\(Int(absInterval.rounded())) sec"
        }

        return interval >= 0 ? "\(body) left" : "\(body) overdue"
    }

    private static func formatted(_ value: Double) -> String {
        if value >= 100 {
            return String(Int(value.rounded()))
        }

        let rounded = (value * 10).rounded() / 10
        if rounded == floor(rounded) {
            return String(Int(rounded))
        }
        return String(format: "%.1f", rounded)
    }
}
