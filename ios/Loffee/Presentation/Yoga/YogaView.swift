import SwiftUI
import UIKit

struct YogaView: View {
    @ObservedObject var viewModel: YogaViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var poseColumns: [GridItem] {
        [GridItem(.adaptive(minimum: horizontalSizeClass == .regular ? 200 : 150), spacing: 12)]
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                yogaBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        heroCard
                        sessionStageCard
                        streakCard
                        routineCard
                        achievementsCard
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 16)
                    .padding(.bottom, 36)
                }
            }
            .navigationTitle("Yoga")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var yogaBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 0.10, green: 0.17, blue: 0.23),
                Color(red: 0.21, green: 0.31, blue: 0.28),
                Color(red: 0.05, green: 0.08, blue: 0.11)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Daily Flow")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)

                    Text("Start a guided pose sequence, log your session automatically, and build a steady streak.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(viewModel.energyPoints)")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color(red: 0.98, green: 0.92, blue: 0.76))
                    Text("Energy")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.72))
                }
            }

            HStack(spacing: 12) {
                statChip(title: "Today", value: "\(viewModel.progressStore.sessionsToday)")
                statChip(title: "Streak", value: "\(viewModel.progressStore.currentStreak)d")
                statChip(title: "Longest", value: "\(viewModel.progressStore.longestStreak)d")
            }

            Text(viewModel.streakHeadline)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color(red: 0.88, green: 0.94, blue: 0.86))
        }
        .padding(20)
        .background(Color.black.opacity(0.24))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func statChip(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var sessionStageCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.currentPose.name)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)

                    Text(viewModel.currentPose.focus)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.72))
                }

                Spacer()

                Text(timeLabel(viewModel.secondsRemaining))
                    .font(.title2.monospacedDigit().weight(.bold))
                    .foregroundStyle(Color(red: 0.94, green: 0.96, blue: 0.78))
            }

            YogaPoseFigureView(pose: viewModel.currentPose, isAnimating: viewModel.isRunning)
                .frame(height: horizontalSizeClass == .regular ? 340 : 280)

            VStack(alignment: .leading, spacing: 10) {
                Text(viewModel.currentPose.cue)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.84))

                ProgressView(value: viewModel.sessionProgress)
                    .tint(Color(red: 0.77, green: 0.92, blue: 0.79))

                Text("\(viewModel.elapsedDuration) sec of \(viewModel.totalSessionDuration) sec")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.68))
            }

            HStack(spacing: 12) {
                Button(viewModel.primaryActionTitle) {
                    YogaHaptics.impact(.medium)
                    viewModel.handlePrimaryAction()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.34, green: 0.61, blue: 0.47))
                .disabled(!viewModel.canStart)

                Button("Skip Pose") {
                    YogaHaptics.selection()
                    viewModel.skipPose()
                }
                .buttonStyle(.bordered)
                .tint(.white)

                Button("Reset") {
                    YogaHaptics.notification(.warning)
                    viewModel.resetSession()
                }
                .buttonStyle(.bordered)
                .tint(.white)
            }

            if let completedLog = viewModel.completedLog {
                Label(
                    "Last session logged at \(completedLog.completedAt.formatted(date: .omitted, time: .shortened))",
                    systemImage: "checkmark.seal.fill"
                )
                .font(.subheadline)
                .foregroundStyle(Color(red: 0.82, green: 0.94, blue: 0.82))
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.26))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var streakCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Consistency")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)

            Text("Daily logging is automatic when you finish a session. Keep the chain alive to raise your streak and unlock milestones.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.78))

            HStack(spacing: 10) {
                ForEach(viewModel.progressStore.recentActivity) { day in
                    VStack(spacing: 8) {
                        Circle()
                            .fill(day.isCompleted ? Color(red: 0.78, green: 0.93, blue: 0.78) : Color.white.opacity(0.12))
                            .frame(width: 14, height: 14)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(day.isCompleted ? 0.0 : 0.18), lineWidth: 1)
                            )

                        Text(day.day.formatted(.dateTime.weekday(.narrow)))
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.72))

                        Text("\(day.sessions)")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.22))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var routineCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Pose Sequence")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)

            LazyVGrid(columns: poseColumns, spacing: 12) {
                ForEach(Array(viewModel.poses.enumerated()), id: \.element.id) { index, pose in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(pose.name)
                                .font(.headline)
                                .foregroundStyle(.white)
                            Spacer()
                            Text("\(pose.holdDuration)s")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.72))
                        }

                        Text(pose.focus)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.72))

                        Text(pose.cue)
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.64))
                            .lineLimit(2)
                    }
                    .padding(14)
                    .background(Color.black.opacity(index == viewModel.currentPoseIndex ? 0.34 : 0.20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(index == viewModel.currentPoseIndex ? Color(red: 0.77, green: 0.92, blue: 0.79) : Color.white.opacity(0.10), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.22))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var achievementsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Milestones")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)

            ForEach(viewModel.achievements) { achievement in
                HStack(spacing: 12) {
                    Image(systemName: achievement.systemImage)
                        .font(.title3)
                        .foregroundStyle(achievement.isUnlocked ? Color(red: 0.98, green: 0.90, blue: 0.58) : Color.white.opacity(0.42))
                        .frame(width: 36)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(achievement.title)
                            .font(.headline)
                            .foregroundStyle(.white)

                        Text(achievement.subtitle)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.72))
                    }

                    Spacer()

                    Text(achievement.isUnlocked ? "Unlocked" : "Locked")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(achievement.isUnlocked ? Color(red: 0.78, green: 0.93, blue: 0.78) : Color.white.opacity(0.52))
                }
                .padding(14)
                .background(Color.white.opacity(achievement.isUnlocked ? 0.10 : 0.06))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.22))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func timeLabel(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

private struct YogaPoseFigureView: View {
    let pose: YogaPose
    let isAnimating: Bool

    var body: some View {
        TimelineView(.animation) { context in
            let pulse = isAnimating ? CGFloat(sin(context.date.timeIntervalSinceReferenceDate * 2.1)) : 0

            Canvas { graphicsContext, size in
                let minSide = min(size.width, size.height)
                let lineWidth = minSide * 0.04
                let headRadius = minSide * 0.08
                let upperLimb = minSide * 0.18
                let lowerLimb = minSide * 0.16
                let torsoLength = minSide * 0.22
                let hip = CGPoint(x: size.width * 0.5, y: size.height * 0.68 + pulse * 2)
                let shoulder = point(from: hip, length: torsoLength, angle: pose.figure.torsoAngle)
                let headCenter = point(from: shoulder, length: headRadius * 1.35, angle: -90)

                let leftElbow = point(from: shoulder, length: upperLimb, angle: pose.figure.leftUpperArmAngle)
                let leftHand = point(from: leftElbow, length: lowerLimb, angle: pose.figure.leftLowerArmAngle)
                let rightElbow = point(from: shoulder, length: upperLimb, angle: pose.figure.rightUpperArmAngle)
                let rightHand = point(from: rightElbow, length: lowerLimb, angle: pose.figure.rightLowerArmAngle)
                let leftKnee = point(from: hip, length: upperLimb, angle: pose.figure.leftUpperLegAngle)
                let leftFoot = point(from: leftKnee, length: lowerLimb, angle: pose.figure.leftLowerLegAngle)
                let rightKnee = point(from: hip, length: upperLimb, angle: pose.figure.rightUpperLegAngle)
                let rightFoot = point(from: rightKnee, length: lowerLimb, angle: pose.figure.rightLowerLegAngle)

                let plateRect = CGRect(x: size.width * 0.08, y: size.height * 0.06, width: size.width * 0.84, height: size.height * 0.88)
                graphicsContext.fill(
                    Path(roundedRect: plateRect, cornerRadius: minSide * 0.1),
                    with: .linearGradient(
                        Gradient(colors: [Color.white.opacity(0.08), Color.clear]),
                        startPoint: CGPoint(x: plateRect.minX, y: plateRect.minY),
                        endPoint: CGPoint(x: plateRect.maxX, y: plateRect.maxY)
                    )
                )

                let glowRect = CGRect(x: hip.x - minSide * 0.24, y: hip.y - minSide * 0.18, width: minSide * 0.48, height: minSide * 0.48)
                graphicsContext.fill(
                    Path(ellipseIn: glowRect),
                    with: .radialGradient(
                        Gradient(colors: [Color(red: 0.82, green: 0.95, blue: 0.84).opacity(0.26), Color.clear]),
                        center: CGPoint(x: glowRect.midX, y: glowRect.midY),
                        startRadius: 4,
                        endRadius: glowRect.width / 2
                    )
                )

                drawSegment(from: shoulder, to: hip, width: lineWidth * 1.2, in: &graphicsContext)
                drawSegment(from: shoulder, to: leftElbow, width: lineWidth, in: &graphicsContext)
                drawSegment(from: leftElbow, to: leftHand, width: lineWidth * 0.9, in: &graphicsContext)
                drawSegment(from: shoulder, to: rightElbow, width: lineWidth, in: &graphicsContext)
                drawSegment(from: rightElbow, to: rightHand, width: lineWidth * 0.9, in: &graphicsContext)
                drawSegment(from: hip, to: leftKnee, width: lineWidth * 1.1, in: &graphicsContext)
                drawSegment(from: leftKnee, to: leftFoot, width: lineWidth, in: &graphicsContext)
                drawSegment(from: hip, to: rightKnee, width: lineWidth * 1.1, in: &graphicsContext)
                drawSegment(from: rightKnee, to: rightFoot, width: lineWidth, in: &graphicsContext)

                for joint in [shoulder, hip, leftElbow, rightElbow, leftKnee, rightKnee] {
                    graphicsContext.fill(Path(ellipseIn: CGRect(x: joint.x - lineWidth * 0.42, y: joint.y - lineWidth * 0.42, width: lineWidth * 0.84, height: lineWidth * 0.84)), with: .color(Color(red: 0.90, green: 0.98, blue: 0.88)))
                }

                graphicsContext.fill(Path(ellipseIn: CGRect(x: headCenter.x - headRadius, y: headCenter.y - headRadius, width: headRadius * 2, height: headRadius * 2)), with: .color(Color(red: 0.96, green: 0.99, blue: 0.93)))
            }
        }
        .background(Color.black.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }

    private func point(from origin: CGPoint, length: CGFloat, angle: Double) -> CGPoint {
        let radians = angle * .pi / 180
        return CGPoint(
            x: origin.x + cos(radians) * length,
            y: origin.y + sin(radians) * length
        )
    }

    private func drawSegment(from start: CGPoint, to end: CGPoint, width: CGFloat, in context: inout GraphicsContext) {
        var path = Path()
        path.move(to: start)
        path.addLine(to: end)
        context.stroke(path, with: .color(Color(red: 0.92, green: 0.99, blue: 0.90)), style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
    }
}

private enum YogaHaptics {
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
}

#Preview {
    YogaView(viewModel: YogaViewModel(progressStore: YogaProgressStore()))
}