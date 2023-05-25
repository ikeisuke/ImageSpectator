//
//  MenuView.swift
//  ImageSpectator
//
//  Created by Keisuke Isono on 2023/05/25.
//

import SwiftUI

struct MenuView: View {
    @ObservedObject var state: AppState
    
    var body: some View {
        HStack {
            TextField("Search", text: $state.searchText)
                .padding()
                .frame(maxWidth: 200)
                .disabled(state.rootDirectory==nil)
            Picker("Sort", selection: $state.directorySortType) {
                ForEach(DirectorySortType.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            .frame(maxWidth: 200)
            .disabled(state.rootDirectory==nil)
            Spacer()
            if state.imageViewType == .horizontal {
                Stepper(value: $state.imageViewHorizontalColumnSize, in: 1...2) {}
                    .padding()
                TextField("PerPage", value: $state.imageViewHorizontalColumnSize, formatter: NumberFormatter())
                    .multilineTextAlignment(.trailing)
                    .padding()
                    .frame(maxWidth: 50)
                    .disabled(true)
                Stepper(value: $state.imageViewHorizontalColumnSize, in: 1...2) {}
                    .padding()
                Button(action: {
                    switch state.imageViewHorizontalDirectionType {
                    case .right:
                        state.imageViewHorizontalDirectionType = .left
                    case .left:
                        state.imageViewHorizontalDirectionType = .right
                    }
                }) {
                    switch state.imageViewHorizontalDirectionType {
                    case .right:
                        Text("right")
                    case .left:
                        Text("left")
                    }
                }
                .disabled(state.rootDirectory==nil)
            }
            if state.imageViewType == .grid {
                TextField("GridSize", value: $state.imageViewGridColumnSize, formatter: NumberFormatter())
                    .multilineTextAlignment(.trailing)
                    .padding()
                    .frame(maxWidth: 50)
                    .disabled(true)
                Stepper(value: $state.imageViewGridColumnSize, in: 1...10) {}
                    .padding()
            }
            Button(action: {
                switch state.imageViewType {
                case .grid:
                    state.imageViewType = .vertical
                case .vertical:
                    state.imageViewType = .horizontal
                case .horizontal:
                    state.imageViewType = .grid
                }
            }) {
                switch state.imageViewType {
                case .grid:
                    Text("grid")
                case .vertical:
                    Text("vertical")
                case .horizontal:
                    Text("horizontal")
                }
            }
            .disabled(state.rootDirectory==nil)
            Button("Select Directory") {
                let openPanel = NSOpenPanel()
                openPanel.canChooseDirectories = true
                openPanel.canChooseFiles = false
                openPanel.allowsMultipleSelection = false
                if openPanel.runModal() == .OK {
                    if  let url = openPanel.url {
                        state.rootDirectory = Directory(url: url, parent: nil)
                        if let dir = state.rootDirectory {
                            dir.load()
                        }
                    }
                }
            }.padding()
        }
        if state.rootDirectory == nil {
            Spacer()
            Text("Please select a directory").padding()
            Spacer()
        }
    }
}

//struct MenuView_Previews: PreviewProvider {
//    static var previews: some View {
//        MenuView()
//    }
//}
