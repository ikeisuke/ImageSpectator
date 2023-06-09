//
//  SwiftUIView.swift
//  ImageSpectator
//
//  Created by Keisuke Isono on 2023/05/21.
//

import SwiftUI

class DirectoryLoader: ObservableObject {
    @Published var rootDirectory: DirectoryItem?
    @Published var selectedImage: Image?
    @Published var selectedFileURL: URL?
    @Published var selectedImageItems: [DirectoryItem] = []
    @Published var isLoading = false
    
    static let allowedExtensions = ["jpg", "jpeg", "png", "gif", "webp"]

    init(directoryURL: URL?, opened:Bool = false) {
        if let dir = directoryURL {
            self.rootDirectory = DirectoryItem(url: dir, name:"ALL", isDirectory: true, isOpened: opened)
            if let root = self.rootDirectory {
                fetchContents(for: root)
            }
        }
    }
    
    func preload(directoryItem: DirectoryItem) {
        self.isLoading = true
        directoryItem.children = Self.fetchDirectoryContent(from: directoryItem.url, parent: directoryItem)
        self.isLoading = false
    }

    func fetchContents(for directoryItem: DirectoryItem) {
        self.isLoading = true
        directoryItem.children = Self.fetchDirectoryContent(from: directoryItem.url, parent: directoryItem)
        self.isLoading = false
    }

    private func createDirectoryItem(url: URL) -> DirectoryItem {
        return DirectoryItem(url: url, name:url.lastPathComponent, isDirectory: true)
    }

    private static func fetchDirectoryContent(from url: URL, parent: DirectoryItem) -> [DirectoryItem] {
        let fileManager = FileManager.default
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
                .sorted(by: { $0.lastPathComponent < $1.lastPathComponent })
            var directoryItems: [DirectoryItem] = []
            for fileURL in fileURLs {
                var isDirectory: ObjCBool = false
                let exists = fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDirectory)
                if exists && (isDirectory.boolValue || allowedExtensions.contains(fileURL.pathExtension.lowercased())) {
                    let childItem = DirectoryItem(url: fileURL, name: fileURL.lastPathComponent, isDirectory: isDirectory.boolValue)
                    childItem.parent = parent
                    directoryItems.append(childItem)
                }
            }
            return directoryItems
        } catch {
            print("Error while enumerating files \(url.path): \(error.localizedDescription)")
            return []
        }
    }
    
    
    func loadImageItems(directoryItem: DirectoryItem) {
        selectedImageItems = directoryItem.children
        if let firstImageItem = selectedImageItems.first, let image = NSImage(contentsOf: firstImageItem.url) {
            selectedImage = Image(nsImage: image)
            selectedFileURL = firstImageItem.url
        }
    }
}


class Directory: Hashable, Identifiable {
    let id = UUID()
    let url: URL
    var directories: [Directory] = []
    var files: [File] = []
    weak var parent: Directory?
    var isOpened: Bool = false
    
    private var loaded: Bool = false
    
    init(url: URL, parent: Directory?) {
        self.url = url
        self.parent = parent
    }
    
    func load() {
        if loaded {
            return
        }
        let fileManager = FileManager.default
        do {
            let contents = try fileManager.contentsOfDirectory(at: self.url, includingPropertiesForKeys: [.contentAccessDateKey])
            var tmpFiles: [File] = [];
            for content in contents {
                var isDirectory: ObjCBool = false
                let exists = fileManager.fileExists(atPath: content.path, isDirectory: &isDirectory)
                if exists {
                    if isDirectory.boolValue {
                        directories.append(Directory(url: content, parent: self))
                    } else if File.allowedExtensions.contains(content.pathExtension.lowercased()) {
                        tmpFiles.append(File(url: content, parent: self))
                    }
                }
            }
            files = tmpFiles.sorted(by: { $0.url.lastPathComponent < $1.url.lastPathComponent })
            loaded = true
        } catch {
            print("Error while enumerating files \(url.path): \(error.localizedDescription)")
        }
    }
    
    func sorted(sort: String) -> [Directory] {
        if sort == "time" {
            return directories.sorted{
                let creationDate1 = try? $0.url.resourceValues(forKeys: [.creationDateKey]).creationDate
                let creationDate2 = try? $1.url.resourceValues(forKeys: [.creationDateKey]).creationDate
                return creationDate1 ?? .distantPast > creationDate2 ?? .distantPast
            }
        } else {
            return directories.sorted(by: { $0.url.lastPathComponent < $1.url.lastPathComponent })
        }
     }
    
    func next(file: File) -> File? {
        if let index = files.firstIndex(of: file) {
            if files.indices.contains(index + 1) {
                return files[index + 1]
            }
        }
        return nil
    }
    
    func prev(file: File) -> File? {
        if let index = files.firstIndex(of: file) {
            if files.indices.contains(index - 1) {
                return files[index - 1]
            }
        }
        return nil
    }
    
    func hasDirectory() -> Bool {
        return !directories.isEmpty
    }
    
    func hasFile() -> Bool {
        return !files.isEmpty
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Directory, rhs: Directory) -> Bool {
        lhs.id == rhs.id
    }
}

class File: Hashable, Identifiable {
    let id = UUID()
    let url: URL
    let parent: Directory
    
    static let allowedExtensions = ["jpg", "png", "gif", "webp"]
    
    init(url: URL, parent: Directory) {
        self.url = url
        self.parent = parent
    }
    
    func next() -> File? {
        return parent.next(file: self)
    }
    
    func prev() -> File? {
        return parent.prev(file: self)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: File, rhs: File) -> Bool {
        lhs.id == rhs.id
    }
}
