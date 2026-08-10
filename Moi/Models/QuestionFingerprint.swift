import Foundation
import SwiftData

@Model
public final class QuestionFingerprint {
    @Attribute(.unique) public var id: UUID
    public var date: Date
    public var questionText: String
    public var depthLevel: String // "light", "medium", "deep"
    public var tags: [String]
    
    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        questionText: String = "",
        depthLevel: String = "light",
        tags: [String] = []
    ) {
        self.id = id
        self.date = date
        self.questionText = questionText
        self.depthLevel = depthLevel
        self.tags = tags
    }
}
