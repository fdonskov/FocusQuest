import Foundation
import AVFoundation

struct AmbientConfig {
    let root: Double
    let pad: [Double]
    let noise: Double

    static let byLocation: [String: AmbientConfig] = [
        "meadow":    AmbientConfig(root: 261.63, pad: [1, 1.5, 2],          noise: 0.015),
        "forest":    AmbientConfig(root: 220.00, pad: [1, 1.5, 2],          noise: 0.03),
        "caves":     AmbientConfig(root: 130.81, pad: [1, 1.49, 2.01],      noise: 0.05),
        "mountains": AmbientConfig(root: 196.00, pad: [1, 1.5, 2],          noise: 0.07),
        "castle":    AmbientConfig(root: 174.61, pad: [1, 1.5, 2.5],        noise: 0.02),
        "voidgate":  AmbientConfig(root: 293.66, pad: [1, 1.498, 2.002, 3], noise: 0.05),
    ]

    static func config(for id: String) -> AmbientConfig {
        byLocation[id] ?? byLocation["meadow"]!
    }
}

// Calm sustained drone: detuned sine voices with slow tremolo + soft filtered noise. No melodic plinks.
private final class Synth: @unchecked Sendable {
    let sampleRate: Double
    var freqs: [Double] = []
    var phase: [Double] = []
    var lfoPhase: [Double] = []
    var lfoRate: [Double] = []
    var noiseLevel = 0.0

    var master = 0.0
    var target = 0.0

    private var noiseLP = 0.0
    private var rng: UInt64 = 0x9E3779B97F4A7C15

    init(sampleRate: Double) { self.sampleRate = sampleRate }

    private func nextRandom() -> Double {
        rng ^= rng << 13; rng ^= rng >> 7; rng ^= rng << 17
        return Double(rng >> 11) / Double(1 << 53)
    }

    func configure(_ c: AmbientConfig) {
        // Each pad tone gets a slightly detuned partner for warmth.
        var f: [Double] = []
        for mult in c.pad {
            f.append(mult * c.root)
            f.append(mult * c.root * 1.004)
        }
        freqs = f
        phase = Array(repeating: 0, count: f.count)
        lfoPhase = (0..<f.count).map { _ in nextRandom() }
        lfoRate = (0..<f.count).map { _ in 0.03 + nextRandom() * 0.06 }
        noiseLevel = c.noise
    }

    func render(frames: Int, into buffer: UnsafeMutablePointer<Float>) {
        for i in 0..<frames {
            target == 0 ? (master -= master * 0.00004) : (master += (target - master) * 0.00003)

            var sample = 0.0
            for v in 0..<freqs.count {
                let tremolo = 0.55 + 0.45 * sin(2 * .pi * lfoPhase[v])
                sample += sin(2 * .pi * phase[v]) * 0.1 * tremolo
                phase[v] += freqs[v] / sampleRate
                if phase[v] >= 1 { phase[v] -= 1 }
                lfoPhase[v] += lfoRate[v] / sampleRate
                if lfoPhase[v] >= 1 { lfoPhase[v] -= 1 }
            }

            if noiseLevel > 0 {
                let white = nextRandom() * 2 - 1
                noiseLP += (white - noiseLP) * 0.015
                sample += noiseLP * noiseLevel
            }

            buffer[i] = Float(sample * master * 0.16)
        }
    }
}

@MainActor
final class AudioService {
    static let shared = AudioService()

    private let engine = AVAudioEngine()
    private var node: AVAudioSourceNode?
    private let synth = Synth(sampleRate: 44100)
    private var synthRunning = false

    private var player: AVAudioPlayer?
    private var rotationIndex: Int?

    func start(locationID: String, presetMinutes: Int) {
        configureSession()
        stopPlayer()

        let pool = trackPool(for: locationID, presetMinutes: presetMinutes)
        guard !pool.isEmpty else {
            startSynth(for: locationID)
            return
        }
        // Global round-robin: every focus start plays the next track in the pool,
        // regardless of location or timer length, so it varies everywhere.
        let index = AmbientTrackSelector.nextIndex(current: rotationIndex, count: pool.count)
        rotationIndex = index
        startFile(pool[index], fallbackID: locationID)
    }

    func stop() {
        stopPlayer()
        synth.target = 0
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            if synth.target == 0, player == nil {
                engine.stop()
                synthRunning = false
            }
        }
    }

    // Pool of bundled tracks, most specific first:
    // ambient_<id>_<preset> (location + timer) → ambient_<id> (location) → ambient_default (global).
    // Each tier also picks up numbered variants (..._1, ..._2, ...) for the rotation pool.
    private func trackPool(for id: String, presetMinutes: Int) -> [URL] {
        AmbientTrackSelector.pool(
            perPreset: files(prefix: "ambient_\(id)_\(presetMinutes)"),
            perLocation: files(prefix: "ambient_\(id)"),
            perDefault: files(prefix: "ambient_default"))
    }

    private func files(prefix: String) -> [URL] {
        var urls: [URL] = []
        if let base = resource(prefix) { urls.append(base) }
        var n = 1
        while let next = resource("\(prefix)_\(n)") {
            urls.append(next)
            n += 1
            if n > 50 { break }
        }
        return urls
    }

    private func resource(_ name: String) -> URL? {
        for ext in ["m4a", "mp3", "wav", "caf"] {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                return url
            }
        }
        return nil
    }

    private func startFile(_ url: URL, fallbackID: String) {
        synth.target = 0
        do {
            let p = try AVAudioPlayer(contentsOf: url)
            p.numberOfLoops = -1
            p.volume = 0
            p.prepareToPlay()
            p.play()
            p.setVolume(0.6, fadeDuration: 2)
            player = p
        } catch {
            startSynth(for: fallbackID)
        }
    }

    private func stopPlayer() {
        player?.setVolume(0, fadeDuration: 1.2)
        let outgoing = player
        player = nil
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_300_000_000)
            outgoing?.stop()
        }
    }

    private func startSynth(for id: String) {
        synth.configure(AmbientConfig.config(for: id))
        synth.target = 1
        installNodeIfNeeded()
        guard !synthRunning else { return }
        do {
            try engine.start()
            synthRunning = true
        } catch {
            synthRunning = false
        }
    }

    private func configureSession() {
        #if os(iOS)
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        #endif
    }

    private func installNodeIfNeeded() {
        guard node == nil else { return }
        let synth = self.synth
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
        let source = AVAudioSourceNode { _, _, frameCount, audioBufferList in
            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let frames = Int(frameCount)
            guard let first = abl.first, let base = first.mData else { return noErr }
            synth.render(frames: frames, into: base.assumingMemoryBound(to: Float.self))
            for buffer in abl.dropFirst() {
                if let data = buffer.mData {
                    memcpy(data, base, frames * MemoryLayout<Float>.size)
                }
            }
            return noErr
        }
        engine.attach(source)
        engine.connect(source, to: engine.mainMixerNode, format: format)
        node = source
    }
}
