//
//  File.swift
//  
//
//  Created by Bill Chen on 2023/4/6.
//

import Foundation
import SwiftUI
import SpriteKit

struct EnvelopePanel: View {

    @ObservedObject var controller: EnvelopeController

    var scene: SKScene {
        let scene = ADSRScene()
        scene.env = controller.osc1.envPool[0]
        return scene
    }

    let sliderWidth: CGFloat = 50.0
    let screenWidth: CGFloat = 220.0

    var body: some View {
        ControlPanelContainer(title: "Envelope Generator", component: .env) {
            HStack {
                GeometryReader { geo in
                    VStack {
                        HSSlider(value: $controller.attackDuration, range: 0.0...2.0, stepSize: 0.005, height: geo.size.height * 0.85, allowPoweroff: false)
                        Spacer()
                        Text("Attack").modifier(HSFont(.body2))
                    }
                }.frame(width: sliderWidth)
                GeometryReader { geo in
                    VStack {
                        HSSlider(value: $controller.decayDuration, range: 0.05...2.0, stepSize: 0.005, height: geo.size.height * 0.85, allowPoweroff: false)
                        Spacer()
                        Text("Decay").modifier(HSFont(.body2))
                    }
                }.frame(width: sliderWidth)
                GeometryReader { geo in
                    VStack {
                        HSSlider(value: $controller.sustainLevel, range: 0.00...1.0, stepSize: 0.005, height: geo.size.height * 0.85, allowPoweroff: false)
                        Spacer()
                        Text("Sustain").modifier(HSFont(.body2))
                    }
                }.frame(width: sliderWidth)
                GeometryReader { geo in
                    VStack {
                        HSSlider(value: $controller.releaseDuration, range: 0.05...10.0, stepSize: 0.005, height: geo.size.height * 0.85, allowPoweroff: false, log: true)
                        Spacer()
                        Text("Release").modifier(HSFont(.body2))
                    }
                }.frame(width: sliderWidth)
                GeometryReader { geo in
                    VStack {
                        ScreenBox(isOn: false, width: geo.size.width, height: geo.size.height * 0.85) {
                            SpriteView(scene: scene,
                                       preferredFramesPerSecond: HiSynthApp.sceneFPS,
                                       options: [.allowsTransparency])
                        }
                        Spacer()
                        Text("Envelope Preview").modifier(HSFont(.body2))
                    }
                }.frame(width: screenWidth)


            }
        }
    }
}

