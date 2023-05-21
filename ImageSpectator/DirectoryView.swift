//
//  DirectoryView.swift
//  ImageSpectator
//
//  Created by Keisuke Isono on 2023/05/21.
//

import SwiftUI

struct DirectoryView: View {
    @ObservedObject var directoryLoader: DirectoryLoader
    @ObservedObject var directoryItem: DirectoryItem
    @Binding var selectedImage: Image?
    @Binding var selectedFileURL: URL?
    @Binding var selectedImageItems: [DirectoryItem]

    var body: some View {
        if directoryItem.isDirectory {
            DisclosureGroup(isExpanded: $directoryItem.isOpened, content: {
                ForEach(directoryItem.children) { childItem in
                    DirectoryView(directoryLoader: directoryLoader,
                                  directoryItem: childItem,
                                  selectedImage: $selectedImage,
                                  selectedFileURL: $selectedFileURL,
                                  selectedImageItems: $selectedImageItems)
                }
            }, label: {
                Text(directoryItem.name)
            })
            .onTapGesture {
                selectedImage = nil
                if directoryItem.name == "ALL" {
                    loadFirstImageFromSubDirectories(directoryItem: directoryItem)
                } else {
                    if directoryItem.children.isEmpty {
                        directoryLoader.fetchContents(for: directoryItem)
                        directoryItem.isOpened = true
                        loadImageItems(directoryItem: directoryItem)
                    } else {
                        directoryItem.isOpened.toggle()
                        if directoryItem.isOpened {
                            loadImageItems(directoryItem: directoryItem)
                        }
                    }
                }
            }
        } else {
            Text(directoryItem.name)
                .foregroundColor(selectedFileURL == directoryItem.url ? .blue : .white)  // Change this line
                .focusable()
                .onTapGesture {
                    if let image = NSImage(contentsOf: directoryItem.url) {
                        self.selectedImage = Image(nsImage: image)
                        self.selectedFileURL = directoryItem.url
                        selectedImageItems = []
                    }
                }
        }
    }
    private func loadImageItems(directoryItem: DirectoryItem) {
        if directoryItem.name == "ALL" {
            loadFirstImageFromSubDirectories(directoryItem: directoryItem)
        } else {
            directoryLoader.fetchContents(for: directoryItem)
            selectedImageItems = directoryItem.children
        }
    }

    private func loadFirstImageFromSubDirectories(directoryItem: DirectoryItem) {
        selectedImageItems = directoryItem.children.compactMap { directory -> DirectoryItem? in
            directoryLoader.preload(directoryItem: directory)
            let files = directory.children
            if let firstImageItem = files.first {
                if firstImageItem.image == nil {
                    if let image = NSImage(contentsOf: firstImageItem.url) {
                        firstImageItem.image = Image(nsImage: image)
                        return firstImageItem
                    }
                }
            }
            return nil
        }
    }
}
