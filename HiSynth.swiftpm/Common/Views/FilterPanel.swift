//
//  FilterPanel.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/7.
//

import Foundation
import SwiftUI
import SpriteKit

struct FilterPanel: View {

    @ObservedObject var controller: FilterController

    let sliderWidth: CGFloat = 60.0
    let screenWidth: CGFloat = 300.0

    var scene: SKScene {
        let scene = FilterScene()
        scene.controller = controller
        scene.size.width = screenWidth
        return scene
    }

    var body: some View {
        ControlPanelContainer(title: "Filters") {
            HStack{
                GeometryReader { geo in
                    VStack {
                        HSSlider(value: $controller.lowPassCutoff, range: controller.filters.lowPassFilter.$cutoffFrequency.range, stepSize: 1.0, height: geo.size.height * 0.85, allowPoweroff: false)
                        Spacer()
                        Text("Cutoff").modifier(HSFont(.body2))
                    }
                }.frame(width: sliderWidth)
                GeometryReader { geo in
                    VStack {
                        HSSlider(value: $controller.lowPassRes, range: controller.filters.lowPassFilter.$resonance.range, stepSize: 0.01, height: geo.size.height * 0.85, allowPoweroff: false)
                        Spacer()
                        Text("Resonance").modifier(HSFont(.body2))
                    }
                }.frame(width: sliderWidth)

                GeometryReader { geo in
                    VStack {
                        ScreenBox(isOn: false, width: geo.size.width, height: geo.size.height * 0.85) {
                            SpriteView(scene: scene,
                                       preferredFramesPerSecond: 60,
                                       options: [.allowsTransparency],
                                       debugOptions: [.showsFPS, .showsNodeCount])
                            .padding(2.0)
                        }
                        Spacer()
                        HStack {
                            Text("Low Pass")
                            Spacer()
                            Text("EQ")
                            Spacer()
                            Text("High Pass")
                        }.modifier(HSFont(.body2))
                    }
                }.frame(width: screenWidth)

                GeometryReader { geo in
                    VStack {
                        HSSlider(value: $controller.highPassCutoff, range: controller.filters.highPassFilter.$cutoffFrequency.range, stepSize: 1.0, height: geo.size.height * 0.85, allowPoweroff: false)
                        Spacer()
                        Text("Cutoff").modifier(HSFont(.body2))
                    }
                }.frame(width: sliderWidth)
                GeometryReader { geo in
                    VStack {
                        HSSlider(value: $controller.highPassRes, range: controller.filters.highPassFilter.$resonance.range, stepSize: 0.01, height: geo.size.height * 0.85, allowPoweroff: false)
                        Spacer()
                        Text("Resonance").modifier(HSFont(.body2))
                    }
                }.frame(width: sliderWidth)
            }
        }
    }
}
