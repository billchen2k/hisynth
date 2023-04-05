//
//  ControlPanelContainer.swift
//  
//
//  Created by Bill Chen on 2023/4/5.
//

import Foundation
import SwiftUI

struct ControlPanelContainer<Content: View>: View {
    var content: () -> Content
    var title: String

    init(title: String = "", @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack {
            if !title.isEmpty {
                HStack {
                    Text(title).modifier(HSFont(.artTitle2)).padding(.bottom, 2.0)
                    Spacer()
                }

            }
            content()
        }
        .padding(.all, 10.0)
        .background(Theme.colorGray2)
        .border(.black, width: 1.0)
        .cornerRadius(4.0)
    }
}


struct ControlPanelContainer_Previews: PreviewProvider {
    static var previews: some View {
        ControlPanelContainer(title: "Low Frequency Oscillator") {
            Button("Title") {

            }
        }
    }
}
