//
//  DirectoryView.swift
//  ImageSpectator
//
//  Created by Keisuke Isono on 2023/05/21.
//

import SwiftUI

let icon = NSWorkspace.shared.icon(forFile: NSHomeDirectory())

struct DirectoryView: View {
    @ObservedObject var state: AppState
    
    @FocusState var focused: Bool

    var body: some View {
        VStack {
            Divider()
            HStack {
                Spacer()
                Text("Search Text")
                Spacer()
            }
            HStack {
                Spacer()
                if state.searchTextEditing {
                    TextField("Search", text: $state.searchText){
                        state.searchTextEditing = false
                    }
                    .focused($focused)
                    .multilineTextAlignment(.center)
                    .disabled(state.rootDirectory==nil)
                    .keyboardShortcut(KeyEquivalent("\r"), modifiers: [])
                } else {
                    let text = state.searchText != "" ? state.searchText : "未設定"
                    Text(text)
                        .frame(maxWidth: 200)
                        .onTapGesture {
                            state.searchTextEditing = true
                            focused = true
                        }
                }
                Spacer()
            }
            Divider()
            HStack {
                Spacer()
                Text("Change Sort")
                Spacer()
            }
            HStack {
                Spacer()
                Picker("", selection: $state.directorySortType) {
                    ForEach(DirectorySortType.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .multilineTextAlignment(.center)
                .pickerStyle(MenuPickerStyle())
                .disabled(state.rootDirectory==nil)
                Spacer()
            }
            Divider()
            HStack {
                Spacer().frame(width: 20)
                Button(action: {
                    if let dir = state.currentDirectory {
                        if let parent = dir.getParent() {
                            state.currentDirectory = parent
                        }
                    }
                }) {
                    Image(systemName: "arrow.left")
                }
                .disabled(state.currentDirectory == state.rootDirectory)
                Spacer()
            }
            Divider()
            ScrollViewReader { value in
                ScrollView {
                    if let current = state.currentDirectory {
                        if current.hasDirectory() {
                            let dirs = current.sortedDirectories(sort: state.directorySortType, filter: state.searchText)
                            LazyVGrid (columns: Array(repeating: GridItem(.flexible()), count: 1)){
                                ForEach(dirs.indices, id: \.self) { i in
                                    let dir = dirs[i]
                                    if dir.hasDirectory() {
                                        ZStack {
                                            Image(nsImage: icon)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 160)
                                                .padding()
                                            Text(dir.url.lastPathComponent)
                                                .frame(width: 160)
                                                .padding()
                                        }
                                        .onTapGesture(count: 2) {
                                            state.currentDirectory = dir
                                        }
                                        .onTapGesture {
                                            state.selectedDirectory = dir
                                            state.imageViewType = .grid
                                        }
                                    }
                                    if dir.hasFile() {
                                        VStack {
                                            if let file = dir.sortedFiles().first {
                                                AsyncImage(url: file.url) { image in
                                                    image
                                                        .resizable()
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                                .aspectRatio(contentMode: .fill)
                                                .frame(height: 240)
                                                .clipped()
                                                Text(dir.url.lastPathComponent)
                                                    .foregroundColor(state.selectedDirectory == dir ? .blue : .white)
                                            }
                                        }
                                        .id(i)
                                        .padding()
                                        .frame(height: 280)
                                        .onTapGesture {
                                            state.imageViewType = .grid
                                            state.selectedDirectory = dir
                                            state.selectedFile = state.selectedDirectory?.files.first
                                            state.searchTextEditing = false
                                        }
                                    }
                                }
                            }
                            .onAppear {
                                if let dir = state.selectedDirectory {
                                    withAnimation {
                                        value.scrollTo(dirs.firstIndex(of: dir))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: 200)
    }
}

//struct DirectoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        DirectoryView()
//    }
//}
