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
    
    private var isRecording = false
    private let lock = NSLock()
    
    // Accumulation state across pauses and utterances
    private var accumulatedText: String = ""
    private var currentUtteranceText: String = ""
    private var latestLiveText: String = ""
    
    var outputURL: URL?
    var onLiveText: ((String) -> Void)?
    var onFinalResult: ((String?, URL?) -> Void)?

    func start() {
        lock.lock()
        isRecording = true
        accumulatedText = ""
        currentUtteranceText = ""
        latestLiveText = ""
        lock.unlock()

        let tmpURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("ollama_audio_\(Int(Date().timeIntervalSince1970)).wav")
        outputURL = tmpURL

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

        // Initialize real-time continuous dictation
        startSpeechRequest()

        input.installTap(onBus: 0, bufferSize: 4096, format: fmt) { [weak self] buffer, _ in
            guard let self = self else { return }
            self.appendBuffer(buffer)

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

    private func appendBuffer(_ buffer: AVAudioPCMBuffer) {
        lock.lock()
        let req = speechRequest
        lock.unlock()
        req?.append(buffer)
    }

    private func startSpeechRequest() {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else { return }
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.taskHint = .dictation
        if #available(macOS 13, *) {
            request.addsPunctuation = true
        }
        if recognizer.supportsOnDeviceRecognition {
            request.requiresOnDeviceRecognition = true
        }

        lock.lock()
        self.speechRequest = request
        lock.unlock()

        speechTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            self?.handleSpeechResult(result: result, error: error)
        }
    }

    private func restartSpeechRequest() {
        lock.lock()
        guard isRecording else {
            lock.unlock()
            return
        }
        speechTask?.cancel()
        speechTask = nil
        speechRequest = nil
        lock.unlock()

        startSpeechRequest()
    }

    private func handleSpeechResult(result: SFSpeechRecognitionResult?, error: Error?) {
        lock.lock()
        guard isRecording else {
            lock.unlock()
            return
        }

        if let result = result {
            let text = result.bestTranscription.formattedString
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty {
                // Determine whether this text is an extension of the current utterance,
                // or if the recognizer started a new utterance/sentence after a pause.
                let isContinuation = currentUtteranceText.isEmpty ||
                                     text.hasPrefix(currentUtteranceText) ||
                                     currentUtteranceText.hasPrefix(text) ||
                                     wordsOverlap(currentUtteranceText, text)

                if isContinuation {
                    currentUtteranceText = text
                } else {
                    // Recognizer reset or started a new sentence across a pause without isFinal
                    accumulatedText = combineTexts(accumulatedText, currentUtteranceText)
                    currentUtteranceText = text
                }

                let fullText = combineTexts(accumulatedText, currentUtteranceText)
                self.latestLiveText = fullText
                lock.unlock()

                self.onLiveText?(fullText)

                if result.isFinal {
                    lock.lock()
                    accumulatedText = fullText
                    currentUtteranceText = ""
                    let stillRecording = isRecording
                    lock.unlock()

                    if stillRecording {
                        DispatchQueue.global().async { [weak self] in
                            self?.restartSpeechRequest()
                        }
                    }
                }
                return
            }
        }

        if let error = error {
            print("[audio-live-speech] stream note: \(error.localizedDescription)")
            if !currentUtteranceText.isEmpty {
                accumulatedText = combineTexts(accumulatedText, currentUtteranceText)
                currentUtteranceText = ""
            }
            let stillRecording = isRecording
            lock.unlock()

            if stillRecording {
                DispatchQueue.global().async { [weak self] in
                    self?.restartSpeechRequest()
                }
            }
            return
        }

        lock.unlock()
    }

    private func combineTexts(_ s1: String, _ s2: String) -> String {
        let t1 = s1.trimmingCharacters(in: .whitespacesAndNewlines)
        let t2 = s2.trimmingCharacters(in: .whitespacesAndNewlines)
        if t1.isEmpty { return t2 }
        if t2.isEmpty { return t1 }
        let lastChar = t1.last
        let needsPeriod = (lastChar != "." && lastChar != "?" && lastChar != "!" && lastChar != ",")
        let separator = needsPeriod ? ". " : " "
        return "\(t1)\(separator)\(t2)"
    }

    private func wordsOverlap(_ s1: String, _ s2: String) -> Bool {
        let w1 = s1.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        let w2 = s2.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        guard let first1 = w1.first?.lowercased(), let first2 = w2.first?.lowercased() else { return true }
        return first1 == first2
    }

    func stop() {
        lock.lock()
        isRecording = false
        speechRequest?.endAudio()
        speechRequest = nil
        speechTask?.cancel()
        speechTask = nil

        let finalFull = combineTexts(accumulatedText, currentUtteranceText)
        if !finalFull.isEmpty {
            latestLiveText = finalFull
        }
        let recognizedText = latestLiveText.trimmingCharacters(in: .whitespacesAndNewlines)
        lock.unlock()

        inputNode?.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
        audioFile = nil

        let fileURL = outputURL

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
