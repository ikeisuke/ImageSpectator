//
//  ContentView.swift
//  ImageSpectator
//
//  Created by Keisuke Isono on 2023/05/21.
//

import SwiftUI

struct ContentView: View {
    
    @State private var searchText: String = ""
    @State private var selectedSort: String = ""
    
    @State private var rootDirectory: Directory? = nil
    @State private var currentDirectory: Directory? = nil
    
    @ObservedObject var state: AppState = AppState()
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                MenuView(state: state)
                    .frame(height:24)
                if state.rootDirectory != nil {
                    HSplitView {
                        DirectoryView(state: state)
                        FileView(state: state)
                    }
               }
            }
        }
    }
}
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
