//
//  ContentView.swift
//  ImageSpectator
//
//  Created by Keisuke Isono on 2023/05/21.
//

import SwiftUI

struct ContentView: View {
    private static let sortOptions = ["name", "time"]
    
    @State private var searchText = ""
    @State private var rootDirectory: Directory? = nil
    @State private var selectedDirImages: [File] = []
    @State private var selectedImage: File? = nil
    @State private var selectedTitle: String = ""
    @State private var selectedSort: String = sortOptions[0]
    
    var body: some View {
        GeometryReader { geometry in
            HSplitView {
                VSplitView {
                    Button("Select Directory") {
                        let openPanel = NSOpenPanel()
                        openPanel.canChooseDirectories = true
                        openPanel.canChooseFiles = false
                        openPanel.allowsMultipleSelection = false
                        if openPanel.runModal() == .OK {
                            if  let url = openPanel.url {
                                rootDirectory = Directory(url: url, parent: nil)
                                if let dir = rootDirectory {
                                    dir.load()
                                    if dir.hasDirectory() {
                                        selectedTitle = "TOP"
                                    }
                                }
                            }
                        }
                    }.padding()
                    if rootDirectory == nil {
                        Text("Please select a directory").padding()
                    } else {
                        Picker("Sort", selection: $selectedSort) {
                                        ForEach(Self.sortOptions, id: \.self) { option in
                                            Text(option).tag(option)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .padding()
                        TextField("Search", text: $searchText).padding()
                    }
                    ScrollView {
                        if let dir = rootDirectory{
                            LazyVGrid (columns: Array(repeating: GridItem(.flexible()), count: 1)){
                                HStack {
                                    Image("chevron.down")
                                    Text("TOP")
                                    Spacer()
                                }.padding()
                                    .onTapGesture {
                                        if dir.hasDirectory() {
                                            selectedImage = nil
                                            selectedDirImages = []
                                            selectedTitle = "TOP"
                                            
                                        }
                                    }
                                if dir.hasDirectory() {
                                    ForEach(dir.sorted(sort: selectedSort).filter({$0.url.lastPathComponent.contains(searchText) || searchText.isEmpty})) { directory in
                                        HStack {
                                            Image(systemName: directory.isOpened ? "chevron.down" : "chevron.right")
                                            Text(directory.url.lastPathComponent)
                                                .foregroundColor(selectedImage?.parent.url == directory.url || selectedDirImages.first?.parent.url == directory.url ? .blue : .white)
                                        }.padding().onTapGesture {
                                            directory.load()
                                            directory.isOpened = !directory.isOpened
                                            selectedDirImages = directory.files
                                            selectedImage = nil
                                            selectedTitle = directory.url.lastPathComponent
                                        }
                                        if directory.isOpened {
                                            ForEach(directory.files, id: \.id) { file in
                                                HStack {
                                                    Text(file.url.lastPathComponent)
                                                        .foregroundColor(selectedImage?.url == file.url ? .blue : .white)  // Change this line
                                                        .focusable()
                                                }
                                                .onTapGesture {
                                                    selectedImage = file
                                                    selectedTitle = file.parent.url.lastPathComponent
                                                }
                                            }
                                        }
                                    }
                                }
                            }.padding()
                        }
                    }.frame(width: 200)
                }.frame(width: 200)
                if let selected = selectedImage{
                    VStack {
                        HStack {
                            Button(" < ") {
                                if let file = selected.prev() {
                                    selectedImage = file
                                    selectedTitle = file.parent.url.lastPathComponent
                                }
                            }.padding()
                            Text(selectedTitle).padding()
                            Button(" > ") {
                                if let file = selected.next() {
                                    selectedImage = file
                                    selectedTitle = file.parent.url.lastPathComponent
                                }
                            }.padding()
                        }
                        Spacer()
                        if let image = NSImage(contentsOf: selected.url) {
                            ZStack {
                                Image(nsImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                GeometryReader { geometry in
                                    HStack {
                                        Color.blue.opacity(0.01)
                                            .frame(width: geometry.size.width / 2, height: geometry.size.height)
                                            .onTapGesture {
                                            if let file = selected.prev() {
                                                selectedImage = file
                                                selectedTitle = file.parent.url.lastPathComponent
                                            }
                                        }
                                        Color.green.opacity(0.01)
                                            .frame(width: geometry.size.width / 2, height: geometry.size.height)
                                            .onTapGesture {
                                            if let file = selected.next() {
                                                selectedImage = file
                                                selectedTitle = file.parent.url.lastPathComponent
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                } else if !selectedDirImages.isEmpty {
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.fixed(300)), count: 4)) {
                            ForEach(selectedDirImages, id: \.id) { file in
                                AsyncImage(url: file.url) { image in
                                    image
                                        .resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 300, height: 300)
                                .onTapGesture {
                                    selectedImage = file
                                    selectedDirImages = []
                                    selectedTitle = file.parent.url.lastPathComponent
                                }
                            }
                        }
                    }
                } else if selectedTitle == "TOP" {
                    if let dir = rootDirectory {
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(.fixed(300)), count: 4)) {
                                ForEach(
                                    dir.sorted(sort: selectedSort).compactMap { directory -> File? in
                                        directory.load()
                                        if directory.hasFile() {
                                            return directory.files.first
                                        }
                                        return nil
                                    }.filter({
                                        return $0.parent.url.lastPathComponent.contains(searchText) || searchText.isEmpty
                                    }), id: \.id) { file in
                                        VStack {
                                            AsyncImage(url: file.url) { image in
                                                image
                                                    .resizable()
                                            } placeholder: {
                                                ProgressView()
                                            }
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 300, height: 300)
                                            .onTapGesture {
                                                selectedDirImages = file.parent.files
                                                selectedImage = nil
                                                selectedTitle = "TOP"
                                            }
                                            Text(file.parent.url.lastPathComponent)
                                        }
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 300, height: 330)
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
