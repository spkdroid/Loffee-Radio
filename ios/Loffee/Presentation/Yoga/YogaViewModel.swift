import Foundation

@MainActor
final class YogaViewModel: ObservableObject {
    enum SessionState {
        case idle
        case running
        case paused
        case completed
    }

    struct Achievement: Identifiable {
        let id: String
        let title: String
        let subtitle: String
        let systemImage: String
        let isUnlocked: Bool
    }

    @Published private(set) var poses: [YogaPose]
    @Published private(set) var currentPoseIndex = 0
    @Published private(set) var secondsRemaining: Int
    @Published private(set) var sessionState: SessionState = .idle
    @Published private(set) var completedLog: YogaProgressStore.YogaSessionLog?

    let progressStore: YogaProgressStore

    private var timer: Timer?

    init(progressStore: YogaProgressStore, poses: [YogaPose] = YogaPose.dailyFlow) {
        self.progressStore = progressStore
        self.poses = poses
        self.secondsRemaining = poses.first?.holdDuration ?? 0
    }

    deinit {
        timer?.invalidate()
    }

    var currentPose: YogaPose {
        poses[min(currentPoseIndex, max(poses.count - 1, 0))]
    }

    var isRunning: Bool {
        sessionState == .running
    }

    var canStart: Bool {
        !poses.isEmpty
    }

    var primaryActionTitle: String {
        switch sessionState {
        case .idle:
            return "Start Session"
        case .running:
            return "Pause"
        case .paused:
            return "Resume"
        case .completed:
            return "Start Again"
        }
    }

    var sessionProgress: Double {
        guard totalSessionDuration > 0 else {
            return 0
        }

        return min(max(Double(elapsedDuration) / Double(totalSessionDuration), 0), 1)
    }

    var elapsedDuration: Int {
        let completedPoseDuration = poses.prefix(currentPoseIndex).reduce(0) { $0 + $1.holdDuration }
        let currentElapsed = max(currentPose.holdDuration - secondsRemaining, 0)
        return completedPoseDuration + currentElapsed
    }

    var totalSessionDuration: Int {
        poses.reduce(0) { $0 + $1.holdDuration }
    }

    var energyPoints: Int {
        progressStore.totalSessions * 25 + progressStore.currentStreak * 10 + progressStore.totalMinutes
    }

    var streakHeadline: String {
        if progressStore.currentStreak > 0 {
            return "\(progressStore.currentStreak)-day streak active"
        }

        if progressStore.recoverableStreak > 0 {
            return "Resume today to keep your \(progressStore.recoverableStreak)-day rhythm"
        }

        return "Start today and set the first streak marker"
    }

    var achievements: [Achievement] {
        [
            Achievement(
                id: "first-session",
                title: "First Flow",
                subtitle: "Complete one guided yoga session.",
                systemImage: "sparkles",
                isUnlocked: progressStore.totalSessions >= 1
            ),
            Achievement(
                id: "three-day",
                title: "Rhythm Builder",
                subtitle: "Hold a three day yoga streak.",
                systemImage: "flame.fill",
                isUnlocked: progressStore.longestStreak >= 3
            ),
            Achievement(
                id: "seven-day",
                title: "Week Warrior",
                subtitle: "Practice for seven days in a row.",
                systemImage: "figure.cooldown",
                isUnlocked: progressStore.longestStreak >= 7
            ),
            Achievement(
                id: "ten-sessions",
                title: "Steady Ritual",
                subtitle: "Log ten completed yoga sessions.",
                systemImage: "medal.fill",
                isUnlocked: progressStore.totalSessions >= 10
            )
        ]
    }

    func handlePrimaryAction() {
        switch sessionState {
        case .idle, .completed:
            startSession(reset: true)
        case .running:
            pauseSession()
        case .paused:
            startSession(reset: false)
        }
    }

    func resetSession() {
        timer?.invalidate()
        sessionState = .idle
        currentPoseIndex = 0
        secondsRemaining = poses.first?.holdDuration ?? 0
    }

    func skipPose() {
        guard currentPoseIndex < poses.count - 1 else {
            completeSession()
            return
        }

        currentPoseIndex += 1
        secondsRemaining = currentPose.holdDuration
    }

    private func startSession(reset: Bool) {
        guard canStart else {
            return
        }

        if reset {
            currentPoseIndex = 0
            secondsRemaining = currentPose.holdDuration
        } else if secondsRemaining == 0 {
            secondsRemaining = currentPose.holdDuration
        }

        sessionState = .running
        startTimer()
    }

    private func pauseSession() {
        timer?.invalidate()
        sessionState = .paused
    }

    private func completeSession() {
        timer?.invalidate()
        sessionState = .completed
        secondsRemaining = 0
        completedLog = progressStore.recordSession(
            poseIDs: poses.map(\.id),
            totalDuration: TimeInterval(totalSessionDuration)
        )
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    private func tick() {
        guard sessionState == .running else {
            return
        }

        if secondsRemaining > 0 {
            secondsRemaining -= 1
        }

        if secondsRemaining == 0 {
            if currentPoseIndex < poses.count - 1 {
                currentPoseIndex += 1
                secondsRemaining = currentPose.holdDuration
            } else {
                completeSession()
            }
        }
    }
}