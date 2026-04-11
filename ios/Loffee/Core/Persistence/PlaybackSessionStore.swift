import Foundation

final class PlaybackSessionStore {
    private struct PlaybackSnapshot: Codable {
        let soundID: String
        let volume: Float
    }

    private let userDefaults: UserDefaults
    private let sessionKey = "com.loffee.playback-session"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func restore() -> [String: Float] {
        guard let data = userDefaults.data(forKey: sessionKey) else {
            return [:]
        }

        do {
            let snapshots = try JSONDecoder().decode([PlaybackSnapshot].self, from: data)
            return Dictionary(uniqueKeysWithValues: snapshots.map { ($0.soundID, $0.volume) })
        } catch {
            return [:]
        }
    }

    func persist(from sounds: [Sound]) {
        let snapshots = sounds
            .filter(\.isSelected)
            .map { PlaybackSnapshot(soundID: $0.id, volume: $0.volume) }

        do {
            let data = try JSONEncoder().encode(snapshots)
            userDefaults.set(data, forKey: sessionKey)
        } catch {
            userDefaults.removeObject(forKey: sessionKey)
        }
    }

    func clear() {
        userDefaults.removeObject(forKey: sessionKey)
    }
}