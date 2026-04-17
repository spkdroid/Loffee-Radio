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

    @Published private(set) var styles: [YogaStyle]
    @Published private(set) var selectedStyleID: String
    @Published private(set) var selectedRoutineID: String
    @Published private(set) var currentStepIndex = 0
    @Published private(set) var secondsRemaining: Int
    @Published private(set) var sessionState: SessionState = .idle
    @Published private(set) var completedLog: YogaProgressStore.YogaSessionLog?
    @Published var voiceGuidanceEnabled = true
    @Published var transitionCueEnabled = true
    @Published private(set) var latestGuidanceText = "Voice guidance ready."

    let progressStore: YogaProgressStore

    private var timer: Timer?
    private let guidanceService = YogaGuidanceService()

    init(progressStore: YogaProgressStore, styles: [YogaStyle] = YogaStyle.catalog) {
        self.progressStore = progressStore
        self.styles = styles
        self.selectedStyleID = styles.first?.id ?? ""
        self.selectedRoutineID = styles.first?.defaultRoutine.id ?? ""
        self.secondsRemaining = styles.first?.defaultRoutine.steps.first?.holdDuration ?? 0
    }

    deinit {
        timer?.invalidate()
    }

    var selectedStyle: YogaStyle {
        styles.first(where: { $0.id == selectedStyleID }) ?? styles[0]
    }

    var selectedRoutine: YogaRoutine {
        selectedStyle.routines.first(where: { $0.id == selectedRoutineID }) ?? selectedStyle.defaultRoutine
    }

    var steps: [YogaRoutineStep] {
        selectedRoutine.steps
    }

    var poses: [YogaPose] {
        steps.map(\.pose)
    }

    var currentStep: YogaRoutineStep {
        steps[min(currentStepIndex, max(steps.count - 1, 0))]
    }

    var currentPose: YogaPose {
        currentStep.pose
    }

    var goalGuide: [YogaGoalGuide] {
        YogaGoalGuide.recommendations
    }

    var isRunning: Bool {
        sessionState == .running
    }

    var canStart: Bool {
        !steps.isEmpty
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
        let completedStepDuration = steps.prefix(currentStepIndex).reduce(0) { $0 + $1.holdDuration }
        let currentElapsed = max(currentStep.holdDuration - secondsRemaining, 0)
        return completedStepDuration + currentElapsed
    }

    var totalSessionDuration: Int {
        steps.reduce(0) { $0 + $1.holdDuration }
    }

    var energyPoints: Int {
        progressStore.totalSessions * 25 + progressStore.currentStreak * 10 + progressStore.totalMinutes
    }

    var completedStyleCount: Int {
        Set(progressStore.sessionLogs.compactMap(\.styleID)).count
    }

    var advancedCompletionCount: Int {
        progressStore.sessionLogs.filter { $0.routineLevel == YogaRoutineLevel.advanced.rawValue }.count
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

    var selectedStyleHeadline: String {
        "\(selectedRoutine.level.title) \(selectedStyle.name) is best for \(selectedStyle.bestFor.lowercased())."
    }

    var routineHeadline: String {
        "\(selectedRoutine.title) • \(selectedRoutine.estimatedMinutes) min"
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
            ),
            Achievement(
                id: "style-explorer",
                title: "Style Explorer",
                subtitle: "Complete sessions in three different yoga styles.",
                systemImage: "square.grid.2x2.fill",
                isUnlocked: completedStyleCount >= 3
            ),
            Achievement(
                id: "advanced-finish",
                title: "Advanced Focus",
                subtitle: "Finish any advanced yoga routine.",
                systemImage: "bolt.heart.fill",
                isUnlocked: advancedCompletionCount >= 1
            )
        ]
    }

    func selectStyle(_ style: YogaStyle) {
        guard style.id != selectedStyleID else {
            return
        }

        timer?.invalidate()
        guidanceService.stop()
        selectedStyleID = style.id
        selectedRoutineID = style.defaultRoutine.id
        sessionState = .idle
        currentStepIndex = 0
        secondsRemaining = style.defaultRoutine.steps.first?.holdDuration ?? 0
        completedLog = nil
        latestGuidanceText = "Selected \(style.name)."
    }

    func selectRoutine(_ routine: YogaRoutine) {
        guard routine.id != selectedRoutineID else {
            return
        }

        timer?.invalidate()
        guidanceService.stop()
        selectedRoutineID = routine.id
        sessionState = .idle
        currentStepIndex = 0
        secondsRemaining = routine.steps.first?.holdDuration ?? 0
        completedLog = nil
        latestGuidanceText = "Loaded \(routine.title)."
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
        guidanceService.stop()
        sessionState = .idle
        currentStepIndex = 0
        secondsRemaining = selectedRoutine.steps.first?.holdDuration ?? 0
        latestGuidanceText = "Session reset."
    }

    func skipPose() {
        guard currentStepIndex < steps.count - 1 else {
            completeSession()
            return
        }

        transitionToStep(currentStepIndex + 1, source: "Skipping to")
    }

    private func startSession(reset: Bool) {
        guard canStart else {
            return
        }

        if reset {
            currentStepIndex = 0
            secondsRemaining = currentStep.holdDuration
        } else if secondsRemaining == 0 {
            secondsRemaining = currentStep.holdDuration
        }

        sessionState = .running
        startTimer()
        announceCurrentStep(prefix: reset ? "Starting" : "Resuming")
    }

    private func pauseSession() {
        timer?.invalidate()
        guidanceService.stop()
        sessionState = .paused
        latestGuidanceText = "Session paused."
    }

    private func completeSession() {
        timer?.invalidate()
        if transitionCueEnabled {
            guidanceService.playTransitionCue()
        }
        sessionState = .completed
        secondsRemaining = 0
        completedLog = progressStore.recordSession(
            styleID: selectedStyle.id,
            styleName: selectedStyle.name,
            routineID: selectedRoutine.id,
            routineName: selectedRoutine.title,
            routineLevel: selectedRoutine.level.rawValue,
            poseIDs: steps.map { $0.pose.id },
            totalDuration: TimeInterval(totalSessionDuration)
        )
        latestGuidanceText = "Completed \(selectedRoutine.title)."

        if voiceGuidanceEnabled {
            guidanceService.speak("Session complete. Great work finishing \(selectedRoutine.title).")
        }
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
            if currentStepIndex < steps.count - 1 {
                transitionToStep(currentStepIndex + 1, source: "Next")
            } else {
                completeSession()
            }
        }
    }

    private func transitionToStep(_ index: Int, source: String) {
        currentStepIndex = index
        secondsRemaining = currentStep.holdDuration

        if transitionCueEnabled {
            guidanceService.playTransitionCue()
        }

        announceCurrentStep(prefix: source)
    }

    private func announceCurrentStep(prefix: String) {
        let prompt = currentStep.spokenPrompt ?? currentPose.cue
        latestGuidanceText = "\(prefix) \(currentPose.name). \(prompt)"

        if voiceGuidanceEnabled {
            guidanceService.speak(latestGuidanceText)
        }
    }
}