import SwiftUI
import Combine

public final class AppState: ObservableObject {
    @Published public var isInitialized: Bool = false
    
    public init() {}
}
