//
//  AppState.swift
//  ImageSpectator
//
//  Created by Keisuke Isono on 2023/05/28.
//

import Foundation

enum ImageViewType {
    case grid, vertical, horizontal
}

enum ImageViewHorizontalDirectionType {
    case right, left
}

enum DirectorySortType: String, CaseIterable {
    case name = "name"
    case time = "time"
}

class AppState: ObservableObject {
    @Published var rootDirectory: Directory?
    @Published var searchText: String = ""
    @Published var imageViewType: ImageViewType = .grid {
        didSet {
            switch imageViewType {
            case .grid:
                imageViewVertivalColumnSize = imageViewGridColumnSize
            case .vertical:
                imageViewVertivalColumnSize = 1
            case .horizontal:
                break
            }
        }
    }
    @Published var imageViewGridColumnSize = 4 {
        didSet {
            imageViewVertivalColumnSize = imageViewGridColumnSize
        }
    }
    @Published var imageViewVertivalColumnSize = 4
    @Published var imageViewHorizontalDirectionType: ImageViewHorizontalDirectionType = .right
    @Published var imageViewHorizontalColumnSize = 1
    @Published var directorySortType: DirectorySortType = .name
    @Published var selectedDirectory: Directory? {
        didSet {
            selectedFile = nil
            if let dir = selectedDirectory {
                if selectedFile == nil {
                    selectedFile = dir.sortedFiles().first
                }
            }
        }
    }
    @Published var selectedFile: File?
    
    func frame() {
        
    }
}
