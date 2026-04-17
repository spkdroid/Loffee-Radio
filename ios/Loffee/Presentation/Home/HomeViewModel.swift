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
        configureRemoteControls()
        restoreSession()
        validateBundledAudioAssets()
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

    var miniPlayerTitle: String {
        if let customMixName = trimmedMixName, !customMixName.isEmpty {
            return customMixName
        }

        guard let firstSound = activeSounds.first else {
            return "Build a calm scene"
        }

        if activeSounds.count == 1 {
            return firstSound.name
        }

        return "\(firstSound.name) + \(activeSounds.count - 1) more"
    }

    var miniPlayerSubtitle: String {
        if activeSounds.isEmpty {
            return "Tap a sound tile or start from a preset mix"
        }

        let soundSummary = "\(activeSounds.count) sound\(activeSounds.count == 1 ? "" : "s") active"

        guard sleepTimerOption != .off else {
            return soundSummary
        }

        return "\(soundSummary) • Sleep timer: \(sleepTimerOption.title)"
    }

    var activeArtworkName: String {
        activeSounds.first?.selectedArtworkName ?? "bg_main"
    }

    var starterMixes: [StarterMix] {
        [
            StarterMix(id: "soft-rain", title: "Soft Rain", subtitle: "Rain, piano, wind", soundIDs: ["rain", "piano", "wind"]),
            StarterMix(id: "ocean-drift", title: "Ocean Drift", subtitle: "Ocean, flute, birds", soundIDs: ["ocean", "flute", "birds"]),
            StarterMix(id: "night-lounge", title: "Night Lounge", subtitle: "Lounge, music box, orchestral", soundIDs: ["lounge", "musicbox", "orchestral"]),
            StarterMix(id: "forest-canopy", title: "Forest Canopy", subtitle: "Birds Canopy, Wind Hollow, Rain Shelter", soundIDs: ["birds_canopy", "wind_hollow", "rain_shelter"]),
            StarterMix(id: "velvet-tide", title: "Velvet Tide", subtitle: "Ocean Glow, Orchestral Velvet, Lounge Hush", soundIDs: ["ocean_glow", "orchestral_velvet", "lounge_hush"]),
            StarterMix(id: "misty-focus", title: "Misty Focus", subtitle: "Piano Mist, Flute Dusk, Music Box Starlight", soundIDs: ["piano_mist", "flute_dusk", "musicbox_starlight"])
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
        persistPlaybackSession()
    }

    func clearAll() {
        for index in sounds.indices {
            sounds[index].isSelected = false
        }

        audioEngineManager.stopAll()
        playbackSessionStore.clear()
        cancelSleepTimer()
        mixName = ""
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
            audioEngineManager.clearNowPlayingInfo()
        } else {
            persistPlaybackSession()
            audioEngineManager.updateNowPlayingInfo(
                title: miniPlayerTitle,
                subtitle: miniPlayerSubtitle,
                isPlaying: isPlaying && !isPaused,
                artworkName: activeArtworkName
            )
        }
    }

    private var trimmedMixName: String? {
        let value = mixName.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }

    private func configureRemoteControls() {
        audioEngineManager.onRemotePlayRequested = { [weak self] in
            Task { @MainActor in
                self?.resumePlayback()
            }
        }

        audioEngineManager.onRemotePauseRequested = { [weak self] in
            Task { @MainActor in
                self?.pausePlayback()
            }
        }

        audioEngineManager.onRemoteToggleRequested = { [weak self] in
            Task { @MainActor in
                self?.togglePlayback()
            }
        }

        audioEngineManager.onRemoteStopRequested = { [weak self] in
            Task { @MainActor in
                self?.clearAll()
            }
        }
    }

    private func restoreSession() {
        guard let restoredSession = playbackSessionStore.restore(), !restoredSession.snapshots.isEmpty else {
            return
        }

        let persistedVolumes = Dictionary(
            uniqueKeysWithValues: restoredSession.snapshots.map { ($0.soundID, $0.volume) }
        )

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

        if !restoredSession.mixName.isEmpty {
            mixName = restoredSession.mixName
        }

        if restoredSession.isPaused {
            audioEngineManager.pauseAll()
        }

        syncPlaybackState()
    }

    private func persistPlaybackSession() {
        playbackSessionStore.persist(from: sounds, mixName: mixName, isPaused: audioEngineManager.isPaused)
    }

    private func validateBundledAudioAssets() {
        let missingPreferredAssets = audioEngineManager.missingPreferredAssets(for: sounds.map(\.audioBaseName))
        guard !missingPreferredAssets.isEmpty else {
            return
        }

        errorMessage = "Native iOS audio files are still missing for: \(missingPreferredAssets.sorted().joined(separator: ", ")). Playback may work with bundled .ogg files, but reliable release builds should add .m4a, .caf, or .wav versions with the same base names."
    }

    private func cancelSleepTimer() {
        sleepTimer?.invalidate()
        sleepTimer = nil
        sleepTimerOption = .off
    }

    private static let defaultSounds: [Sound] = [
        Sound(id: "birds", name: "Birds", audioBaseName: "birds", category: "Nature", normalArtworkName: "sound_birds_normal", selectedArtworkName: "sound_birds_selected"),
        Sound(id: "birds_canopy", name: "Birds Canopy", audioBaseName: "birds_canopy", category: "Nature", normalArtworkName: "sound_birds_canopy_normal", selectedArtworkName: "sound_birds_canopy_selected"),
        Sound(id: "flute", name: "Flute", audioBaseName: "flute", category: "Melody", normalArtworkName: "sound_flute_normal", selectedArtworkName: "sound_flute_selected"),
        Sound(id: "flute_dusk", name: "Flute Dusk", audioBaseName: "flute_dusk", category: "Melody", normalArtworkName: "sound_flute_dusk_normal", selectedArtworkName: "sound_flute_dusk_selected"),
        Sound(id: "lounge", name: "Lounge", audioBaseName: "lounge", category: "Atmosphere", normalArtworkName: "sound_lounge_normal", selectedArtworkName: "sound_lounge_selected"),
        Sound(id: "lounge_hush", name: "Lounge Hush", audioBaseName: "lounge_hush", category: "Atmosphere", normalArtworkName: "sound_lounge_hush_normal", selectedArtworkName: "sound_lounge_hush_selected"),
        Sound(id: "musicbox", name: "Music Box", audioBaseName: "musicbox", category: "Melody", normalArtworkName: "sound_musicbox_normal", selectedArtworkName: "sound_musicbox_selected"),
        Sound(id: "musicbox_starlight", name: "Music Box Starlight", audioBaseName: "musicbox_starlight", category: "Melody", normalArtworkName: "sound_musicbox_starlight_normal", selectedArtworkName: "sound_musicbox_starlight_selected"),
        Sound(id: "ocean", name: "Ocean", audioBaseName: "ocean", category: "Nature", normalArtworkName: "sound_ocean_normal", selectedArtworkName: "sound_ocean_selected"),
        Sound(id: "ocean_glow", name: "Ocean Glow", audioBaseName: "ocean_glow", category: "Nature", normalArtworkName: "sound_ocean_glow_normal", selectedArtworkName: "sound_ocean_glow_selected"),
        Sound(id: "orchestral", name: "Orchestral", audioBaseName: "orchestral", category: "Melody", normalArtworkName: "sound_orchestral_normal", selectedArtworkName: "sound_orchestral_selected"),
        Sound(id: "orchestral_velvet", name: "Orchestral Velvet", audioBaseName: "orchestral_velvet", category: "Melody", normalArtworkName: "sound_orchestral_velvet_normal", selectedArtworkName: "sound_orchestral_velvet_selected"),
        Sound(id: "piano", name: "Piano", audioBaseName: "piano", category: "Melody", normalArtworkName: "sound_piano_normal", selectedArtworkName: "sound_piano_selected"),
        Sound(id: "piano_mist", name: "Piano Mist", audioBaseName: "piano_mist", category: "Melody", normalArtworkName: "sound_piano_mist_normal", selectedArtworkName: "sound_piano_mist_selected"),
        Sound(id: "rain", name: "Rain", audioBaseName: "rain", category: "Weather", normalArtworkName: "sound_rain_normal", selectedArtworkName: "sound_rain_selected"),
        Sound(id: "rain_shelter", name: "Rain Shelter", audioBaseName: "rain_shelter", category: "Weather", normalArtworkName: "sound_rain_shelter_normal", selectedArtworkName: "sound_rain_shelter_selected"),
        Sound(id: "wind", name: "Wind", audioBaseName: "wind", category: "Weather", normalArtworkName: "sound_wind_normal", selectedArtworkName: "sound_wind_selected"),
        Sound(id: "wind_hollow", name: "Wind Hollow", audioBaseName: "wind_hollow", category: "Weather", normalArtworkName: "sound_wind_hollow_normal", selectedArtworkName: "sound_wind_hollow_selected")
    ]
}