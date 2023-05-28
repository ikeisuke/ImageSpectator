//
//  AppState.swift
//  ImageSpectator
//
//  Created by Keisuke Isono on 2023/05/28.
//

import Foundation

enum ImageViewType: String, CaseIterable, Identifiable{
    case grid, vertical, horizontal
    var id: String { self.rawValue }
}

enum ImageViewHorizontalDirectionType: String, CaseIterable, Identifiable {
    case left, right
    var id: String { self.rawValue }
}

enum DirectorySortType: String, CaseIterable {
    case name, time
}

enum CodingKeys {
    case rootDirectory, searchText, imageViewType, imageViewGridColumnSize, imageViewVertivalColumnSize, imageViewHorizontalColumnSize, imageViewHorizontalDirectionType, directorySortType, selectedDirectory, selectedFile
}

class AppState: ObservableObject {
    @Published var rootDirectory: Directory? {
        didSet {
            if rootDirectory == oldValue {
                return
            }
            if let dir = rootDirectory {
                searchText = ""
                selectedDirectory = nil
                selectedFile = nil
                do {
                    let bookmark = try dir.url.bookmarkData(options: [.withSecurityScope, .securityScopeAllowOnlyReadAccess],
                                                            includingResourceValuesForKeys: nil,
                                                            relativeTo: nil)
                    
                    UserDefaults.standard.set(bookmark, forKey: "rootDirectory")
                } catch {
                    print("Failed to create bookmark: \(error)")
                }
            }
        }
    }
    @Published var searchText: String = "" {
        didSet {
            if searchText == oldValue {
                return
            }
            UserDefaults.standard.set(searchText, forKey: "searchText")
        }
    }
    @Published var searchTextEditing: Bool = false
    @Published var imageViewType: ImageViewType = .grid {
        didSet {
            switch imageViewType {
            case .grid:
                imageViewVerticalColumnSize = imageViewGridColumnSize
            case .vertical:
                imageViewVerticalColumnSize = 1
            case .horizontal:
                break
            }
            UserDefaults.standard.set(imageViewType.rawValue, forKey: "imageViewType")
        }
    }
    @Published var imageViewGridColumnSize = 4 {
        didSet {
            imageViewVerticalColumnSize = imageViewGridColumnSize
            UserDefaults.standard.set(imageViewGridColumnSize, forKey: "imageViewGridColumnSize")
        }
    }
    @Published var imageViewVerticalColumnSize = 4 {
        didSet {
            UserDefaults.standard.set(imageViewVerticalColumnSize, forKey: "imageViewVerticalColumnSize")
        }
    }
    @Published var imageViewHorizontalDirectionType: ImageViewHorizontalDirectionType = .right {
        didSet {
            UserDefaults.standard.set(imageViewHorizontalDirectionType.rawValue, forKey: "imageViewHorizontalDirectionType")
        }
    }
    @Published var imageViewHorizontalColumnSize = 1 {
        didSet {
            UserDefaults.standard.set(imageViewHorizontalColumnSize, forKey: "imageViewHorizontalColumnSize")
        }
    }
    @Published var directorySortType: DirectorySortType = .name {
        didSet {
            UserDefaults.standard.set(directorySortType.rawValue, forKey: "directorySortType")
        }
    }
    @Published var selectedDirectory: Directory? {
        didSet {
            if selectedDirectory == oldValue {
                return
            }
            if let dir = selectedDirectory {
                UserDefaults.standard.set(dir.url.absoluteString, forKey: "selectedDirectory")
                dir.load()
            }
        }
    }
    @Published var selectedFile: File?  {
        didSet {
            if selectedFile == oldValue {
                return
            }
            if let file = selectedFile {
                UserDefaults.standard.set(file.url.absoluteString, forKey: "selectedFile")
            }
        }
    }
    init() {
        let userDefaults = UserDefaults.standard
        do {
            guard let bookmarkData = userDefaults.data(forKey: "rootDirectory") else {
                return
            }
            var isBookmarkStale = false
            let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isBookmarkStale)
            
            if !url.startAccessingSecurityScopedResource() {
                // Handle the failure case
            }
            rootDirectory = Directory(url: url, parent: nil)
            if let dir = rootDirectory {
                dir.load()
            }
        } catch {
            print("Failed to resolve bookmark: \(error)")
        }
        if let text = userDefaults.string(forKey: "searchText") {
            searchText = text
        }
        if let rawImageViewType = userDefaults.string(forKey: "imageViewType") {
            if let type = ImageViewType(rawValue: rawImageViewType) {
                imageViewType = type
            }
        }
        imageViewGridColumnSize = userDefaults.integer(forKey: "imageViewGridColumnSize")
        if imageViewGridColumnSize == 0 {
            imageViewGridColumnSize = 4
        }
        imageViewVerticalColumnSize = userDefaults.integer(forKey: "imageViewVerticalColumnSize")
        if imageViewVerticalColumnSize == 0 {
            imageViewVerticalColumnSize = 4
        }
        if let rawImageViewHorizontalDirectionType = userDefaults.string(forKey: "imageViewHorizontalDirectionType") {
            if let type = ImageViewHorizontalDirectionType(rawValue: rawImageViewHorizontalDirectionType) {
                imageViewHorizontalDirectionType = type
            }
        }
        imageViewHorizontalColumnSize = userDefaults.integer(forKey: "imageViewHorizontalColumnSize")
        if imageViewHorizontalColumnSize == 0 {
            imageViewHorizontalColumnSize = 1
        }
        if let rawDirectorySortType = userDefaults.string(forKey: "directorySortType") {
            if let type = DirectorySortType(rawValue: rawDirectorySortType) {
                directorySortType = type
            }
        }
        if let saved = userDefaults.string(forKey: "selectedDirectory") {
            if let url = URL(string: saved) {
            selectedDirectory = Directory(url: url, parent: rootDirectory)
                if let dir = selectedDirectory {
                    dir.load()
                    if let saved = userDefaults.string(forKey: "selectedFile") {
                        if let url = URL(string: saved) {
                            dump(url.lastPathComponent)
                            selectedFile = File(url: url, parent: dir)
                        }
                    }
                }
            }
        }
    }
}
