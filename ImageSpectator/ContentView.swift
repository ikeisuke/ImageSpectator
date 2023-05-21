//
//  ContentView.swift
//  ImageSpectator
//
//  Created by Keisuke Isono on 2023/05/21.
//

import SwiftUI

struct ContentView: View {
    @State private var directoryLoader = DirectoryLoader(directoryURL: nil)
    @State private var selectedImage: Image? = nil
    @State private var selectedFileURL: URL? = nil
    @State private var selectedImageItems: [DirectoryItem] = []
    @State private var searchText = ""

    var body: some View {
        if directoryLoader.isLoading {
            ProgressView()
        } else {
            GeometryReader { geometry in
                HSplitView {
                    VSplitView {
                        Button("Select Directory") {
                            let openPanel = NSOpenPanel()
                            openPanel.canChooseDirectories = true
                            openPanel.canChooseFiles = false
                            openPanel.allowsMultipleSelection = false
                            openPanel.begin { (result) in
                                if result == NSApplication.ModalResponse.OK {
                                    directoryLoader = DirectoryLoader(directoryURL: openPanel.url)
                                }
                            }
                        }
                        ScrollView {
                            if let root = directoryLoader.rootDirectory {
                                VSplitView {
                                    TextField("Search", text: $searchText)
                                        .padding()
                                    DirectoryView(directoryLoader: directoryLoader,
                                                  directoryItem: root,
                                                  selectedImage: $selectedImage,
                                                  selectedFileURL: $selectedFileURL,
                                                  selectedImageItems: $selectedImageItems)
                                    .frame(width: 200)
                                }
                            } else {
                                Text("Please select a directory")
                            }
                        }
                    }
                    .frame(width: 200)
                    if let image = selectedImage{
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else if !selectedImageItems.isEmpty {
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(.fixed(300)), count: 4)) {
                                ForEach(selectedImageItems, id: \.id) { imageItem in
                                    if let image = NSImage(contentsOf: imageItem.url) {
                                        Image(nsImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 300, height: 300)
                                            .onTapGesture {
                                                if imageItem.parent?.name == "ALL" {
                                                    if let parent = imageItem.parent {
                                                        directoryLoader.loadImageItems(directoryItem: parent)
                                                    }
                                                } else {
                                                    directoryLoader.selectedFileURL = imageItem.url
                                                }
                                            }
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
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
