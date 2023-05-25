//
//  DirectoryView.swift
//  ImageSpectator
//
//  Created by Keisuke Isono on 2023/05/21.
//

import SwiftUI

struct DirectoryView: View {
    @ObservedObject var state: AppState

    var body: some View {
        ScrollView {
            if let root = state.rootDirectory {
                if root.hasDirectory() {
                    LazyVGrid (columns: Array(repeating: GridItem(.flexible()), count: 1)){
                        ForEach(root.sortedDirectories(sort: state.directorySortType).filter({$0.url.lastPathComponent.contains(state.searchText) || state.searchText.isEmpty}), id: \.id) { directory in
                            VStack {
                                if let file = directory.sortedFiles().first {
                                    AsyncImage(url: file.url) { image in
                                        image
                                            .resizable()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .aspectRatio(contentMode: .fit)
                                    Text(directory.url.lastPathComponent)
                                        .foregroundColor(state.selectedDirectory == directory ? .blue : .white)
                                }
                            }
                            .padding()
                            .onTapGesture {
                                state.selectedDirectory = directory
                            }
                        }
                    }
                }
            }
        }.frame(minWidth: 200)
    }
}

//struct DirectoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        DirectoryView()
//    }
//}
