import Foundation
import SwiftData

@Model
public final class DailyLog {
    @Attribute(.unique) public var id: UUID
    public var date: Date
    public var questionEn: String
    public var questionZh: String
    public var rawAnswer: String
    public var refinedAnswer: String
    public var isRefinedUsed: Bool
    public var depthLevel: String // "light", "medium", "deep"
    public var isCompleted: Bool
    
    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        questionEn: String = "",
        questionZh: String = "",
        rawAnswer: String = "",
        refinedAnswer: String = "",
        isRefinedUsed: Bool = true,
        depthLevel: String = "light",
        isCompleted: Bool = false
    ) {
        self.id = id
        self.date = date
        self.questionEn = questionEn
        self.questionZh = questionZh
        self.rawAnswer = rawAnswer
        self.refinedAnswer = refinedAnswer
        self.isRefinedUsed = isRefinedUsed
        self.depthLevel = depthLevel
        self.isCompleted = isCompleted
    }
}
