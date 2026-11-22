import AVFoundation
import Speech

class AudioRecorder: NSObject {
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private var audioFile: AVAudioFile?
    
    // Live real-time Apple Speech recognition (locked to en-US)
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var speechRequest: SFSpeechAudioBufferRecognitionRequest?
    private var speechTask: SFSpeechRecognitionTask?
    private var latestLiveText: String = ""
    
    var outputURL: URL?
    var onLiveText: ((String) -> Void)?
    var onFinalResult: ((String?, URL?) -> Void)?

    func start() {
        let tmpURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("ollama_audio_\(Int(Date().timeIntervalSince1970)).wav")
        outputURL = tmpURL
        latestLiveText = ""

        audioEngine = AVAudioEngine()
        guard let engine = audioEngine else { return }
        inputNode = engine.inputNode
        guard let input = inputNode else { return }

        let fmt = input.outputFormat(forBus: 0)
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: 16000.0,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false
        ]
        do {
            audioFile = try AVAudioFile(forWriting: tmpURL, settings: settings)
        } catch {
            print("[audio] audioFile init error: \(error)")
        }

        // Initialize real-time on-device English buffer recognition
        if let recognizer = speechRecognizer, recognizer.isAvailable {
            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            if recognizer.supportsOnDeviceRecognition {
                request.requiresOnDeviceRecognition = true
            }
            speechRequest = request
            speechTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
                guard let self = self else { return }
                if let result = result {
                    let text = result.bestTranscription.formattedString
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    if !text.isEmpty {
                        self.latestLiveText = text
                        self.onLiveText?(text)
                    }
                }
                if let error = error {
                    print("[audio-live-speech] stream note: \(error.localizedDescription)")
                }
            }
        }

        input.installTap(onBus: 0, bufferSize: 4096, format: fmt) { [weak self] buffer, _ in
            guard let self = self else { return }
            // Feed live audio buffer directly to Apple Speech Recognizer
            self.speechRequest?.append(buffer)

            // Also convert and write to backup WAV file
            if let file = self.audioFile {
                if let c = self.convert(buffer: buffer, to: file.processingFormat) {
                    try? file.write(from: c)
                } else {
                    try? file.write(from: buffer)
                }
            }
        }

        do {
            try engine.start()
        } catch {
            print("[audio] engine start error: \(error)")
        }
    }

    func stop() {
        speechRequest?.endAudio()
        inputNode?.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
        audioFile = nil

        let recognizedText = latestLiveText.trimmingCharacters(in: .whitespacesAndNewlines)
        let fileURL = outputURL

        speechTask?.finish()
        speechTask = nil
        speechRequest = nil

        if !recognizedText.isEmpty {
            // Instant return from real-time live buffer recognition
            if let url = fileURL {
                try? FileManager.default.removeItem(at: url)
            }
            onFinalResult?(recognizedText, nil)
        } else {
            // Fallback to audio file URL
            onFinalResult?(nil, fileURL)
        }
    }

    private func convert(buffer: AVAudioPCMBuffer, to format: AVAudioFormat) -> AVAudioPCMBuffer? {
        guard buffer.format != format,
              let converter = AVAudioConverter(from: buffer.format, to: format) else { return nil }
        let ratio    = format.sampleRate / buffer.format.sampleRate
        let capacity = AVAudioFrameCount(Double(buffer.frameLength) * ratio)
        guard let out = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: capacity) else { return nil }
        var error: NSError?
        var done = false
        converter.convert(to: out, error: &error) { _, status in
            if done { status.pointee = .noDataNow; return nil }
            status.pointee = .haveData
            done = true
            return buffer
        }
        return error == nil ? out : nil
    }
}
