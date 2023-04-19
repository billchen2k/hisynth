//
//  WelcomeView.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/17.
//

import Foundation
import SwiftUI

struct WelcomeView: View {

    @EnvironmentObject var walkthrough: WalkthroughController
    @Binding var isPresented: Bool

    let windowWidth: CGFloat = 450.0
    let windowHeight: CGFloat = 200.0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if isPresented {
                    RoundedRectangle(cornerSize: CGSize(width: 12.0, height: 12.0))
                        .fill(Theme.colorGray2)
                        .shadow(color: Theme.colorHighlight.opacity(0.5), radius: 16.0)

                    RoundedRectangle(cornerSize: CGSize(width: 12.0, height: 12.0))
                        .stroke(Theme.colorHighlight, lineWidth: 2.0)

                    VStack(spacing: 16.0) {
                        HStack {
                            Text("Welcome to").modifier(HSFont(.title1))
                            Text("HiSynth").modifier(HSFont(.artTitle1))
                        }
                        Spacer()
                        VStack(alignment: .leading, spacing: 12.0) {
                            Text(HSComponent.welcome.description)
                                .modifier(HSFont(.body0))
                                .fixedSize(horizontal: false, vertical: true)
                            if geo.size.width <= geo.size.height {
                                Text("It is recommended to use this app in landscape mode.")
                                    .modifier(HSFont(.body0))
                            }
                        }
                        Spacer()
                        HStack {
                            ActionButton(title: "Close", icon: "xmark.circle.fill", width: 90.0, action: {
                                isPresented = false
                            })
                            Spacer()
                            ActionButton(title: "Start the Tutorial", icon: "book.circle.fill", width: 150.0, action: {
                                isPresented = false
                                walkthrough.activate(for: .osc)
                            })
                        }
                    }
                    .padding(14.0)
                }
            }.frame(width: windowWidth, height: windowHeight)
                .offset(CGSize(width: geo.size.width / 2.0 - windowWidth / 2.0,
                               height: geo.size.height / 2.0 - windowHeight / 2.0))
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(isPresented: .constant(true))
    }
}



