//
//  SwiftUIView.swift
//  ImageSpectator
//
//  Created by Keisuke Isono on 2023/05/21.
//

import SwiftUI

class DirectoryLoader: ObservableObject {
    @Published var rootDirectory: DirectoryItem
    @Published var selectedImage: Image?
    @Published var selectedFileURL: URL?
    @Published var selectedImageItems: [DirectoryItem] = []
    
    static let allowedExtensions = ["jpg", "png", "gif", "webp"]

    init(opened:Bool = false) {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let rootDirectoryURL = homeDirectory.appendingPathComponent("tmp")
        self.rootDirectory = DirectoryItem(url: rootDirectoryURL, name:"ALL", isDirectory: true, isOpened: opened)
        fetchContents(for: self.rootDirectory)
    }
    
    func preload(directoryItem: DirectoryItem) {
        directoryItem.children = Self.fetchDirectoryContent(from: directoryItem.url, parent: directoryItem)
    }

    func fetchContents(for directoryItem: DirectoryItem) {
        directoryItem.children = Self.fetchDirectoryContent(from: directoryItem.url, parent: directoryItem)

        for childItem in directoryItem.children {
            if !childItem.isDirectory && DirectoryLoader.allowedExtensions.contains(childItem.url.pathExtension) {
                if let nsImage = NSImage(contentsOf: childItem.url) {
                    childItem.image = Image(nsImage: nsImage)
                }
            }
        }
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
