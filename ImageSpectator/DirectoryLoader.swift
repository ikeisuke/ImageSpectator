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
    
    static let allowedExtensions = ["jpg", "png", "gif", "webp"]

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
                if exists && (isDirectory.boolValue || allowedExtensions.contains(fileURL.pathExtension)) {
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
