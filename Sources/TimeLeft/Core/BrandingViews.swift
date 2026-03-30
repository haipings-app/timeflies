import SwiftUI

struct TimeLeftBrandMark: View {
    var size: CGFloat = 52

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.10, green: 0.18, blue: 0.38),
                            Color(red: 0.24, green: 0.52, blue: 0.90),
                            Color(red: 0.94, green: 0.56, blue: 0.24)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                )
                )

            VStack(spacing: size * 0.07) {
                Capsule()
                    .fill(.white.opacity(0.95))
                    .frame(width: size * 0.48, height: size * 0.08)

                ZStack {
                    HourglassFrameShape()
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.94), Color(red: 1.0, green: 0.95, blue: 0.88)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: size * 0.075, lineCap: .round, lineJoin: .round)
                        )
                        .frame(width: size * 0.48, height: size * 0.66)

                    HourglassSandTopShape()
                        .fill(Color(red: 1.0, green: 0.93, blue: 0.78).opacity(0.98))
                        .frame(width: size * 0.26, height: size * 0.18)
                        .offset(y: -size * 0.13)

                    HourglassSandBottomShape()
                        .fill(Color(red: 1.0, green: 0.83, blue: 0.56).opacity(0.98))
                        .frame(width: size * 0.22, height: size * 0.14)
                        .offset(y: size * 0.16)

                    Capsule()
                        .fill(Color(red: 1.0, green: 0.87, blue: 0.62))
                        .frame(width: size * 0.038, height: size * 0.16)

                    Circle()
                        .fill(Color(red: 1.0, green: 0.88, blue: 0.66))
                        .frame(width: size * 0.06, height: size * 0.06)
                        .offset(y: size * 0.12)
                }

                Capsule()
                    .fill(.white.opacity(0.95))
                    .frame(width: size * 0.48, height: size * 0.08)
            }
        }
        .frame(width: size, height: size)
    }
}

private struct HourglassFrameShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.1, y: rect.minY))
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.midY),
            control1: CGPoint(x: rect.minX + rect.width * 0.12, y: rect.minY + rect.height * 0.28),
            control2: CGPoint(x: rect.midX - rect.width * 0.12, y: rect.midY - rect.height * 0.08)
        )
        path.addCurve(
            to: CGPoint(x: rect.maxX - rect.width * 0.1, y: rect.maxY),
            control1: CGPoint(x: rect.midX + rect.width * 0.12, y: rect.midY + rect.height * 0.08),
            control2: CGPoint(x: rect.maxX - rect.width * 0.12, y: rect.maxY - rect.height * 0.28)
        )

        path.move(to: CGPoint(x: rect.maxX - rect.width * 0.1, y: rect.minY))
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.midY),
            control1: CGPoint(x: rect.maxX - rect.width * 0.12, y: rect.minY + rect.height * 0.28),
            control2: CGPoint(x: rect.midX + rect.width * 0.12, y: rect.midY - rect.height * 0.08)
        )
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.1, y: rect.maxY),
            control1: CGPoint(x: rect.midX - rect.width * 0.12, y: rect.midY + rect.height * 0.08),
            control2: CGPoint(x: rect.minX + rect.width * 0.12, y: rect.maxY - rect.height * 0.28)
        )
        return path
    }
}

private struct HourglassSandTopShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control1: CGPoint(x: rect.maxX - rect.width * 0.08, y: rect.midY),
            control2: CGPoint(x: rect.midX + rect.width * 0.14, y: rect.maxY - rect.height * 0.1)
        )
        path.addCurve(
            to: CGPoint(x: rect.minX, y: rect.minY),
            control1: CGPoint(x: rect.midX - rect.width * 0.14, y: rect.maxY - rect.height * 0.1),
            control2: CGPoint(x: rect.minX + rect.width * 0.08, y: rect.midY)
        )
        return path
    }
}

private struct HourglassSandBottomShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY - rect.height * 0.22),
            control1: CGPoint(x: rect.midX + rect.width * 0.12, y: rect.minY + rect.height * 0.12),
            control2: CGPoint(x: rect.maxX - rect.width * 0.1, y: rect.maxY - rect.height * 0.4)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - rect.height * 0.22),
            control: CGPoint(x: rect.midX, y: rect.maxY + rect.height * 0.18)
        )
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control1: CGPoint(x: rect.minX + rect.width * 0.1, y: rect.maxY - rect.height * 0.4),
            control2: CGPoint(x: rect.midX - rect.width * 0.12, y: rect.minY + rect.height * 0.12)
        )
        return path
    }
}

struct TimeLeftWordmark: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Timeflies")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("FEEL THE COUNTDOWN")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(1.8)
                .foregroundStyle(.white.opacity(0.74))
        }
    }
}

struct TimeLeftBrandHeader: View {
    var body: some View {
        HStack(spacing: 12) {
            TimeLeftBrandMark(size: 54)
            TimeLeftWordmark()
            Spacer()
        }
    }
}

struct TimeLeftCompactBrandBadge: View {
    var body: some View {
        HStack(spacing: 8) {
            TimeLeftBrandMark(size: 28)
            Text("Timeflies")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.white.opacity(0.72), in: Capsule())
    }
}

struct TimeLeftDetailBrandBadge: View {
    let palette: GoalPalette

    var body: some View {
        HStack(spacing: 10) {
            TimeLeftBrandMark(size: 34)

            VStack(alignment: .leading, spacing: 2) {
                Text("Timeflies")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)

                Text("FEEL THE COUNTDOWN")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(1.2)
                    .foregroundStyle(Color.white.opacity(0.76))
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            LinearGradient(
                colors: [palette.primary, palette.secondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.white.opacity(0.16), lineWidth: 1)
        )
    }
}

struct TimeLeftNavigationBrand: View {
    var body: some View {
        HStack(spacing: 8) {
            TimeLeftBrandMark(size: 22)
            Text("Timeflies")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.09, green: 0.16, blue: 0.30))
        }
    }
}

struct LaunchSplashView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.09, green: 0.11, blue: 0.24),
                    Color(red: 0.19, green: 0.36, blue: 0.64),
                    Color(red: 0.94, green: 0.53, blue: 0.23)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 22) {
                TimeLeftBrandMark(size: 122)
                    .scaleEffect(animate ? 1 : 0.84)
                    .opacity(animate ? 1 : 0.75)
                    .shadow(color: .black.opacity(0.18), radius: 20, y: 14)
                    .rotationEffect(.degrees(animate ? 0 : -8))

                VStack(spacing: 8) {
                    Text("Timeflies")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Turn deadlines into motion.")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.82))
                }

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.18))
                        .frame(width: 170, height: 6)

                    Capsule()
                        .fill(.white)
                        .frame(width: animate ? 170 : 56, height: 6)
                }
                .animation(.easeInOut(duration: 0.9), value: animate)
            }
            .padding(24)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animate = true
            }
        }
    }
}
