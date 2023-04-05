//
//  LightButton.swift
//  
//
//  Created by Bill Chen on 2023/4/5.
//

import Foundation
import SwiftUI

struct LightButton: View {

    var isOn: Bool = false;
    var width: CGFloat = 200.0
    var height: CGFloat = 24.0

    /// Text to display on the button.
    var title: String = ""

    /// Action callback.
    var action: (() -> Void)?;

    var body: some View {

        let imageName = isOn ? "lightbutton-on" : "lightbutton-off"
        return ZStack {
            Image(imageName)
                .resizable()
                .frame(width: width)
                .shadow(color: .black.opacity(isOn ? 0 : 0.5), radius: 4.0, x: 0.0, y: 4.0)
                .overlay {
                    Rectangle()
                        .stroke(.black, lineWidth: 1.0)
                        .cornerRadius(3.0)
                }
            Text(title)
                .modifier(HSFont(.body1))
        }.frame(width: width, height: height)
            .onTapGesture {
                if let action = action {
                    action()
                }
            }
    }

}

struct LightButton_Container: View {

    @State var isOn = false

    var body: some View {
        LightButton(isOn: isOn, title: "Click Me!") {
            isOn.toggle()
        }
    }

}
struct LightButton_Previews: PreviewProvider {
    static var previews: some View {
        LightButton_Container()
    }
}
