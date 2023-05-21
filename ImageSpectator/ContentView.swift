//
//  ContentView.swift
//  ImageSpectator
//
//  Created by Keisuke Isono on 2023/05/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var directoryLoader = DirectoryLoader()
    @State private var selectedImage: Image? = nil
    @State private var selectedImageSize: CGSize = CGSize(width:600, height:800)

    var body: some View {
        GeometryReader { geometry in
            HSplitView {
                List(directoryLoader.rootDirectory.children) { directory in
                    Text(directory.name)
                        .onTapGesture {
                            directoryLoader.fetchContents(for: directory)
                            let firstImageItem = directory.children.first(where: { !$0.isDirectory })
                            if let imageURL = firstImageItem?.url, let image = NSImage(contentsOf: imageURL) {
                                if let screen = NSScreen.main {
                                    if screen.frame.size.width < image.size.width {
                                        selectedImageSize = CGSize(width: screen.frame.size.width, height: screen.frame.size.width * image.size.height / image.size.width)
                                    } else {
                                        selectedImageSize = CGSize(width: screen.frame.size.height * image.size.width / image.size.height, height: screen.frame.size.height)
                                    }
                                }
                                self.selectedImage = Image(nsImage: image)
                            }
                        }
                }
                .frame(width: 200)
                if let image = selectedImage{
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Color.gray
                }
            }
        }
    }
    
    private func loadImage(dirUrl: URL) -> Image {
        let fileManager = FileManager.default
        do {
            let items = try fileManager.contentsOfDirectory(at: dirUrl, includingPropertiesForKeys: nil)
            if let firstImageURL = items.sorted(by:{ $0.lastPathComponent < $1.lastPathComponent }).first(where: { $0.pathExtension == "jpg" || $0.pathExtension == "png" || $0.pathExtension == "webp"  }) {
                let image = NSImage(contentsOf: firstImageURL)
                return Image(nsImage: image ?? NSImage())
            }
        } catch {
            // Handle error
            print("Failed to read directory contents. Error: \(error)")
        }
        return Image(nsImage: NSImage())
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class DirectoryItem: Identifiable {
    let id = UUID()
    let url: URL
    let isDirectory: Bool
    var children: [DirectoryItem] = []

    init(url: URL, isDirectory: Bool) {
        self.url = url
        self.isDirectory = isDirectory
    }

    var name: String {
        url.lastPathComponent
    }
}


struct DirectoryView: View {
    @ObservedObject var directoryLoader: DirectoryLoader
    var directoryItem: DirectoryItem

    var body: some View {
        if directoryItem.isDirectory {
            DisclosureGroup(isExpanded: .constant(true), content: {
                ForEach(directoryItem.children) { childItem in
                    DirectoryView(directoryLoader: directoryLoader, directoryItem: childItem)
                }
            }, label: {
                Text(directoryItem.name)
            })
            .onTapGesture {
                directoryLoader.fetchContents(for: directoryItem)
            }
        } else {
            Text(directoryItem.name)
        }
    }
}

class DirectoryLoader: ObservableObject {
    @Published var rootDirectory: DirectoryItem

    init() {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let rootDirectoryURL = homeDirectory.appendingPathComponent("tmp")
        self.rootDirectory = DirectoryItem(url: rootDirectoryURL, isDirectory: true)
        fetchContents(for: self.rootDirectory)
    }

    func fetchContents(for directoryItem: DirectoryItem) {
        directoryItem.children = Self.fetchDirectoryContent(from: directoryItem.url)
    }

    private func createDirectoryItem(url: URL) -> DirectoryItem {
        return DirectoryItem(url: url, isDirectory: true)
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
                if exists {
                    directoryItems.append(DirectoryItem(url: fileURL, isDirectory: isDirectory.boolValue))
                }
            }
            return directoryItems
        } catch {
            print("Error while enumerating files \(url.path): \(error.localizedDescription)")
            return []
        }
    }
}
