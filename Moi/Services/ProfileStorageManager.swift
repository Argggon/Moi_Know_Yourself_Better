import Foundation

/// Manages fluid Markdown file persistence for user_profile.md and Story letters
public final class ProfileStorageManager {
    public static let shared = ProfileStorageManager()
    
    private let fileManager = FileManager.default
    
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var profileFileURL: URL {
        documentsDirectory.appendingPathComponent("user_profile.md")
    }
    
    private var storiesDirectoryURL: URL {
        let dir = documentsDirectory.appendingPathComponent("Stories")
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
    
    private init() {}
    
    // MARK: - User Profile Markdown
    public func loadUserProfile() -> String {
        if fileManager.fileExists(atPath: profileFileURL.path),
           let content = try? String(contentsOf: profileFileURL, encoding: .utf8) {
            return content
        }
        return """
        # Moi User Persona
        
        *Updated monthly based on daily reflections and instant feelings.*
        
        ## Core Traits
        - Pending first monthly story...
        """
    }
    
    public func loadProfile() -> String {
        return loadUserProfile()
    }
    
    public func saveUserProfile(_ content: String) throws {
        try content.write(to: profileFileURL, atomically: true, encoding: .utf8)
    }
    
    public func saveProfile(_ content: String) {
        try? saveUserProfile(content)
    }
    
    // MARK: - Monthly Story Letters
    public func saveStoryLetter(monthYearKey: String, content: String) throws {
        let fileURL = storiesDirectoryURL.appendingPathComponent("Story_\(monthYearKey).md")
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
    }
    
    public func saveLetter(yearMonth: String, content: String) {
        try? saveStoryLetter(monthYearKey: yearMonth, content: content)
    }
    
    public func loadStoryLetter(monthYearKey: String) -> String? {
        let fileURL = storiesDirectoryURL.appendingPathComponent("Story_\(monthYearKey).md")
        return try? String(contentsOf: fileURL, encoding: .utf8)
    }
    
    public func loadLetter(yearMonth: String) -> String {
        return loadStoryLetter(monthYearKey: yearMonth) ?? ""
    }
    
    public func listAllStories() -> [URL] {
        guard let files = try? fileManager.contentsOfDirectory(at: storiesDirectoryURL, includingPropertiesForKeys: nil) else {
            return []
        }
        return files.filter { $0.pathExtension == "md" }.sorted { $0.lastPathComponent > $1.lastPathComponent }
    }
    
    public func listAllLetters() -> [String] {
        return listAllStories().map { $0.lastPathComponent }
    }
    
    public func clearAllData() {
        try? fileManager.removeItem(at: profileFileURL)
        try? fileManager.removeItem(at: storiesDirectoryURL)
    }
}
