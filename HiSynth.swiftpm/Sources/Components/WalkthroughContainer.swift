//
//  HelpButton.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/17.
//

import Foundation
import SwiftUI

struct WalkthroughContainer: View {

    @EnvironmentObject var walkthrough: WalkthroughController

    let buttonSize: CGFloat = 20.0
    let imageSize: CGFloat = 10.0

    @Binding var isPresented: Bool

    var title: String?
    var content: String?
    var extras: AnyView?

    var component: HSComponent?
    var nextComponent: HSComponent?

    var body: some View {
        VStack(alignment: .center) {
            Button(action: {
                isPresented = true
            }) {
                Circle()
                    .fill(Theme.colorGray3)
                    .frame(width: buttonSize, height: buttonSize)
                    .shadow(radius: 4.0, x: 0.0, y: 2.0)
                    .overlay {
                        Image(systemName: "questionmark")
                            .font(.system(size: imageSize))
                            .foregroundColor(Theme.colorBodyText)
                    }
            }
        }.frame(height: buttonSize + 4.0)
            .popover(isPresented: $isPresented,
                     attachmentAnchor: .rect(.bounds), arrowEdge: .leading) {
                VStack {
                    if let title = title {
                        Text(title)
                            .modifier(HSFont(.title1))
                            .padding(.bottom, 8.0)
                    }
                    if let content = content {
                        Text(content).modifier(HSFont(.body0))
                    }
                    if let extras = extras {
                        extras
                    }
                    HStack {
                        ActionButton(title: "OK", icon: "checkmark.circle.fill", action: {
                            isPresented = false
                        })
                        Spacer()
                        if let nextComponent = nextComponent, let component = component {
                            ActionButton(title: "Next", icon: "arrow.forward.circle.fill", action: {
                                walkthrough.dismiss(for: component)
                                // Without this it can not be activated on macOS
#if os(macOS) || targetEnvironment(macCatalyst)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    walkthrough.activate(for: nextComponent)
                                }
#else
                                walkthrough.activate(for: nextComponent)
#endif
                            })
                        }
                    }
                }.padding(12.0)
                    .frame(width: 400.0)
                    .background(Theme.colorGray3)
            }
    }
}

struct HelpButton_Previews: PreviewProvider {
    static var previews: some View {
        WalkthroughContainer(isPresented: .constant(true), title: "Low Frequency Oscillator",
                content: "This is the test string.\nThis is the test string. This is the test string. This is the test string. This is the test string. This is the test string. This is the test string.")
    }
}

