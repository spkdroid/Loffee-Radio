import Foundation

@MainActor
final class YogaProgressStore: ObservableObject {
    struct YogaSessionLog: Identifiable, Codable, Equatable {
        let id: UUID
        let completedAt: Date
        let styleID: String?
        let styleName: String?
        let poseIDs: [String]
        let totalDuration: TimeInterval
    }

    struct YogaActivityDay: Identifiable, Equatable {
        let day: Date
        let sessions: Int

        var id: Date { day }
        var isCompleted: Bool { sessions > 0 }
    }

    @Published private(set) var sessionLogs: [YogaSessionLog] = []

    private let userDefaults: UserDefaults
    private let storageKey = "com.loffee.yoga-progress"
    private let calendar = Calendar.autoupdatingCurrent

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        load()
    }

    var totalSessions: Int {
        sessionLogs.count
    }

    var totalMinutes: Int {
        Int(sessionLogs.reduce(0) { $0 + $1.totalDuration } / 60)
    }

    var sessionsToday: Int {
        sessions(on: Date())
    }

    var currentStreak: Int {
        streak(endingOn: Date(), allowTodayMiss: false)
    }

    var recoverableStreak: Int {
        guard currentStreak == 0 else {
            return currentStreak
        }

        return streak(endingOn: Date(), allowTodayMiss: true)
    }

    var longestStreak: Int {
        let days = completedDaysSortedAscending
        guard var previousDay = days.first else {
            return 0
        }

        var longest = 1
        var running = 1

        for day in days.dropFirst() {
            if let difference = calendar.dateComponents([.day], from: previousDay, to: day).day, difference == 1 {
                running += 1
            } else if !calendar.isDate(previousDay, inSameDayAs: day) {
                running = 1
            }

            longest = max(longest, running)
            previousDay = day
        }

        return longest
    }

    var recentActivity: [YogaActivityDay] {
        let today = calendar.startOfDay(for: Date())
        return (0..<7).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -6 + offset, to: today) else {
                return nil
            }

            return YogaActivityDay(day: day, sessions: sessions(on: day))
        }
    }

    var recentSessions: [YogaSessionLog] {
        Array(sessionLogs.prefix(5))
    }

    func recordSession(
        styleID: String,
        styleName: String,
        poseIDs: [String],
        totalDuration: TimeInterval,
        completedAt: Date = Date()
    ) -> YogaSessionLog {
        let log = YogaSessionLog(
            id: UUID(),
            completedAt: completedAt,
            styleID: styleID,
            styleName: styleName,
            poseIDs: poseIDs,
            totalDuration: totalDuration
        )

        sessionLogs.insert(log, at: 0)
        sessionLogs.sort { $0.completedAt > $1.completedAt }
        persist()

        return log
    }

    private var completedDaysSortedAscending: [Date] {
        Array(Set(sessionLogs.map { calendar.startOfDay(for: $0.completedAt) })).sorted()
    }

    private func streak(endingOn referenceDate: Date, allowTodayMiss: Bool) -> Int {
        var currentDay = calendar.startOfDay(for: referenceDate)
        let completedDays = Set(sessionLogs.map { calendar.startOfDay(for: $0.completedAt) })

        if allowTodayMiss && !completedDays.contains(currentDay) {
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDay) else {
                return 0
            }
            currentDay = previousDay
        }

        guard completedDays.contains(currentDay) else {
            return 0
        }

        var streakCount = 0
        while completedDays.contains(currentDay) {
            streakCount += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDay) else {
                break
            }
            currentDay = previousDay
        }

        return streakCount
    }

    private func sessions(on date: Date) -> Int {
        sessionLogs.filter { calendar.isDate($0.completedAt, inSameDayAs: date) }.count
    }

    private func load() {
        guard let data = userDefaults.data(forKey: storageKey) else {
            sessionLogs = []
            return
        }

        do {
            sessionLogs = try JSONDecoder().decode([YogaSessionLog].self, from: data)
                .sorted { $0.completedAt > $1.completedAt }
        } catch {
            sessionLogs = []
        }
    }

    private func persist() {
        do {
            let data = try JSONEncoder().encode(sessionLogs)
            userDefaults.set(data, forKey: storageKey)
        } catch {
            userDefaults.removeObject(forKey: storageKey)
        }
    }
}