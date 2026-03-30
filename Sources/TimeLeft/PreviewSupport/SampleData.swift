import Foundation

enum SampleData {
    static let goals: [CountdownGoal] = [
        CountdownGoal(
            title: "Graduate School Application",
            note: "Complete the package before the portal closes.",
            colorName: "Amber",
            scheduleMode: .fixedDates,
            startDate: .now,
            endDate: Calendar.current.date(byAdding: .day, value: 45, to: .now) ?? .now,
            reminderSettings: ReminderSettings(
                localNotificationsEnabled: true,
                emailEnabled: true,
                smsEnabled: false,
                frequency: .daily,
                customIntervalDays: 2,
                preferredHour: 9,
                emailAddress: "you@example.com",
                phoneNumber: "",
                smartEscalation: true
            ),
            tasks: [
                TaskItem(title: "Finalize personal statement"),
                TaskItem(title: "Ask recommender #1", isCompleted: true, completedAt: .now),
                TaskItem(title: "Order official transcript", note: "Upload PDF once received")
            ]
        ),
        CountdownGoal(
            title: "Launch Demo Day",
            note: "Keep the demo reliable and crisp.",
            colorName: "Ocean",
            scheduleMode: .duration,
            startDate: .now,
            endDate: Calendar.current.date(byAdding: .day, value: 14, to: .now) ?? .now,
            reminderSettings: ReminderSettings(
                localNotificationsEnabled: true,
                emailEnabled: false,
                smsEnabled: false,
                frequency: .weekly,
                customIntervalDays: 7,
                preferredHour: 10,
                emailAddress: "",
                phoneNumber: "",
                smartEscalation: true
            ),
            tasks: [
                TaskItem(title: "Freeze scope"),
                TaskItem(title: "Polish walkthrough script"),
                TaskItem(title: "Run full rehearsal")
            ]
        )
    ]
}
