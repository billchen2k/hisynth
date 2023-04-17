//
//  ControlPanelContainer.swift
//  
//
//  Created by Bill Chen on 2023/4/5.
//

import Foundation
import SwiftUI

struct ControlPanelContainer<Content: View>: View {

    @EnvironmentObject var walkthrough: WalkthroughController

    var content: () -> Content
    var title: String
    var component: HSComponent?

    init(title: String = "", component: HSComponent? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.component = component
        self.content = content
    }

    var body: some View {
        VStack {
            if !title.isEmpty {
                HStack(alignment: .bottom) {
                    Text(title).modifier(HSFont(.artTitle2)).padding(.vertical, 2.0)
                    Spacer()
                    if let component = component {
                        walkthrough.walkthrough(for: component)
                    }
                }
            }
            content()
        }
        .padding(.horizontal, 8.0)
        .padding(.bottom, 4.0)
        .background(Theme.colorGray2)
        .cornerRadius(4.0)
        .overlay {
            RoundedRectangle(cornerRadius: 4.0)
                .stroke(Color.black, lineWidth: 1.0)
        }
        .id(component?.rawValue ?? -1)
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
