//
//  PowerToggle.swift
//  
//
//  Created by Bill Chen on 2023/4/5.
//

import Foundation
import SwiftUI

struct PowerToggle: View {
    @Binding var isOn: Bool

    var size: CGFloat = 50.0

    var body: some View {

        let imageName = isOn ? "powertoggle-on" : "powertoggle-off"
        return VStack {
            Image(imageName)
                .resizable()
                .frame(width: size, height: size)
                .shadow(color: .black.opacity(isOn ? 0 : 0.5), radius: 4.0, x: 0.0, y: 4.0)
        }.frame(width: size, height: size)
            .onTapGesture {
                isOn.toggle()
            }
    }
}

struct PowerToggle_Container: View {
    @State var isOn = true
    var body: some View {
        PowerToggle(isOn: $isOn)
    }
}

struct PowerToggle_Previews: PreviewProvider {
    static var previews: some View {
        PowerToggle_Container()
    }
}
