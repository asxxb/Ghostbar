import Foundation
import Speech

let WHISPER_BIN = "/usr/local/bin/whisper-cli"

func isAppleSpeechAvailable() -> Bool {
    return SFSpeechRecognizer()?.isAvailable ?? false
}

func findWhisperBin() -> String? {
    [WHISPER_BIN, "/opt/homebrew/bin/whisper-cli", "/usr/local/bin/whisper-cli"]
        .first { FileManager.default.fileExists(atPath: $0) }
}

func findWhisperModel() -> String? {
    let dirs = [
        "/opt/homebrew/share/whisper-cpp",
        "/opt/homebrew/share/whisper-cpp/models",
        "/usr/local/share/whisper-cpp",
        NSHomeDirectory() + "/.cache/whisper",
        NSHomeDirectory() + "/.ollama-chat",
    ]
    let preferred = ["ggml-base.en.bin","ggml-base.bin","ggml-small.bin","ggml-tiny.bin","ggml-medium.bin"]
    for dir in dirs {
        for name in preferred {
            let p = dir + "/" + name
            if FileManager.default.fileExists(atPath: p) { return p }
        }
        if let files = try? FileManager.default.contentsOfDirectory(atPath: dir),
           let m = files.first(where: { $0.hasSuffix(".bin") && $0.contains("ggml") }) {
            return dir + "/" + m
        }
    }
    return nil
}

func transcribeWithAppleSpeech(audioURL: URL, completion: @escaping (String?) -> Void) {
    SFSpeechRecognizer.requestAuthorization { authStatus in
        guard authStatus == .authorized else {
            print("[speech] Authorization status: \(authStatus.rawValue)")
            completion(nil)
            return
        }

        let recognizer = SFSpeechRecognizer(locale: Locale.current) ?? SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        guard let recognizer = recognizer, recognizer.isAvailable else {
            print("[speech] Recognizer not available")
            completion(nil)
            return
        }

        let request = SFSpeechURLRecognitionRequest(url: audioURL)
        request.shouldReportPartialResults = false
        if recognizer.supportsOnDeviceRecognition {
            request.requiresOnDeviceRecognition = true
        }

        var finished = false
        recognizer.recognitionTask(with: request) { result, error in
            if finished { return }
            if let result = result, result.isFinal {
                finished = true
                let text = result.bestTranscription.formattedString
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                print("[speech] Transcribed via Apple Speech: \(text)")
                completion(text.isEmpty ? nil : text)
            } else if let error = error {
                print("[speech] Error: \(error.localizedDescription)")
                if request.requiresOnDeviceRecognition {
                    // Try fallback without requiring on-device in case asset is not installed locally
                    let fallbackReq = SFSpeechURLRecognitionRequest(url: audioURL)
                    fallbackReq.shouldReportPartialResults = false
                    fallbackReq.requiresOnDeviceRecognition = false
                    recognizer.recognitionTask(with: fallbackReq) { res2, err2 in
                        if finished { return }
                        if let res2 = res2, res2.isFinal {
                            finished = true
                            let text = res2.bestTranscription.formattedString
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                            completion(text.isEmpty ? nil : text)
                        } else if err2 != nil {
                            finished = true
                            completion(nil)
                        }
                    }
                } else {
                    finished = true
                    completion(nil)
                }
            }
        }
    }
}

func transcribeWithWhisper(audioURL: URL, completion: @escaping (String?) -> Void) {
    guard let bin   = findWhisperBin(),
          let model = findWhisperModel() else { completion(nil); return }
    print("[whisper] \(bin) model=\(model)")
    let task = Process()
    task.executableURL = URL(fileURLWithPath: bin)
    task.arguments = ["--model", model, "--language", "auto", "--output-txt", "--no-prints", "--file", audioURL.path]
    let pipe = Pipe()
    task.standardOutput = pipe; task.standardError = Pipe()
    task.terminationHandler = { _ in
        let txtURL = audioURL.deletingPathExtension().appendingPathExtension("txt")
        if let text = try? String(contentsOf: txtURL, encoding: .utf8) {
            let cleaned = text
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "\\[.*?\\]", with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            try? FileManager.default.removeItem(at: txtURL)
            completion(cleaned.isEmpty ? nil : cleaned)
        } else {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let text = (String(data: data, encoding: .utf8) ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            completion(text.isEmpty ? nil : text)
        }
    }
    do { try task.run() } catch { print("[whisper] \(error)"); completion(nil) }
}

func transcribe(audioURL: URL, completion: @escaping (String?) -> Void) {
    // 1. Prefer Apple Speech Recognition (native on macOS, zero dependencies)
    transcribeWithAppleSpeech(audioURL: audioURL) { appleText in
        if let appleText = appleText, !appleText.isEmpty {
            try? FileManager.default.removeItem(at: audioURL)
            completion(appleText)
            return
        }

        // 2. Fallback to whisper if available
        transcribeWithWhisper(audioURL: audioURL) { whisperText in
            try? FileManager.default.removeItem(at: audioURL)
            completion(whisperText)
        }
    }
}
