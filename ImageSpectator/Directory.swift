//
//  Directory.swift
//  ImageSpectator
//
//  Created by Keisuke Isono on 2023/05/22.
//

import Foundation

class DirectoryItem: ObservableObject, Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let name: String
    let isDirectory: Bool
    weak var parent: DirectoryItem?
    @Published var isOpened: Bool = false
    @Published var children: [DirectoryItem] = []
    @Published var image: Image? = nil
    
    init(url: URL, name: String, isDirectory: Bool, isOpened: Bool = false) {
        self.url = url
        self.name = name
        self.isDirectory = isDirectory
        self.isOpened = isOpened
    }
    
    static func == (lhs: DirectoryItem, rhs: DirectoryItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
