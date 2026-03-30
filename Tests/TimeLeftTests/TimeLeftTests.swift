import Foundation
import Testing
@testable import TimeLeft

@Test
func durationGoalComputesEndDateAndProgress() {
    let start = Date(timeIntervalSince1970: 0)
    let end = Date(timeIntervalSince1970: 86_400 * 10)
    let goal = CountdownGoal(
        title: "Ship MVP",
        startDate: start,
        endDate: end
    )

    #expect(goal.totalDuration == 86_400 * 10)
    #expect(goal.completedTaskCount == 0)
    #expect(goal.incompleteTaskCount == 0)
}

@Test
func relativeFormatterShowsDaysWhenNeeded() {
    let now = Date(timeIntervalSince1970: 0)
    let target = Date(timeIntervalSince1970: 86_400 * 2 + 3_600 * 5)

    #expect(RelativeTimeFormatter.timeLeft(until: target, mode: .day, relativeTo: now) == "2.2 days left")
}
