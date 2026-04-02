import AVFoundation

class MusicManager {
    static let shared = MusicManager()
    private init() { configureAudioSession() }

    private var engine = AVAudioEngine()
    private var bgSourceNode: AVAudioSourceNode?
    private var alarmSourceNode: AVAudioSourceNode?
    private var bgPlayerNode: AVAudioPlayerNode?
    private var alarmPlayerNode: AVAudioPlayerNode?

    private var bgPhase: Double = 0
    private var alarmPhase: Double = 0
    private var bgNoteIndex: Int = 0
    private var bgSampleCounter: Int = 0
    private var isBackgroundPlaying = false
    private var isAlarmPlaying = false

    // Silly background melody — pentatonic scale in C major
    private let melodyNotes: [Double] = [
        261.63, 293.66, 329.63, 392.00, 440.00,  // C D E G A
        392.00, 329.63, 293.66, 261.63, 329.63,   // G E D C E
        392.00, 440.00, 523.25, 440.00, 392.00,   // G A C5 A G
        329.63, 261.63, 293.66, 392.00, 329.63,   // E C D G E
    ]
    private let noteDuration: Double = 0.18 // seconds per note
    private let bgVolume: Float = 0.12

    // Alarm — rapid alternating high notes
    private let alarmFreqHigh: Double = 880.0
    private let alarmFreqLow: Double = 660.0
    private let alarmVolume: Float = 0.15
    private var alarmToggle: Bool = false
    private var alarmToggleCounter: Int = 0

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, options: .mixWithOthers)
        try? session.setActive(true)
    }

    func playBackground() {
        guard !isBackgroundPlaying else { return }
        stopAll()

        let sampleRate = engine.outputNode.outputFormat(forBus: 0).sampleRate
        let samplesPerNote = Int(sampleRate * noteDuration)

        let sourceNode = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self = self else { return noErr }
            let bufferList = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let buf = bufferList[0]
            let frames = Int(frameCount)
            guard let data = buf.mData?.assumingMemoryBound(to: Float.self) else { return noErr }

            for i in 0..<frames {
                let freq = self.melodyNotes[self.bgNoteIndex % self.melodyNotes.count]
                let increment = 2.0 * Double.pi * freq / sampleRate

                // Square wave with softened edges (sounds 8-bit)
                let sineVal = sin(self.bgPhase)
                let sample = Float(sineVal > 0 ? 1.0 : -1.0) * self.bgVolume * 0.3
                    + Float(sineVal) * self.bgVolume * 0.7  // mix square + sine
                data[i] = sample

                self.bgPhase += increment
                if self.bgPhase > 2.0 * Double.pi { self.bgPhase -= 2.0 * Double.pi }

                self.bgSampleCounter += 1
                if self.bgSampleCounter >= samplesPerNote {
                    self.bgSampleCounter = 0
                    self.bgNoteIndex += 1
                }
            }
            return noErr
        }

        engine.attach(sourceNode)
        let format = engine.outputNode.outputFormat(forBus: 0)
        engine.connect(sourceNode, to: engine.mainMixerNode, format: format)

        do {
            try engine.start()
            isBackgroundPlaying = true
            bgSourceNode = sourceNode
        } catch {
            print("Music engine failed: \(error)")
        }
    }

    func playAlarm() {
        guard !isAlarmPlaying, engine.isRunning else { return }

        let sampleRate = engine.outputNode.outputFormat(forBus: 0).sampleRate
        let samplesPerToggle = Int(sampleRate * 0.12) // toggle every 0.12s

        let sourceNode = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self = self else { return noErr }
            let bufferList = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let buf = bufferList[0]
            let frames = Int(frameCount)
            guard let data = buf.mData?.assumingMemoryBound(to: Float.self) else { return noErr }

            let freq = self.alarmToggle ? self.alarmFreqHigh : self.alarmFreqLow

            for i in 0..<frames {
                let increment = 2.0 * Double.pi * freq / sampleRate
                let sample = Float(sin(self.alarmPhase)) * self.alarmVolume
                data[i] = sample

                self.alarmPhase += increment
                if self.alarmPhase > 2.0 * Double.pi { self.alarmPhase -= 2.0 * Double.pi }

                self.alarmToggleCounter += 1
                if self.alarmToggleCounter >= samplesPerToggle {
                    self.alarmToggleCounter = 0
                    self.alarmToggle.toggle()
                }
            }
            return noErr
        }

        engine.attach(sourceNode)
        let format = engine.outputNode.outputFormat(forBus: 0)
        engine.connect(sourceNode, to: engine.mainMixerNode, format: format)
        isAlarmPlaying = true
        alarmSourceNode = sourceNode
    }

    func stopAlarm() {
        guard isAlarmPlaying, let node = alarmSourceNode else { return }
        engine.detach(node)
        alarmSourceNode = nil
        isAlarmPlaying = false
        alarmPhase = 0
        alarmToggleCounter = 0
    }

    func stopAll() {
        if let bg = bgSourceNode {
            engine.detach(bg)
            bgSourceNode = nil
        }
        if let alarm = alarmSourceNode {
            engine.detach(alarm)
            alarmSourceNode = nil
        }
        engine.stop()
        isBackgroundPlaying = false
        isAlarmPlaying = false
        bgPhase = 0
        bgNoteIndex = 0
        bgSampleCounter = 0
        alarmPhase = 0
        alarmToggleCounter = 0
    }

    func pauseAll() {
        engine.pause()
    }

    func resumeAll() {
        try? engine.start()
    }
}
