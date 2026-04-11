import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    enum SleepTimerOption: Int, CaseIterable, Identifiable {
        case off = 0
        case fiveMinutes = 5
        case tenMinutes = 10
        case twentyMinutes = 20
        case thirtyMinutes = 30

        var id: Int { rawValue }

        var title: String {
            switch self {
            case .off:
                return "Sleep timer off"
            case .fiveMinutes:
                return "5 min"
            case .tenMinutes:
                return "10 min"
            case .twentyMinutes:
                return "20 min"
            case .thirtyMinutes:
                return "30 min"
            }
        }
    }

    struct StarterMix: Identifiable {
        let id: String
        let title: String
        let subtitle: String
        let soundIDs: [String]
    }

    @Published private(set) var sounds: [Sound]
    @Published var mixName = ""
    @Published private(set) var isPlaying = false
    @Published private(set) var isPaused = false
    @Published private(set) var sleepTimerOption: SleepTimerOption = .off
    @Published var errorMessage: String?

    private let audioEngineManager: AudioEngineManager
    private let mixStore: MixStore
    private let playbackSessionStore: PlaybackSessionStore
    private var sleepTimer: Timer?

    init(
        audioEngineManager: AudioEngineManager,
        mixStore: MixStore,
        playbackSessionStore: PlaybackSessionStore
    ) {
        self.audioEngineManager = audioEngineManager
        self.mixStore = mixStore
        self.playbackSessionStore = playbackSessionStore
        self.sounds = Self.defaultSounds
        restoreSession()
    }

    var activeSounds: [Sound] {
        sounds.filter(\.isSelected)
    }

    var canSaveMix: Bool {
        !activeSounds.isEmpty
    }

    var hasActiveMix: Bool {
        !activeSounds.isEmpty
    }

    var transportTitle: String {
        if !hasActiveMix {
            return "Ready"
        }

        return isPaused ? "Paused" : "Live Mix"
    }

    var transportSystemImage: String {
        if !hasActiveMix {
            return "waveform"
        }

        return isPaused ? "pause.circle.fill" : "play.circle.fill"
    }

    var starterMixes: [StarterMix] {
        [
            StarterMix(id: "soft-rain", title: "Soft Rain", subtitle: "Rain, piano, wind", soundIDs: ["rain", "piano", "wind"]),
            StarterMix(id: "ocean-drift", title: "Ocean Drift", subtitle: "Ocean, flute, birds", soundIDs: ["ocean", "flute", "birds"]),
            StarterMix(id: "night-lounge", title: "Night Lounge", subtitle: "Lounge, music box, orchestral", soundIDs: ["lounge", "musicbox", "orchestral"])
        ]
    }

    func toggleSound(_ sound: Sound) {
        guard let index = sounds.firstIndex(where: { $0.id == sound.id }) else {
            return
        }

        sounds[index].isSelected.toggle()

        if sounds[index].isSelected {
            do {
                try audioEngineManager.play(sounds[index])
            } catch {
                sounds[index].isSelected = false
                errorMessage = error.localizedDescription
            }
        } else {
            audioEngineManager.stop(sounds[index].id)
        }

        syncPlaybackState()
    }

    func togglePlayback() {
        guard hasActiveMix else {
            return
        }

        if isPaused {
            resumePlayback()
        } else {
            pausePlayback()
        }
    }

    func pausePlayback() {
        guard hasActiveMix else {
            return
        }

        audioEngineManager.pauseAll()
        syncPlaybackState()
    }

    func resumePlayback() {
        guard hasActiveMix else {
            return
        }

        do {
            try audioEngineManager.resumeAll()
        } catch {
            errorMessage = error.localizedDescription
        }

        syncPlaybackState()
    }

    func setVolume(for soundID: String, volume: Float) {
        guard let index = sounds.firstIndex(where: { $0.id == soundID }) else {
            return
        }

        sounds[index].volume = volume
        audioEngineManager.setVolume(for: soundID, volume: volume)
        playbackSessionStore.persist(from: sounds)
    }

    func clearAll() {
        for index in sounds.indices {
            sounds[index].isSelected = false
        }

        audioEngineManager.stopAll()
        playbackSessionStore.clear()
        cancelSleepTimer()
        syncPlaybackState()
    }

    func saveMix() {
        mixStore.saveMix(name: mixName, sounds: sounds)
        mixName = ""
    }

    func load(_ mix: Mix) {
        clearAll()

        for item in mix.items {
            guard let index = sounds.firstIndex(where: { $0.id == item.soundID }) else {
                continue
            }

            sounds[index].isSelected = true
            sounds[index].volume = item.volume

            do {
                try audioEngineManager.play(sounds[index])
                audioEngineManager.setVolume(for: item.soundID, volume: item.volume)
            } catch {
                sounds[index].isSelected = false
                errorMessage = error.localizedDescription
            }
        }

        mixName = mix.name
        syncPlaybackState()
    }

    func dismissError() {
        errorMessage = nil
    }

    func applyStarterMix(_ starterMix: StarterMix) {
        clearAll()

        for soundID in starterMix.soundIDs {
            guard let index = sounds.firstIndex(where: { $0.id == soundID }) else {
                continue
            }

            sounds[index].isSelected = true

            do {
                try audioEngineManager.play(sounds[index])
            } catch {
                sounds[index].isSelected = false
                errorMessage = error.localizedDescription
            }
        }

        mixName = starterMix.title
        syncPlaybackState()
    }

    func setSleepTimer(_ option: SleepTimerOption) {
        cancelSleepTimer()
        sleepTimerOption = option

        guard option != .off else {
            return
        }

        sleepTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(option.rawValue * 60), repeats: false) { [weak self] _ in
            Task { @MainActor in
                guard let self else {
                    return
                }

                self.clearAll()
                self.sleepTimerOption = .off
            }
        }
    }

    private func syncPlaybackState() {
        isPlaying = audioEngineManager.hasActiveNodes
        isPaused = audioEngineManager.isPaused

        if activeSounds.isEmpty {
            playbackSessionStore.clear()
        } else {
            playbackSessionStore.persist(from: sounds)
        }
    }

    private func restoreSession() {
        let persistedVolumes = playbackSessionStore.restore()
        guard !persistedVolumes.isEmpty else {
            return
        }

        for index in sounds.indices {
            guard let volume = persistedVolumes[sounds[index].id] else {
                continue
            }

            sounds[index].isSelected = true
            sounds[index].volume = volume

            do {
                try audioEngineManager.play(sounds[index])
            } catch {
                sounds[index].isSelected = false
                errorMessage = error.localizedDescription
            }
        }

        syncPlaybackState()
    }

    private func cancelSleepTimer() {
        sleepTimer?.invalidate()
        sleepTimer = nil
        sleepTimerOption = .off
    }

    private static let defaultSounds: [Sound] = [
        Sound(id: "birds", name: "Birds", audioBaseName: "birds", category: "Nature", normalArtworkName: "sound_birds_normal", selectedArtworkName: "sound_birds_selected"),
        Sound(id: "flute", name: "Flute", audioBaseName: "flute", category: "Melody", normalArtworkName: "sound_flute_normal", selectedArtworkName: "sound_flute_selected"),
        Sound(id: "lounge", name: "Lounge", audioBaseName: "lounge", category: "Atmosphere", normalArtworkName: "sound_lounge_normal", selectedArtworkName: "sound_lounge_selected"),
        Sound(id: "musicbox", name: "Music Box", audioBaseName: "musicbox", category: "Melody", normalArtworkName: "sound_musicbox_normal", selectedArtworkName: "sound_musicbox_selected"),
        Sound(id: "ocean", name: "Ocean", audioBaseName: "ocean", category: "Nature", normalArtworkName: "sound_ocean_normal", selectedArtworkName: "sound_ocean_selected"),
        Sound(id: "orchestral", name: "Orchestral", audioBaseName: "orchestral", category: "Melody", normalArtworkName: "sound_orchestral_normal", selectedArtworkName: "sound_orchestral_selected"),
        Sound(id: "piano", name: "Piano", audioBaseName: "piano", category: "Melody", normalArtworkName: "sound_piano_normal", selectedArtworkName: "sound_piano_selected"),
        Sound(id: "rain", name: "Rain", audioBaseName: "rain", category: "Weather", normalArtworkName: "sound_rain_normal", selectedArtworkName: "sound_rain_selected"),
        Sound(id: "wind", name: "Wind", audioBaseName: "wind", category: "Weather", normalArtworkName: "sound_wind_normal", selectedArtworkName: "sound_wind_selected")
    ]
}