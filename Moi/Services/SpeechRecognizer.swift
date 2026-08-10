import Foundation
import Speech
import AVFoundation
import Combine

public final class SpeechRecognizer: ObservableObject {
    @Published public var transcript: String = ""
    @Published public var isRecording: Bool = false
    @Published public var errorMessage: String? = nil
    
    private var audioEngine = AVAudioEngine()
    private var speechRecognizer: SFSpeechRecognizer?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    public init(locale: Locale = Locale(identifier: "zh_CN")) {
        speechRecognizer = SFSpeechRecognizer(locale: locale)
    }
    
    public func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                if authStatus != .authorized {
                    self.errorMessage = "语音识别未获得授权，请在设置中开启。"
                }
            }
        }
    }
    
    public func startTranscribing() {
        guard !isRecording else { return }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            self.errorMessage = "无法初始化音频输入：" + error.localizedDescription
            return
        }
        
        request = SFSpeechAudioBufferRecognitionRequest()
        guard let request = request else { return }
        request.shouldReportPartialResults = true
        
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            self.errorMessage = "无法启动录音引擎：" + error.localizedDescription
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.transcript = result.bestTranscription.formattedString
                }
            }
            if error != nil {
                self.stopTranscribing()
            }
        }
    }
    
    public func stopTranscribing() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        recognitionTask?.cancel()
        
        request = nil
        recognitionTask = nil
        isRecording = false
    }
}
