//
//  ImageSpectatorApp.swift
//  ImageSpectator
//
//  Created by Keisuke Isono on 2023/05/21.
//

import SwiftUI

@main
struct ImageSpectatorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first, let screen = NSScreen.main {
            let screenSize = screen.visibleFrame.size
            let newWidth = 250 + screenSize.height * 3 / 4
            let newHeight = screenSize.height
            let newSize = CGSize(width: newWidth, height: newHeight)
            window.setContentSize(newSize)
        }
    }
}
