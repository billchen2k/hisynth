//
//  ScreenBox.swift
//
//
//  Created by Bill Chen on 2023/4/5.
//

import Foundation
import SwiftUI

struct ScreenBox<Content: View>: View {

    var isOn: Bool = true
    var blankStyle: Bool = false
    var width: CGFloat = 200.0
    var height: CGFloat = 200.0

    var content: () -> Content?

    init(isOn: Bool, blankStyle: Bool = false, width: CGFloat = 200.0, height: CGFloat = 200.0,
         @ViewBuilder content: @escaping () -> Content? = { nil }) {
        self.isOn = isOn
        self.blankStyle = blankStyle
        self.width = width
        self.height = height
        self.content = content
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(isOn ? Theme.gradientLightScreen(max(width, height)) :
                        (blankStyle ? Theme.gradientBlankScreen(): Theme.gradientDarkScreen(max(width, height))))
                .border(.black, width: 1.0)
                .frame(width: width, height: height)
            content()
        }.frame(width: width, height: height)

    }
}

struct ScreenBox_Previews: PreviewProvider {
    static var previews: some View {
        ScreenBox(isOn: true, width: 48.0, height: 24.0) { }
    }
}
