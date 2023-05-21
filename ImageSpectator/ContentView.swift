//
//  ContentView.swift
//  ImageSpectator
//
//  Created by Keisuke Isono on 2023/05/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var directoryLoader = DirectoryLoader(opened: true)
    @State private var selectedImage: Image? = nil
    @State private var selectedFileURL: URL? = nil
    @State private var selectedImageItems: [DirectoryItem] = []
    @State private var focusedItem: DirectoryItem?

    var body: some View {
        GeometryReader { geometry in
            HSplitView {
                ScrollView {
                    DirectoryView(directoryLoader: directoryLoader, directoryItem: directoryLoader.rootDirectory, selectedImage: $selectedImage, selectedFileURL: $selectedFileURL, selectedImageItems: $selectedImageItems, focusedItem:$focusedItem)
                        .frame(width: 200)
                }
                if let image = selectedImage{
                   image
                       .resizable()
                       .aspectRatio(contentMode: .fit)
               } else if !selectedImageItems.isEmpty {
                   ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                            ForEach(selectedImageItems, id: \.id) { imageItem in
                                if let image = imageItem.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 200)
                                }
                            }
                        }
                    }
                } else {
                    Color.gray
                }
            }
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class DirectoryItem: ObservableObject, Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let name: String
    let isDirectory: Bool
    @Published var isOpened: Bool = false
    @Published var children: [DirectoryItem] = []
    @Published var image: Image? = nil
    
    init(url: URL, name: String, isDirectory: Bool, isOpened: Bool = false) {
        self.url = url
        self.name = name
        self.isDirectory = isDirectory
        self.isOpened = isOpened
    }
    
    static func == (lhs: DirectoryItem, rhs: DirectoryItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct DirectoryView: View {
    @ObservedObject var directoryLoader: DirectoryLoader
    @ObservedObject var directoryItem: DirectoryItem
    @Binding var selectedImage: Image?
    @Binding var selectedFileURL: URL?
    @Binding var selectedImageItems: [DirectoryItem]
    @Binding var focusedItem: DirectoryItem?

    var body: some View {
        if directoryItem.isDirectory {
            DisclosureGroup(isExpanded: $directoryItem.isOpened, content: {
                ForEach(directoryItem.children) { childItem in
                    DirectoryView(directoryLoader: directoryLoader,
                                  directoryItem: childItem,
                                  selectedImage: $selectedImage,
                                  selectedFileURL: $selectedFileURL,
                                  selectedImageItems: $selectedImageItems,
                                  focusedItem: $focusedItem)
                }
            }, label: {
                Text(directoryItem.name)
            })
            .onTapGesture {
                selectedImage = nil
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
        selectedImageItems = directoryItem.children
        if let firstImageItem = selectedImageItems.first, let image = NSImage(contentsOf: firstImageItem.url) {
            selectedImage = Image(nsImage: image)
            selectedFileURL = firstImageItem.url
        }
    }
}

class DirectoryLoader: ObservableObject {
    @Published var rootDirectory: DirectoryItem
    
    static let allowedExtensions = ["jpg", "png", "gif", "webp"]

    init(opened:Bool = false) {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let rootDirectoryURL = homeDirectory.appendingPathComponent("tmp")
        self.rootDirectory = DirectoryItem(url: rootDirectoryURL, name:"ALL", isDirectory: true, isOpened: opened)
        fetchContents(for: self.rootDirectory)
    }

    func fetchContents(for directoryItem: DirectoryItem) {
        directoryItem.children = Self.fetchDirectoryContent(from: directoryItem.url)

        for childItem in directoryItem.children {
            if !childItem.isDirectory && DirectoryLoader.allowedExtensions.contains(childItem.url.pathExtension) {
                DispatchQueue.global(qos: .background).async {
                    if let nsImage = NSImage(contentsOf: childItem.url) {
                        DispatchQueue.main.async {
                            childItem.image = Image(nsImage: nsImage)
                        }
                    }
                }
            }
        }
    }

    private func createDirectoryItem(url: URL) -> DirectoryItem {
        return DirectoryItem(url: url, name:url.lastPathComponent, isDirectory: true)
    }

    private static func fetchDirectoryContent(from url: URL) -> [DirectoryItem] {
        let fileManager = FileManager.default
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
                .sorted(by: { $0.lastPathComponent < $1.lastPathComponent })
            var directoryItems: [DirectoryItem] = []
            for fileURL in fileURLs {
                var isDirectory: ObjCBool = false
                let exists = fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDirectory)
                if exists && (isDirectory.boolValue || allowedExtensions.contains(fileURL.pathExtension)) {
                    directoryItems.append(DirectoryItem(url: fileURL, name: fileURL.lastPathComponent, isDirectory: isDirectory.boolValue))
                }
            }
            return directoryItems
        } catch {
            print("Error while enumerating files \(url.path): \(error.localizedDescription)")
            return []
        }
    }
    
}
