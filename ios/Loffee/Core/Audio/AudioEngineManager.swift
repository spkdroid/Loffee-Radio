import AVFoundation
import Foundation

enum AudioEngineError: LocalizedError {
    case missingResource(String)
    case unsupportedResource(String)
    case bufferCreationFailed(String)
    case engineStartFailed(String)

    var errorDescription: String? {
        switch self {
        case let .missingResource(baseName):
            return "Audio asset '\(baseName)' was not found in the app bundle. Add an iOS-supported file such as .m4a, .caf, .wav, .aif, or .mp3 to Resources/Audio."
        case let .unsupportedResource(baseName):
            return "Audio asset '\(baseName)' could not be decoded by AVAudioEngine. The imported Android .ogg files are bundled for reference, but iOS playback is most reliable with .m4a, .caf, or .wav."
        case let .bufferCreationFailed(baseName):
            return "Audio buffer creation failed for '\(baseName)'."
        case let .engineStartFailed(message):
            return "Audio engine failed to start: \(message)"
        }
    }
}

final class AudioEngineManager {
    private struct PlaybackNode {
        let player: AVAudioPlayerNode
        let buffer: AVAudioPCMBuffer
    }

    private let engine = AVAudioEngine()
    private var playbackNodes: [String: PlaybackNode] = [:]
    private let supportedExtensions = ["m4a", "caf", "wav", "aif", "mp3", "ogg"]
    private(set) var isPaused = false

    var isPlaying: Bool {
        !playbackNodes.isEmpty && !isPaused
    }

    var hasActiveNodes: Bool {
        !playbackNodes.isEmpty
    }

    init() {
        configureSession()
        observeAudioSession()
        engine.prepare()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func play(_ sound: Sound) throws {
        if isPaused {
            try resumeAll()
        }

        if let playbackNode = playbackNodes[sound.id] {
            playbackNode.player.volume = sound.volume

            if !playbackNode.player.isPlaying {
                try startEngineIfNeeded()
                scheduleLoop(playbackNode.buffer, on: playbackNode.player)
                playbackNode.player.play()
            }

            isPaused = false

            return
        }

        let fileURL = try resolveAudioURL(for: sound.audioBaseName)

        let audioFile: AVAudioFile
        do {
            audioFile = try AVAudioFile(forReading: fileURL)
        } catch {
            throw AudioEngineError.unsupportedResource(sound.audioBaseName)
        }

        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: audioFile.processingFormat,
            frameCapacity: AVAudioFrameCount(audioFile.length)
        ) else {
            throw AudioEngineError.bufferCreationFailed(sound.audioBaseName)
        }

        try audioFile.read(into: buffer)

        let player = AVAudioPlayerNode()
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: buffer.format)

        try startEngineIfNeeded()
        scheduleLoop(buffer, on: player)
        player.volume = sound.volume
        player.play()

        playbackNodes[sound.id] = PlaybackNode(player: player, buffer: buffer)
        isPaused = false
    }

    func stop(_ soundID: String) {
        guard let playbackNode = playbackNodes.removeValue(forKey: soundID) else {
            return
        }

        playbackNode.player.stop()
        engine.detach(playbackNode.player)

        if playbackNodes.isEmpty {
            engine.pause()
            isPaused = false
        }
    }

    func stopAll() {
        let identifiers = Array(playbackNodes.keys)

        for identifier in identifiers {
            stop(identifier)
        }

        isPaused = false
    }

    func pauseAll() {
        guard !playbackNodes.isEmpty else {
            return
        }

        playbackNodes.values.forEach { $0.player.pause() }
        engine.pause()
        isPaused = true
    }

    func resumeAll() throws {
        guard !playbackNodes.isEmpty else {
            return
        }

        try startEngineIfNeeded()
        playbackNodes.values.forEach { playbackNode in
            if !playbackNode.player.isPlaying {
                playbackNode.player.play()
            }
        }
        isPaused = false
    }

    func setVolume(for soundID: String, volume: Float) {
        guard let playbackNode = playbackNodes[soundID] else {
            return
        }

        playbackNode.player.volume = volume
    }

    private func configureSession() {
        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            assertionFailure("Audio session configuration failed: \(error.localizedDescription)")
        }
    }

    private func observeAudioSession() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption(_:)),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange(_:)),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
    }

    @objc private func handleInterruption(_ notification: Notification) {
        guard
            let typeValue = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue)
        else {
            return
        }

        switch type {
        case .began:
            pauseAll()
        case .ended:
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                try resumeAll()
            } catch {
                break
            }
        @unknown default:
            break
        }
    }

    @objc private func handleRouteChange(_ notification: Notification) {
        guard
            let reasonValue = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue)
        else {
            return
        }

        if reason == .oldDeviceUnavailable {
            pauseAll()
        }
    }

    private func resolveAudioURL(for baseName: String) throws -> URL {
        for fileExtension in supportedExtensions {
            if let url = Bundle.main.url(forResource: baseName, withExtension: fileExtension, subdirectory: "Audio") {
                return url
            }

            if let url = Bundle.main.url(forResource: baseName, withExtension: fileExtension) {
                return url
            }
        }

        throw AudioEngineError.missingResource(baseName)
    }

    private func startEngineIfNeeded() throws {
        guard !engine.isRunning else {
            return
        }

        do {
            try engine.start()
        } catch {
            throw AudioEngineError.engineStartFailed(error.localizedDescription)
        }
    }

    private func scheduleLoop(_ buffer: AVAudioPCMBuffer, on player: AVAudioPlayerNode) {
        player.stop()
        player.scheduleBuffer(buffer, at: nil, options: [.loops], completionHandler: nil)
    }
}