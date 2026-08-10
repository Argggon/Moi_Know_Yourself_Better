import Foundation
import SwiftData

@Model
public final class SpontaneousNote {
    @Attribute(.unique) public var id: UUID
    public var date: Date
    public var content: String
    
    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        content: String = ""
    ) {
        self.id = id
        self.date = date
        self.content = content
    }
}
