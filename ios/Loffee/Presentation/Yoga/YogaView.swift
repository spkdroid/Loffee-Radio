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
                        goalGuideCard
                        styleLibraryCard
                        routineLibraryCard
                        guidanceCard
                        sessionStageCard
                        streakCard
                        routineCard
                        recentSessionsCard
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
                    Text("Yoga Styles")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)

                    Text("Choose a practice based on your goal, run a guided session, and let the app log your streak automatically.")
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
                statChip(title: "Styles", value: "\(viewModel.completedStyleCount)")
            }

            Text(viewModel.selectedStyleHeadline)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color(red: 0.88, green: 0.94, blue: 0.86))

            Text(viewModel.routineHeadline)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color(red: 0.95, green: 0.91, blue: 0.74))

            Text(viewModel.streakHeadline)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.72))
        }
        .padding(20)
        .background(Color.black.opacity(0.24))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var routineLibraryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Routine Levels")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)

            Text("Each style now includes curated beginner, intermediate, and advanced variants.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.76))

            ForEach(viewModel.selectedStyle.routines) { routine in
                Button {
                    YogaHaptics.selection()
                    viewModel.selectRoutine(routine)
                } label: {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(routine.title)
                                .font(.headline)
                                .foregroundStyle(.white)
                            Text("\(routine.level.title) • \(routine.estimatedMinutes) min")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color(red: 0.95, green: 0.91, blue: 0.74))
                            Text(routine.summary)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.72))
                        }

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color.black.opacity(viewModel.selectedRoutineID == routine.id ? 0.34 : 0.18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(viewModel.selectedRoutineID == routine.id ? Color(red: 0.77, green: 0.92, blue: 0.79) : Color.white.opacity(0.10), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)
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

    private var guidanceCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Guidance")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)

            Toggle("Voice guidance", isOn: $viewModel.voiceGuidanceEnabled)
                .tint(Color(red: 0.34, green: 0.61, blue: 0.47))
                .foregroundStyle(.white)

            Toggle("Transition cue audio", isOn: $viewModel.transitionCueEnabled)
                .tint(Color(red: 0.34, green: 0.61, blue: 0.47))
                .foregroundStyle(.white)

            Text(viewModel.latestGuidanceText)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.72))
        }
        .padding(20)
        .background(Color.black.opacity(0.22))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var goalGuideCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Goal Guide")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)

            Text("Style selection now follows the wellness goals you specified.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.76))

            ForEach(viewModel.goalGuide) { item in
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.goal)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(item.styles)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color(red: 0.95, green: 0.91, blue: 0.74))
                    Text(item.rationale)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.72))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(Color.white.opacity(0.06))
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

    private var styleLibraryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Practice Library")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)

            Text("Each style card includes a short researched summary so the user can choose the right session intentionally.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.76))

            LazyVGrid(columns: poseColumns, spacing: 12) {
                ForEach(viewModel.styles) { style in
                    Button {
                        YogaHaptics.selection()
                        viewModel.selectStyle(style)
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(style.name)
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                    Text(style.bestFor)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(Color(red: 0.95, green: 0.91, blue: 0.74))
                                }
                                Spacer()
                                Text(style.intensity)
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.white.opacity(0.75))
                            }

                            Text(style.researchSummary)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.74))
                                .lineLimit(4)

                            Text(style.practiceFeel)
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.58))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .background(Color.black.opacity(viewModel.selectedStyleID == style.id ? 0.34 : 0.18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(viewModel.selectedStyleID == style.id ? Color(red: 0.77, green: 0.92, blue: 0.79) : Color.white.opacity(0.10), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)
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
                    Text(viewModel.selectedStyle.name)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)

                    Text(viewModel.currentPose.name + " • " + viewModel.currentPose.focus)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.72))
                }

                Spacer()

                Text(timeLabel(viewModel.secondsRemaining))
                    .font(.title2.monospacedDigit().weight(.bold))
                    .foregroundStyle(Color(red: 0.94, green: 0.96, blue: 0.78))
            }

            YogaPoseFigureView(
                pose: viewModel.currentPose,
                style: viewModel.selectedStyle,
                level: viewModel.selectedRoutine.level,
                isAnimating: viewModel.isRunning
            )
                .frame(height: horizontalSizeClass == .regular ? 340 : 280)

            VStack(alignment: .leading, spacing: 10) {
                Text(viewModel.selectedStyle.researchSummary)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.72))

                Text(viewModel.currentPose.cue)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.84))

                Text(viewModel.selectedStyle.breathCue)
                    .font(.caption)
                    .foregroundStyle(Color(red: 0.82, green: 0.93, blue: 0.83))

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
                    "\(completedLog.styleName ?? viewModel.selectedStyle.name) logged at \(completedLog.completedAt.formatted(date: .omitted, time: .shortened))",
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
            Text("Selected Sequence")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)

            Text(viewModel.selectedRoutine.summary)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.74))

            LazyVGrid(columns: poseColumns, spacing: 12) {
                ForEach(Array(viewModel.steps.enumerated()), id: \.element.id) { index, step in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(step.pose.name)
                                .font(.headline)
                                .foregroundStyle(.white)
                            Spacer()
                            Text("\(step.holdDuration)s")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.72))
                        }

                        Text(step.pose.focus)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.72))

                        Text(step.spokenPrompt ?? step.pose.cue)
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.64))
                            .lineLimit(2)
                    }
                    .padding(14)
                    .background(Color.black.opacity(index == viewModel.currentStepIndex ? 0.34 : 0.20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(index == viewModel.currentStepIndex ? Color(red: 0.77, green: 0.92, blue: 0.79) : Color.white.opacity(0.10), lineWidth: 1)
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

    private var recentSessionsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Recent Sessions")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)

            if viewModel.progressStore.recentSessions.isEmpty {
                Text("Finish any style once and the session history will appear here.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.72))
            } else {
                ForEach(viewModel.progressStore.recentSessions) { session in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.routineName ?? session.styleName ?? "Yoga Session")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Text("\((session.routineLevel ?? "").capitalized) \(session.completedAt.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.68))
                        }

                        Spacer()

                        Text("\(Int(session.totalDuration / 60)) min")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color(red: 0.95, green: 0.91, blue: 0.74))
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.06))
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
    let style: YogaStyle
    let level: YogaRoutineLevel
    let isAnimating: Bool

    var body: some View {
        TimelineView(.animation) { context in
            let pulse = isAnimating ? CGFloat(sin(context.date.timeIntervalSinceReferenceDate * 2.1)) : 0
            let breath = isAnimating ? CGFloat(sin(context.date.timeIntervalSinceReferenceDate * 1.35)) : 0
            let palette = YogaIllustrationPalette.palette(for: style.id, level: level)

            Canvas { graphicsContext, size in
                let minSide = min(size.width, size.height)
                let skinStroke = minSide * palette.torsoWidth
                let armStroke = minSide * palette.armWidth
                let legStroke = minSide * palette.legWidth
                let headRadius = minSide * palette.headScale
                let upperLimb = minSide * (0.18 + palette.limbScale)
                let lowerLimb = minSide * (0.16 + palette.limbScale * 0.75)
                let torsoLength = minSide * (0.24 + palette.torsoScale)
                let hip = CGPoint(x: size.width * 0.5, y: size.height * (0.68 + palette.figureYOffset) + pulse * 2)
                let shoulder = point(from: hip, length: torsoLength + breath * 3, angle: pose.figure.torsoAngle)
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
                        Gradient(colors: [palette.cardTint.opacity(0.22), Color.clear]),
                        startPoint: CGPoint(x: plateRect.minX, y: plateRect.minY),
                        endPoint: CGPoint(x: plateRect.maxX, y: plateRect.maxY)
                    )
                )

                let glowRect = CGRect(x: hip.x - minSide * 0.24, y: hip.y - minSide * 0.18, width: minSide * 0.48, height: minSide * 0.48)
                graphicsContext.fill(
                    Path(ellipseIn: glowRect),
                    with: .radialGradient(
                        Gradient(colors: [palette.aura.opacity(0.30), Color.clear]),
                        center: CGPoint(x: glowRect.midX, y: glowRect.midY),
                        startRadius: 4,
                        endRadius: glowRect.width / 2
                    )
                )

                drawLimb(from: shoulder, to: leftElbow, width: armStroke, color: palette.skin, in: &graphicsContext)
                drawLimb(from: leftElbow, to: leftHand, width: armStroke * 0.92, color: palette.skin, in: &graphicsContext)
                drawLimb(from: shoulder, to: rightElbow, width: armStroke, color: palette.skin, in: &graphicsContext)
                drawLimb(from: rightElbow, to: rightHand, width: armStroke * 0.92, color: palette.skin, in: &graphicsContext)
                drawLimb(from: hip, to: leftKnee, width: legStroke, color: palette.skin, in: &graphicsContext)
                drawLimb(from: leftKnee, to: leftFoot, width: legStroke * 0.96, color: palette.skin, in: &graphicsContext)
                drawLimb(from: hip, to: rightKnee, width: legStroke, color: palette.skin, in: &graphicsContext)
                drawLimb(from: rightKnee, to: rightFoot, width: legStroke * 0.96, color: palette.skin, in: &graphicsContext)
                drawLimb(from: shoulder, to: hip, width: skinStroke, color: palette.skin, in: &graphicsContext)

                drawLimb(from: shoulder, to: hip, width: skinStroke * 0.78, color: palette.top, in: &graphicsContext)
                drawLimb(from: hip, to: leftKnee, width: legStroke * 0.88, color: palette.bottom, in: &graphicsContext)
                drawLimb(from: hip, to: rightKnee, width: legStroke * 0.88, color: palette.bottom, in: &graphicsContext)

                let shortsOverlay = hipShiftedRect(center: hip, width: minSide * 0.20, height: minSide * 0.11)
                graphicsContext.fill(Path(roundedRect: shortsOverlay, cornerRadius: minSide * 0.03), with: .color(palette.bottom))

                graphicsContext.fill(Path(ellipseIn: CGRect(x: headCenter.x - headRadius, y: headCenter.y - headRadius, width: headRadius * 2, height: headRadius * 2)), with: .color(palette.skin))
                graphicsContext.fill(Path(ellipseIn: CGRect(x: headCenter.x - headRadius * 0.95, y: headCenter.y - headRadius * 1.05, width: headRadius * 1.82, height: headRadius * 1.45)), with: .color(palette.hair))

                switch palette.hairStyle {
                case .ponytail:
                    let ponytailRect = CGRect(x: headCenter.x - headRadius * 1.45, y: headCenter.y + headRadius * 0.1, width: headRadius * 1.0, height: headRadius * 2.1)
                    graphicsContext.fill(Path(roundedRect: ponytailRect, cornerRadius: headRadius * 0.6), with: .color(palette.hair))
                case .bun:
                    graphicsContext.fill(Path(ellipseIn: CGRect(x: headCenter.x - headRadius * 0.2, y: headCenter.y - headRadius * 1.42, width: headRadius * 0.8, height: headRadius * 0.8)), with: .color(palette.hair))
                case .short:
                    break
                }

                graphicsContext.fill(Path(ellipseIn: CGRect(x: leftHand.x - armStroke * 0.20, y: leftHand.y - armStroke * 0.20, width: armStroke * 0.40, height: armStroke * 0.40)), with: .color(palette.skin))
                graphicsContext.fill(Path(ellipseIn: CGRect(x: rightHand.x - armStroke * 0.20, y: rightHand.y - armStroke * 0.20, width: armStroke * 0.40, height: armStroke * 0.40)), with: .color(palette.skin))
                graphicsContext.fill(Path(ellipseIn: CGRect(x: leftFoot.x - legStroke * 0.36, y: leftFoot.y - legStroke * 0.18, width: legStroke * 0.72, height: legStroke * 0.36)), with: .color(palette.top))
                graphicsContext.fill(Path(ellipseIn: CGRect(x: rightFoot.x - legStroke * 0.36, y: rightFoot.y - legStroke * 0.18, width: legStroke * 0.72, height: legStroke * 0.36)), with: .color(palette.top))
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

    private func drawLimb(from start: CGPoint, to end: CGPoint, width: CGFloat, color: Color, in context: inout GraphicsContext) {
        var path = Path()
        path.move(to: start)
        path.addLine(to: end)
        context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
    }

    private func hipShiftedRect(center: CGPoint, width: CGFloat, height: CGFloat) -> CGRect {
        CGRect(x: center.x - width * 0.55, y: center.y - height * 0.36, width: width, height: height)
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

private enum YogaHairStyle {
    case ponytail
    case bun
    case short
}

private struct YogaIllustrationPalette {
    let skin: Color
    let top: Color
    let bottom: Color
    let hair: Color
    let aura: Color
    let cardTint: Color
    let hairStyle: YogaHairStyle
    let torsoScale: CGFloat
    let limbScale: CGFloat
    let torsoWidth: CGFloat
    let armWidth: CGFloat
    let legWidth: CGFloat
    let headScale: CGFloat
    let figureYOffset: CGFloat

    static func palette(for styleID: String, level: YogaRoutineLevel) -> YogaIllustrationPalette {
        let scaleBoost: CGFloat = level == .advanced ? 0.01 : level == .intermediate ? 0.005 : 0

        switch styleID {
        case "restorative":
            return YogaIllustrationPalette(skin: Color(red: 0.96, green: 0.73, blue: 0.60), top: Color(red: 0.90, green: 0.95, blue: 0.88), bottom: Color(red: 0.53, green: 0.67, blue: 0.60), hair: Color(red: 0.22, green: 0.16, blue: 0.12), aura: Color(red: 0.76, green: 0.92, blue: 0.84), cardTint: Color(red: 0.73, green: 0.86, blue: 0.80), hairStyle: .bun, torsoScale: -0.005, limbScale: -0.004, torsoWidth: 0.11, armWidth: 0.082, legWidth: 0.091, headScale: 0.086, figureYOffset: 0.01)
        case "iyengar":
            return YogaIllustrationPalette(skin: Color(red: 0.95, green: 0.68, blue: 0.53), top: Color(red: 0.95, green: 0.93, blue: 0.84), bottom: Color(red: 0.28, green: 0.37, blue: 0.50), hair: Color(red: 0.12, green: 0.11, blue: 0.16), aura: Color(red: 0.73, green: 0.82, blue: 0.97), cardTint: Color(red: 0.63, green: 0.73, blue: 0.90), hairStyle: .short, torsoScale: scaleBoost, limbScale: 0, torsoWidth: 0.116, armWidth: 0.084, legWidth: 0.096, headScale: 0.083, figureYOffset: 0)
        case "vinyasa":
            return YogaIllustrationPalette(skin: Color(red: 0.97, green: 0.67, blue: 0.55), top: Color(red: 0.99, green: 0.86, blue: 0.64), bottom: Color(red: 0.19, green: 0.50, blue: 0.47), hair: Color(red: 0.08, green: 0.10, blue: 0.14), aura: Color(red: 0.99, green: 0.78, blue: 0.52), cardTint: Color(red: 0.87, green: 0.66, blue: 0.46), hairStyle: .ponytail, torsoScale: 0.01 + scaleBoost, limbScale: 0.004, torsoWidth: 0.114, armWidth: 0.086, legWidth: 0.097, headScale: 0.084, figureYOffset: -0.005)
        case "power":
            return YogaIllustrationPalette(skin: Color(red: 0.98, green: 0.64, blue: 0.48), top: Color(red: 0.99, green: 0.79, blue: 0.62), bottom: Color(red: 0.43, green: 0.17, blue: 0.12), hair: Color(red: 0.12, green: 0.08, blue: 0.07), aura: Color(red: 0.99, green: 0.58, blue: 0.46), cardTint: Color(red: 0.94, green: 0.49, blue: 0.37), hairStyle: .bun, torsoScale: 0.018 + scaleBoost, limbScale: 0.008, torsoWidth: 0.12, armWidth: 0.089, legWidth: 0.101, headScale: 0.082, figureYOffset: -0.008)
        case "yin":
            return YogaIllustrationPalette(skin: Color(red: 0.95, green: 0.71, blue: 0.58), top: Color(red: 0.90, green: 0.88, blue: 0.97), bottom: Color(red: 0.41, green: 0.40, blue: 0.60), hair: Color(red: 0.11, green: 0.10, blue: 0.15), aura: Color(red: 0.79, green: 0.76, blue: 0.97), cardTint: Color(red: 0.68, green: 0.63, blue: 0.90), hairStyle: .short, torsoScale: -0.002, limbScale: -0.003, torsoWidth: 0.112, armWidth: 0.082, legWidth: 0.092, headScale: 0.087, figureYOffset: 0.006)
        case "ashtanga":
            return YogaIllustrationPalette(skin: Color(red: 0.97, green: 0.66, blue: 0.53), top: Color(red: 0.90, green: 0.94, blue: 0.98), bottom: Color(red: 0.14, green: 0.22, blue: 0.35), hair: Color(red: 0.07, green: 0.08, blue: 0.10), aura: Color(red: 0.61, green: 0.80, blue: 0.98), cardTint: Color(red: 0.48, green: 0.66, blue: 0.86), hairStyle: .ponytail, torsoScale: 0.015 + scaleBoost, limbScale: 0.006, torsoWidth: 0.118, armWidth: 0.087, legWidth: 0.100, headScale: 0.082, figureYOffset: -0.004)
        case "kundalini":
            return YogaIllustrationPalette(skin: Color(red: 0.96, green: 0.67, blue: 0.55), top: Color(red: 0.96, green: 0.89, blue: 0.70), bottom: Color(red: 0.43, green: 0.26, blue: 0.54), hair: Color(red: 0.13, green: 0.10, blue: 0.15), aura: Color(red: 0.90, green: 0.71, blue: 0.97), cardTint: Color(red: 0.83, green: 0.58, blue: 0.89), hairStyle: .bun, torsoScale: 0.003, limbScale: 0.001, torsoWidth: 0.114, armWidth: 0.084, legWidth: 0.095, headScale: 0.085, figureYOffset: 0)
        default:
            return YogaIllustrationPalette(skin: Color(red: 0.98, green: 0.66, blue: 0.52), top: Color(red: 0.98, green: 0.90, blue: 0.80), bottom: Color(red: 0.25, green: 0.35, blue: 0.14), hair: Color(red: 0.10, green: 0.15, blue: 0.09), aura: Color(red: 0.82, green: 0.95, blue: 0.84), cardTint: Color.white, hairStyle: .ponytail, torsoScale: scaleBoost, limbScale: 0, torsoWidth: 0.115, armWidth: 0.085, legWidth: 0.095, headScale: 0.085, figureYOffset: 0)
        }
    }
}

#Preview {
    YogaView(viewModel: YogaViewModel(progressStore: YogaProgressStore()))
}