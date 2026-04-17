import Foundation

final class PlaybackSessionStore {
    struct PlaybackSession: Codable {
        let mixName: String
        let isPaused: Bool
        let snapshots: [PlaybackSnapshot]
    }

    struct PlaybackSnapshot: Codable {
        let soundID: String
        let volume: Float
    }

    private let userDefaults: UserDefaults
    private let sessionKey = "com.loffee.playback-session"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func restore() -> PlaybackSession? {
        guard let data = userDefaults.data(forKey: sessionKey) else {
            return nil
        }

        do {
            return try JSONDecoder().decode(PlaybackSession.self, from: data)
        } catch {
            guard let snapshots = try? JSONDecoder().decode([PlaybackSnapshot].self, from: data) else {
                return nil
            }

            return PlaybackSession(mixName: "", isPaused: false, snapshots: snapshots)
        }
    }

    func persist(from sounds: [Sound], mixName: String, isPaused: Bool) {
        let snapshots = sounds
            .filter(\.isSelected)
            .map { PlaybackSnapshot(soundID: $0.id, volume: $0.volume) }

        let session = PlaybackSession(
            mixName: mixName.trimmingCharacters(in: .whitespacesAndNewlines),
            isPaused: isPaused,
            snapshots: snapshots
        )

        do {
            let data = try JSONEncoder().encode(session)
            userDefaults.set(data, forKey: sessionKey)
        } catch {
            userDefaults.removeObject(forKey: sessionKey)
        }
    }

    func clear() {
        userDefaults.removeObject(forKey: sessionKey)
    }
}