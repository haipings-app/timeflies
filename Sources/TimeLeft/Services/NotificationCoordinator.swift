import Foundation
import UserNotifications

actor NotificationCoordinator {
    func requestAuthorizationIfNeeded() async {
        do {
            _ = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            print("Notification authorization failed:", error.localizedDescription)
        }
    }

    func reschedule(for goals: [CountdownGoal]) async {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        for goal in goals where goal.reminderSettings.localNotificationsEnabled && !goal.isOverdue {
            let content = UNMutableNotificationContent()
            content.title = goal.title
            content.body = "\(goal.statusLine). \(goal.incompleteTaskCount) tasks still need attention."
            content.sound = .default

            var components = DateComponents()
            components.hour = goal.reminderSettings.preferredHour
            components.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(
                identifier: "goal-\(goal.id.uuidString)",
                content: content,
                trigger: trigger
            )

            do {
                try await center.add(request)
            } catch {
                print("Failed to schedule notification:", error.localizedDescription)
            }
        }
    }
}
