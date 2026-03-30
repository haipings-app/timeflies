import Foundation
import Observation

@MainActor
@Observable
final class AppState {
    var goals: [CountdownGoal] = [] {
        didSet {
            guard hasFinishedInitialLoad else { return }
            persist()
        }
    }

    var selectedGoalID: UUID?
    var goalSortOption: GoalSortOption = .urgency
    var emailSenderName: String = "Not configured yet"
    var smsProviderName: String = "Not configured yet"

    private let storageURL: URL
    private let notificationCoordinator = NotificationCoordinator()
    private var hasFinishedInitialLoad = false

    init() {
        let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        storageURL = baseURL
            .appendingPathComponent("TimeLeft", isDirectory: true)
            .appendingPathComponent("goals.json", isDirectory: false)

        load()
        hasFinishedInitialLoad = true

        if goals.isEmpty {
            goals = SampleData.goals
            selectedGoalID = goals.first?.id
        } else {
            selectedGoalID = goals.first?.id
        }

        let initialGoals = goals
        let coordinator = notificationCoordinator
        Task {
            await coordinator.requestAuthorizationIfNeeded()
            await coordinator.reschedule(for: initialGoals)
        }
    }

    func createGoal(from draft: GoalDraft) {
        goals.append(draft.makeGoal())
        selectedGoalID = goals.last?.id
    }

    func deleteGoals(at offsets: IndexSet) {
        let idsToDelete = offsets.map { goals[$0].id }
        goals.remove(atOffsets: offsets)
        if let currentSelectedGoalID = selectedGoalID, idsToDelete.contains(currentSelectedGoalID) {
            selectedGoalID = goals.first?.id
        }
    }

    func deleteGoal(_ goalID: UUID) {
        let wasSelected = selectedGoalID == goalID
        goals.removeAll { $0.id == goalID }
        if wasSelected {
            selectedGoalID = goals.first?.id
        }
    }

    func duplicateSelectedGoal() {
        guard let index = selectedGoalIndex else { return }
        var copy = goals[index]
        copy.id = UUID()
        copy.title += " Copy"
        copy.createdAt = .now
        copy.updatedAt = .now
        copy.tasks = copy.tasks.map { task in
            var newTask = task
            newTask.id = UUID()
            return newTask
        }
        goals.insert(copy, at: index + 1)
        selectedGoalID = copy.id
    }

    func addTask(to goalID: UUID, title: String) {
        guard let index = index(for: goalID) else { return }
        goals[index].addTask(title: title)
    }

    func toggleTask(goalID: UUID, taskID: UUID) {
        guard let goalIndex = index(for: goalID),
              let taskIndex = goals[goalIndex].tasks.firstIndex(where: { $0.id == taskID }) else { return }
        goals[goalIndex].tasks[taskIndex].toggleCompleted()
        goals[goalIndex].touch()
    }

    func updateTaskTitle(goalID: UUID, taskID: UUID, title: String) {
        let cleaned = title
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty,
              let goalIndex = index(for: goalID),
              let taskIndex = goals[goalIndex].tasks.firstIndex(where: { $0.id == taskID }) else { return }
        goals[goalIndex].tasks[taskIndex].title = cleaned
        goals[goalIndex].touch()
    }

    func updateTaskNote(goalID: UUID, taskID: UUID, note: String) {
        guard let goalIndex = index(for: goalID),
              let taskIndex = goals[goalIndex].tasks.firstIndex(where: { $0.id == taskID }) else { return }
        goals[goalIndex].tasks[taskIndex].note = note
        goals[goalIndex].touch()
    }

    func deleteTask(goalID: UUID, taskID: UUID) {
        guard let goalIndex = index(for: goalID) else { return }
        goals[goalIndex].tasks.removeAll { $0.id == taskID }
        goals[goalIndex].touch()
    }

    func bindingForSelectedGoal() -> CountdownGoal? {
        guard let index = selectedGoalIndex else { return nil }
        return goals[index]
    }

    var selectedGoalIndex: Int? {
        guard let selectedGoalID else { return nil }
        return index(for: selectedGoalID)
    }

    var sortedGoals: [CountdownGoal] {
        goals.sorted(using: goalSortOption)
    }

    private func index(for goalID: UUID) -> Int? {
        goals.firstIndex { $0.id == goalID }
    }

    private func persist() {
        do {
            try FileManager.default.createDirectory(
                at: storageURL.deletingLastPathComponent(),
                withIntermediateDirectories: true,
                attributes: nil
            )
            let data = try JSONEncoder.pretty.encode(goals)
            try data.write(to: storageURL, options: .atomic)
        } catch {
            print("Failed to save goals:", error.localizedDescription)
        }

        let currentGoals = goals
        let coordinator = notificationCoordinator
        Task {
            await coordinator.reschedule(for: currentGoals)
        }
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: storageURL.path) else { return }

        do {
            let data = try Data(contentsOf: storageURL)
            goals = try JSONDecoder.appState.decode([CountdownGoal].self, from: data)
        } catch {
            print("Failed to load goals:", error.localizedDescription)
            goals = []
        }
    }
}

private extension Array where Element == CountdownGoal {
    func sorted(using option: GoalSortOption) -> [CountdownGoal] {
        sorted { lhs, rhs in
            switch option {
            case .urgency:
                if lhs.isOverdue != rhs.isOverdue {
                    return lhs.isOverdue && !rhs.isOverdue
                }
                if lhs.endDate != rhs.endDate {
                    return lhs.endDate < rhs.endDate
                }
                return lhs.createdAt > rhs.createdAt
            case .newest:
                return lhs.createdAt > rhs.createdAt
            case .alphabetical:
                return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
            case .progress:
                if lhs.completionRate != rhs.completionRate {
                    return lhs.completionRate > rhs.completionRate
                }
                return lhs.endDate < rhs.endDate
            }
        }
    }
}

extension JSONEncoder {
    static var pretty: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

extension JSONDecoder {
    static var appState: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
