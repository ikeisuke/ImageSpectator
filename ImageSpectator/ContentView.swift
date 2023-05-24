//
//  ContentView.swift
//  ImageSpectator
//
//  Created by Keisuke Isono on 2023/05/21.
//

import SwiftUI

struct ContentView: View {
    @State private var directoryLoader = DirectoryLoader(directoryURL: nil)
    @State private var searchText = ""
    
    @State private var directory: Directory? = nil
    @State private var images: [File] = []
    @State private var selected: File? = nil
    private var loading: Bool = false

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
                                if result == NSApplication.ModalResponse.OK, let url = openPanel.url {
                                    directory = Directory(url: url, parent: nil)
                                    if let dir = directory {
                                        dir.load()
                                        if dir.hasDirectory() {
                                            images = dir.directories.compactMap { directory -> File? in
                                                directory.load()
                                                if directory.hasFile() {
                                                    return directory.files.first
                                                }
                                                return nil
                                            }
                                        }
                                    }
                                }
                            }
                        }.padding()
                        if directory == nil {
                            Text("Please select a directory").padding()
                        } else {
                            TextField("Search", text: $searchText).padding()
                        }
                        ScrollView {
                            if let dir = directory{
                                LazyVGrid (columns: Array(repeating: GridItem(.flexible()), count: 1)){
                                    HStack {
                                        Image("chevron.down")
                                        Text("TOP")
                                        Spacer()
                                    }.padding()
                                    .onTapGesture {
                                        if let dir = directory {
                                            if dir.hasDirectory() {
                                                images = dir.directories.compactMap { directory -> File? in
                                                    directory.load()
                                                    if directory.hasFile() {
                                                        return directory.files.first
                                                    }
                                                    return nil
                                                }
                                            }
                                        }
                                    }
                                    if dir.hasDirectory() {
                                        ForEach(dir.directories.filter({$0.url.lastPathComponent.contains(searchText) || searchText.isEmpty})) { directory in
                                            HStack {
                                                Image(systemName: directory.isOpened ? "chevron.down" : "chevron.right")
                                                Text(directory.url.lastPathComponent)
                                                    .foregroundColor(selected?.url == directory.url ? .blue : .white)  // Change this line
                                                    .focusable()
                                            }.padding().onTapGesture {
                                                if (!directory.hasFile()) {
                                                    directory.load()
                                                }
                                                if (directory.hasFile()) {
                                                    directory.isOpened = !directory.isOpened
                                                    images = directory.files
                                                }
                                                self.selected = nil
                                            }
                                            if directory.isOpened {
                                                ForEach(directory.files, id: \.id) { file in
                                                    HStack {
                                                        Text(file.url.lastPathComponent)
                                                            .foregroundColor(selected?.url == file.url ? .blue : .white)  // Change this line
                                                            .focusable()
                                                    }
                                                    .onTapGesture {
                                                        self.selected = file
                                                        images = []
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }.padding()
                            }
                        }.frame(width: 200)
                    }.frame(width: 200)
                    if loading {
                        ProgressView()
                    } else if let file = selected{
                        VStack {
                            HStack {
                                Button(" < ") {
                                    if let f = file.prev() {
                                        selected = f
                                    }
                                }.padding()
                                Button(" > ") {
                                    if let f = file.next() {
                                        selected = f
                                    }
                                }.padding()
                            }
                            Spacer()
                            if let image = NSImage(contentsOf: file.url) {
                                Image(nsImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                            Spacer()
                        }
                    } else if !images.isEmpty {
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(.fixed(300)), count: 4)) {
                                ForEach(images.filter({
                                    return $0.parent.url.lastPathComponent.contains(searchText) || searchText.isEmpty
                                }), id: \.id) { imageFile in
                                    AsyncImage(url: imageFile.url) { image in
                                        image
                                            .resizable()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 300, height: 300)
                                    .onTapGesture {
                                        selected = imageFile
                                        images = []
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
