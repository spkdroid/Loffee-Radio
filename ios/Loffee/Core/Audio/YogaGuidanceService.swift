import AVFoundation

@MainActor
final class YogaGuidanceService {
    private let synthesizer = AVSpeechSynthesizer()
    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let toneFormat = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)
    private var isToneConfigured = false

    func speak(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return
        }

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: trimmed)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.46
        utterance.pitchMultiplier = 1.02
        utterance.prefersAssistiveTechnologySettings = true
        synthesizer.speak(utterance)
    }

    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        playerNode.stop()
    }

    func playTransitionCue() {
        guard let toneFormat else {
            return
        }

        configureToneEngineIfNeeded(format: toneFormat)
        guard let buffer = makeToneBuffer(format: toneFormat, frequency: 660, duration: 0.18, amplitude: 0.18) else {
            return
        }

        if !audioEngine.isRunning {
            try? audioEngine.start()
        }

        playerNode.stop()
        playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        playerNode.play()
    }

    private func configureToneEngineIfNeeded(format: AVAudioFormat) {
        guard !isToneConfigured else {
            return
        }

        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: format)
        audioEngine.mainMixerNode.outputVolume = 0.3
        try? audioEngine.start()
        isToneConfigured = true
    }

    private func makeToneBuffer(
        format: AVAudioFormat,
        frequency: Double,
        duration: Double,
        amplitude: Float
    ) -> AVAudioPCMBuffer? {
        let frameCount = AVAudioFrameCount(duration * format.sampleRate)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount),
              let channelData = buffer.floatChannelData?[0] else {
            return nil
        }

        buffer.frameLength = frameCount
        let rampFrames = max(1, min(Int(frameCount / 4), 500))

        for index in 0..<Int(frameCount) {
            let phase = 2.0 * Double.pi * frequency * Double(index) / format.sampleRate
            let rampIn = min(Float(index) / Float(rampFrames), 1)
            let rampOut = min(Float(Int(frameCount) - index) / Float(rampFrames), 1)
            channelData[index] = sin(Float(phase)) * amplitude * rampIn * rampOut
        }

        return buffer
    }
}