//
//  ImageSpectatorApp.swift
//  ImageSpectator
//
//  Created by Keisuke Isono on 2023/05/21.
//

import SwiftUI

@main

struct ImageSpectatorApp: App {
    private let state: AppState = AppState()
    var body: some Scene {
        WindowGroup {
            ContentView(state: state)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.newItem) {
                Button("Select Directory") {
                    let openPanel = NSOpenPanel()
                    openPanel.canChooseDirectories = true
                    openPanel.canChooseFiles = false
                    openPanel.allowsMultipleSelection = false
                    if openPanel.runModal() == .OK {
                        if  let url = openPanel.url {
                            state.rootDirectory = Directory(url: url, parent: nil)
                            if let dir = state.rootDirectory {
                                state.currentDirectory = dir
                                dir.load()
                            }
                        }
                    }
                }
            }
        }
    }
}
