import Foundation

@MainActor
final class MixStore: ObservableObject {
    @Published private(set) var mixes: [Mix] = []
    private let userDefaults: UserDefaults
    private let storageKey = "com.loffee.saved-mixes"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        loadPersistedMixes()
    }

    func saveMix(name: String, sounds: [Sound]) {
        let selectedSounds = sounds.filter(\.isSelected)
        guard !selectedSounds.isEmpty else {
            return
        }

        let mixName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = mixName.isEmpty ? defaultMixName() : mixName

        let mix = Mix(
            name: finalName,
            createdAt: Date(),
            updatedAt: Date(),
            items: selectedSounds.map { sound in
                MixItem(soundID: sound.id, volume: sound.volume)
            }
        )

        mixes.insert(mix, at: 0)
        persist()
    }

    func deleteMix(id: UUID) {
        mixes.removeAll { $0.id == id }
        persist()
    }

    func renameMix(id: UUID, name: String) {
        guard let index = mixes.firstIndex(where: { $0.id == id }) else {
            return
        }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            return
        }

        mixes[index].name = trimmedName
        mixes[index].updatedAt = Date()
        persist()
    }

    func duplicateMix(id: UUID) {
        guard let sourceMix = mixes.first(where: { $0.id == id }) else {
            return
        }

        let duplicate = Mix(
            name: duplicateName(for: sourceMix.name),
            createdAt: Date(),
            updatedAt: Date(),
            items: sourceMix.items
        )

        mixes.insert(duplicate, at: 0)
        persist()
    }

    private func loadPersistedMixes() {
        guard let data = userDefaults.data(forKey: storageKey) else {
            mixes = []
            return
        }

        do {
            mixes = try JSONDecoder().decode([Mix].self, from: data)
        } catch {
            mixes = []
        }
    }

    private func persist() {
        do {
            let data = try JSONEncoder().encode(mixes)
            userDefaults.set(data, forKey: storageKey)
        } catch {
            userDefaults.removeObject(forKey: storageKey)
        }
    }

    private func defaultMixName() -> String {
        "Mix \(mixes.count + 1)"
    }

    private func duplicateName(for name: String) -> String {
        let baseName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let candidate = baseName.isEmpty ? defaultMixName() : "\(baseName) Copy"

        guard mixes.contains(where: { $0.name.caseInsensitiveCompare(candidate) == .orderedSame }) else {
            return candidate
        }

        var suffix = 2
        var numberedCandidate = "\(candidate) \(suffix)"

        while mixes.contains(where: { $0.name.caseInsensitiveCompare(numberedCandidate) == .orderedSame }) {
            suffix += 1
            numberedCandidate = "\(candidate) \(suffix)"
        }

        return numberedCandidate
    }
}