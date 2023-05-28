//
//  SwiftUIView.swift
//  ImageSpectator
//
//  Created by Keisuke Isono on 2023/05/22.
//

import Foundation

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
    
    func sortedDirectories(sort: DirectorySortType, filter: String) -> [Directory] {
        var result: [Directory] = []
        if sort.rawValue == "time" {
            result = directories.sorted{
                let creationDate1 = try? $0.url.resourceValues(forKeys: [.creationDateKey]).creationDate
                let creationDate2 = try? $1.url.resourceValues(forKeys: [.creationDateKey]).creationDate
                return creationDate1 ?? .distantPast > creationDate2 ?? .distantPast
            }
        } else {
            result = directories.sorted(by: { $0.url.lastPathComponent < $1.url.lastPathComponent })
        }
        return result.filter({filter.isEmpty || $0.url.lastPathComponent.contains(filter)})
    }
    
    func sortedFiles() -> [File] {
        load()
        return files
    }
    
    func next(file: File) -> File? {
        if let index = files.firstIndex(where: { $0.url == file.url }) {
            if files.indices.contains(index + 1) {
                return files[index + 1]
            }
        }
        return nil
    }
    func prev(file: File) -> File? {
        if let index = files.firstIndex(where: { $0.url == file.url }) {
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
        lhs.url == rhs.url
    }
}

class File: Hashable, Identifiable, Equatable {
    let id = UUID()
    let url: URL
    let parent: Directory
    
    static let allowedExtensions = ["jpg", "png", "gif", "webp"]
    
    init(url: URL, parent: Directory) {
        self.url = url
        self.parent = parent
    }
    
    func index() -> Int {
        if let index = parent.files.firstIndex(of: self) {
            return index;
        }
        return -1
    }
    
    func next(num: Int = 1) -> File? {
        var file = self
        for _ in 0 ..< num {
            if let tmp = parent.next(file: file) {
                file = tmp
            } else {
                return nil
            }
        }
        return file
    }
    
    func prev(num: Int = 1) -> File? {
        var file = self
        for _ in 0 ..< num {
            if let tmp = parent.prev(file: file) {
                file = tmp
            } else {
                return nil
            }
        }
        return file
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: File, rhs: File) -> Bool {
        lhs.url == rhs.url
    }
}
