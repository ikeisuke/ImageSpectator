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

    var body: some View {
        GeometryReader { geometry in
            HSplitView {
                ScrollView {
                    DirectoryView(directoryLoader: directoryLoader, directoryItem: directoryLoader.rootDirectory, selectedImage: $selectedImage, selectedFileURL: $selectedFileURL, selectedImageItems: $selectedImageItems)
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
                                       .onTapGesture {
                                           if imageItem.parent?.name == "ALL" {
                                               if let parent = imageItem.parent {
                                                   directoryLoader.loadImageItems(directoryItem: parent)
                                               }
                                           } else {
                                               directoryLoader.selectedImage = image
                                               directoryLoader.selectedFileURL = imageItem.url
                                               directoryLoader.selectedImageItems = []
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
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
