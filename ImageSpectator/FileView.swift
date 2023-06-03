//
//  Files.swift
//  ImageSpectator
//
//  Created by Keisuke Isono on 2023/05/26.
//

import SwiftUI

struct FileView: View {
    
    @ObservedObject var state: AppState
    
    var body: some View {
        VStack {
            ZStack {
                GeometryReader { geometry in
                    let timer = Timer.publish(every: 5.0 / Double(state.autoPlaySpeed), on: .main, in: .common).autoconnect()
                    if state.imageViewType == .grid {
                        let width = (geometry.size.width - 10 * (CGFloat(state.imageViewVerticalColumnSize) - 1)) / CGFloat(state.imageViewVerticalColumnSize) - 20
                        if let dir = state.selectedDirectory {
                            ScrollViewReader { value in
                                let files = dir.sortedFiles()
                                let index = state.selectedFile?.index()
                                ScrollView {
                                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(width)), count: state.imageViewVerticalColumnSize)) {
                                        ForEach(files.indices, id: \.self) { i in
                                            let file = files[i]
                                            VStack {
                                                AsyncImage(url: file.url) { image in
                                                    image
                                                        .resizable()
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                                .aspectRatio(contentMode: .fit)
                                                Text(file.url.lastPathComponent)
                                            }
                                            .id(i)
                                            .padding()
                                            .border(Color.blue, width: i == index ? 4 : 0)
                                            .frame(maxWidth: width)
                                            .onTapGesture {
                                                state.imageViewType = .horizontal
                                                state.selectedFile = file
                                                state.searchTextEditing = false
                                            }
                                        }
                                    }
                                }.onAppear{
                                    if let file = state.selectedFile {
                                        withAnimation{
                                            value.scrollTo(files.firstIndex(of: file))
                                        }
                                    }
                                }
                            }
                        }
                    } else if state.imageViewType == .vertical {
                        if let dir = state.selectedDirectory {
                            ScrollViewReader { value in
                                let files = dir.sortedFiles()
                                ScrollView {
                                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(geometry.size.width - 20)), count: 1)) {
                                        ForEach(files.indices, id: \.self) { i in
                                            let file = files[i]
                                            VStack {
                                                AsyncImage(url: file.url) { image in
                                                    image
                                                        .resizable()
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                                .aspectRatio(contentMode: .fit)
                                                Text(file.url.lastPathComponent)
                                            }
                                            .id(i)
                                            .padding()
                                            .frame(height: geometry.size.height)
                                            .onTapGesture {
                                                if let next = file.next() {
                                                    state.selectedFile = next
                                                    withAnimation {
                                                        value.scrollTo(files.firstIndex(of: next))
                                                    }
                                                }
                                                state.searchTextEditing = false
                                            }
                                        }
                                    }
                                }.onAppear{
                                    if let file = state.selectedFile {
                                        withAnimation{
                                            value.scrollTo(files.firstIndex(of: file))
                                        }
                                    }
                                }.onReceive(timer, perform: { _ in
                                    if state.autoPlay {
                                        if let file = state.selectedFile?.next() {
                                            withAnimation {
                                                value.scrollTo(files.firstIndex(of: file))
                                                state.selectedFile = file
                                            }
                                        }
                                    }
                                })
                            }
                        }
                    } else if (state.imageViewType == .horizontal) {
                        if let selected = state.selectedFile {
                            if let image = NSImage(contentsOf: selected.url) {
                                ZStack {
                                    HStack {
                                        if state.imageViewHorizontalDirectionType == .left && state.imageViewHorizontalColumnSize == 2 {
                                            if let next = selected.next() {
                                                if let image = NSImage(contentsOf: next.url) {
                                                    VStack {
                                                        Image(nsImage: image)
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                        Text(next.url.lastPathComponent)
                                                    }
                                                }
                                            }
                                        }
                                        VStack {
                                            Image(nsImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                            Text(selected.url.lastPathComponent)
                                        }
                                        if state.imageViewHorizontalDirectionType == .right && state.imageViewHorizontalColumnSize == 2 {
                                            if let next = selected.next() {
                                                if let image = NSImage(contentsOf: next.url) {
                                                    VStack {
                                                        Image(nsImage: image)
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                        Text(next.url.lastPathComponent)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    GeometryReader { geometry in
                                        HStack {
                                            Color.blue.opacity(0.01)
                                                .frame(width: geometry.size.width / 2, height: geometry.size.height)
                                                .onTapGesture {
                                                    if let file = state.imageViewHorizontalDirectionType == .right ? selected.prev(num: state.imageViewHorizontalColumnSize) : selected.next(num: state.imageViewHorizontalColumnSize) {
                                                        state.selectedFile = file
                                                    }
                                                    state.searchTextEditing = false
                                                    state.autoPlay = false
                                                }
                                            Color.green.opacity(0.01)
                                                .frame(width: geometry.size.width / 2, height: geometry.size.height)
                                                .onTapGesture {
                                                    if let file = state.imageViewHorizontalDirectionType == .left ? selected.prev(num: state.imageViewHorizontalColumnSize) : selected.next(num: state.imageViewHorizontalColumnSize) {
                                                        state.selectedFile = file
                                                    }
                                                    state.searchTextEditing = false
                                                    state.autoPlay = false
                                                }
                                        }
                                    }
                                }.onReceive(timer, perform: { _ in
                                    if state.autoPlay {
                                        if let file = state.selectedFile?.next(num: state.imageViewHorizontalColumnSize) {
                                            withAnimation {
                                                state.selectedFile = file
                                            }
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
            }
            Button("next") {
                if let file = state.selectedFile {
                    var num = 1
                    if state.imageViewType == .horizontal {
                        num = state.imageViewHorizontalColumnSize
                    }
                    if let file = file.next(num: num) {
                        state.selectedFile = file
                    }
                }
            }
            .hidden()
            .keyboardShortcut(.space, modifiers: [])
        }
    }
}

//struct Files_Previews: PreviewProvider {
//    static var previews: some View {
//        Files()
//    }
//}
