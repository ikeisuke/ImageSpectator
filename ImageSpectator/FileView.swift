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
            GeometryReader { geometry in
                let itemSize = (geometry.size.width - 10 * (CGFloat(state.imageViewVertivalColumnSize) - 1)) / CGFloat(state.imageViewVertivalColumnSize)
                if let files = state.selectedDirectory?.sortedFiles() {
                    if state.imageViewType == .grid || state.imageViewType == .vertical {
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(.fixed(itemSize)), count: state.imageViewVertivalColumnSize)) {
                                ForEach(files, id: \.id) { file in
                                    VStack {
                                        AsyncImage(url: file.url) { image in
                                            image
                                                .resizable()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .aspectRatio(contentMode: .fit)
                                    }
                                    .padding()
                                    .frame(maxWidth: itemSize, maxHeight: geometry.size.height)
                                }
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
                                                    Image(nsImage: image)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                }
                                            }
                                        }
                                        Image(nsImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                        if state.imageViewHorizontalDirectionType == .right && state.imageViewHorizontalColumnSize == 2 {
                                            if let next = selected.next() {
                                                if let image = NSImage(contentsOf: next.url) {
                                                    Image(nsImage: image)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
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
                                                }
                                            Color.green.opacity(0.01)
                                                .frame(width: geometry.size.width / 2, height: geometry.size.height)
                                                .onTapGesture {
                                                    if let file = state.imageViewHorizontalDirectionType == .left ? selected.prev(num: state.imageViewHorizontalColumnSize) : selected.next(num: state.imageViewHorizontalColumnSize) {
                                                        state.selectedFile = file
                                                    }
                                                }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

//struct Files_Previews: PreviewProvider {
//    static var previews: some View {
//        Files()
//    }
//}
