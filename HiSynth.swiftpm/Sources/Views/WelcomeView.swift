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

    var body: some View {
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
                    VStack {
                        Text(HSComponent.welcome.description)
                            .modifier(HSFont(.body0))
                            .fixedSize(horizontal: false, vertical: true)
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
        }.frame(width: 450.0, height: 200.0)
        .preferredColorScheme(.dark)
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(isPresented: .constant(true))
    }
}



