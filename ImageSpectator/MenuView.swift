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
            Spacer()
            if state.imageViewType == .horizontal {
                Text("Per Page:")
                    .frame(maxWidth: 100)
                Text(String(state.imageViewHorizontalColumnSize))
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 50)
                Stepper(value: $state.imageViewHorizontalColumnSize, in: 1...2) {}
                Divider()
                
                Picker("Direction:", selection: $state.imageViewHorizontalDirectionType) {
                    ForEach(ImageViewHorizontalDirectionType.allCases) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(maxWidth: 250)
                .disabled(state.rootDirectory==nil)
                Divider()
            }
            if state.imageViewType == .grid {
                Text("Grid Columns:")
                    .frame(maxWidth: 140)
                Text(String(state.imageViewGridColumnSize))
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 50)
                Stepper(value: $state.imageViewGridColumnSize, in: 4...10) {}
                Divider()
            }
            
            Picker("View Mode:", selection: $state.imageViewType) {
                ForEach(ImageViewType.allCases) { type in
                    Text(type.rawValue.capitalized).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(maxWidth: 300)
            .disabled(state.rootDirectory==nil)
            Spacer()
                .frame(width: 10)
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
