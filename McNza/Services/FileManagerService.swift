import Foundation

class FileManagerService {
    static let shared = FileManagerService()
    private let fileManager = FileManager.default
    
    private init() {}
    
    func deleteFile(at url: URL) -> Bool {
        do {
            try fileManager.removeItem(at: url)
            print("Successfully deleted file at: \(url)")
            return true
        } catch {
            print("Error deleting file: \(error)")
            return false
        }
    }
    
    func deleteFileFromDocuments(fileName: String) -> Bool {
        let documentsPath = FileManager.getDocumentsDirectory()
        let fileURL = documentsPath.appendingPathComponent(fileName)
        return deleteFile(at: fileURL)
    }
} 