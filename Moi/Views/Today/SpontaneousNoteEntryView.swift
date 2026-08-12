import SwiftUI
import SwiftData

public struct SpontaneousNoteEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
    @State private var noteContent: String = ""
    
    public init() {}
    
    public var body: some View {
        MoiInputBar(
            text: $noteContent,
            placeholder: "Record a thought...",
            isRecording: speechRecognizer.isRecording,
            onVoiceInput: {
                if speechRecognizer.isRecording {
                    speechRecognizer.stopTranscribing()
                    noteContent = speechRecognizer.transcript
                } else {
                    speechRecognizer.requestPermissions()
                    speechRecognizer.startTranscribing()
                }
            },
            onSubmit: {
                let note = SpontaneousNote(date: Date(), content: noteContent)
                modelContext.insert(note)
                
                noteContent = ""
                speechRecognizer.stopTranscribing()
            }
        )
    }
}
