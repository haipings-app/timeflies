import SwiftUI

struct GoalPalette: Identifiable, Equatable {
    let id: String
    let name: String
    let primary: Color
    let secondary: Color
    let accent: Color

    static let all: [GoalPalette] = [
        GoalPalette(id: "Arctic", name: "Arctic", primary: Color(red: 0.10, green: 0.31, blue: 0.56), secondary: Color(red: 0.52, green: 0.80, blue: 0.94), accent: Color(red: 0.86, green: 0.95, blue: 0.99)),
        GoalPalette(id: "Ocean", name: "Ocean", primary: Color(red: 0.07, green: 0.28, blue: 0.60), secondary: Color(red: 0.35, green: 0.70, blue: 0.95), accent: Color(red: 0.81, green: 0.93, blue: 0.99)),
        GoalPalette(id: "Mint", name: "Mint", primary: Color(red: 0.07, green: 0.42, blue: 0.38), secondary: Color(red: 0.39, green: 0.79, blue: 0.67), accent: Color(red: 0.84, green: 0.96, blue: 0.92)),
        GoalPalette(id: "Lime", name: "Lime", primary: Color(red: 0.36, green: 0.49, blue: 0.06), secondary: Color(red: 0.74, green: 0.85, blue: 0.25), accent: Color(red: 0.93, green: 0.97, blue: 0.78)),
        GoalPalette(id: "Amber", name: "Amber", primary: Color(red: 0.68, green: 0.38, blue: 0.04), secondary: Color(red: 0.96, green: 0.70, blue: 0.22), accent: Color(red: 1.00, green: 0.93, blue: 0.78)),
        GoalPalette(id: "Coral", name: "Coral", primary: Color(red: 0.69, green: 0.22, blue: 0.15), secondary: Color(red: 0.95, green: 0.49, blue: 0.34), accent: Color(red: 0.99, green: 0.88, blue: 0.82))
    ]

    static let fallback = GoalPalette(id: "Ocean", name: "Ocean", primary: Color.blue, secondary: Color.cyan, accent: Color.white)
}

extension CountdownGoal {
    var palette: GoalPalette {
        GoalPalette.all.first(where: { $0.id == colorName }) ?? .fallback
    }

    var urgencyLabel: String {
        if isOverdue {
            return "Expired"
        }

        let daysLeft = Int(max(remainingDuration, 0)) / 86_400
        switch daysLeft {
        case 0...2:
            return "Critical"
        case 3...7:
            return "Urgent"
        case 8...21:
            return "Active"
        default:
            return "Planned"
        }
    }
}

extension View {
    func timeLeftCardStyle(fill: LinearGradient, stroke: Color = .white.opacity(0.18)) -> some View {
        self
            .background(fill, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(stroke, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.10), radius: 22, y: 16)
    }
}
