import Foundation
import SwiftData

@Model
public final class AskRecord {
    @Attribute(.unique) public var id: UUID
    public var date: Date
    public var dilemma: String
    public var stanceHeadline: String
    public var explanation: String
    
    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        dilemma: String = "",
        stanceHeadline: String = "",
        explanation: String = ""
    ) {
        self.id = id
        self.date = date
        self.dilemma = dilemma
        self.stanceHeadline = stanceHeadline
        self.explanation = explanation
    }
}
