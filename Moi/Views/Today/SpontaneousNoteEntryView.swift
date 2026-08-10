import SwiftUI
import SwiftData

public struct SpontaneousNoteEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
    @State private var noteContent: String = ""
    @FocusState private var isFocused: Bool
    
    public init() {}
    
    public var body: some View {
        HStack(spacing: 12) {
            // Left: Voice Input Mic Icon Button
            Button(action: {
                if speechRecognizer.isRecording {
                    speechRecognizer.stopTranscribing()
                    noteContent = speechRecognizer.transcript
                } else {
                    speechRecognizer.requestPermissions()
                    speechRecognizer.startTranscribing()
                }
            }) {
                Image(systemName: speechRecognizer.isRecording ? "waveform" : "mic.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(speechRecognizer.isRecording ? .red : MoiDesign.Colors.primary)
                    .frame(width: 36, height: 36)
                    .background(speechRecognizer.isRecording ? Color.red.opacity(0.15) : MoiDesign.Colors.tertiaryBackground)
                    .clipShape(Circle())
            }
            
            // Center: Text Field
            TextField("Record a thought...", text: $noteContent)
                .font(.body)
                .focused($isFocused)
            
            // Right: Submit Icon Button
            let isNotEmpty = !noteContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            
            Button(action: {
                guard isNotEmpty else { return }
                let note = SpontaneousNote(date: Date(), content: noteContent)
                modelContext.insert(note)
                
                noteContent = ""
                speechRecognizer.stopTranscribing()
                isFocused = false
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(isNotEmpty ? MoiDesign.Colors.primary : Color.gray.opacity(0.3))
            }
            .disabled(!isNotEmpty)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(MoiDesign.Colors.secondaryBackground)
        .cornerRadius(24)
    }
}
