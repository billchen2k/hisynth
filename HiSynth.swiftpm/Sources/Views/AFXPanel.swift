//
//  SFXPanel.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/13.
//

import Foundation
import SwiftUI

struct AFXPanel: View {

    @ObservedObject var controller: AFXController

    let knobSize: CGFloat = 48.0
    let toggleSize: CGFloat = 36.0
    let toggleWidth: CGFloat = 52.0
    let itemHeight: CGFloat = 50.0
    let itemWidth: CGFloat = 60.0
    let itemSpacing: CGFloat = 18.0

    let reverbs: [HSReverbType] = [.room, .hall]

    var body: some View {

        let reverbControls = HStack(spacing: itemSpacing) {
            VStack {
                PowerToggle(isOn: $controller.reverbOn, size: toggleSize)
                    .frame(width: toggleWidth, height: itemHeight)
                Text("Reverb").modifier(HSFont(.body2))
            }
            VStack {
                VStack {
                    ForEach(reverbs, id: \.self) { r in
                        LightButton(isOn: r == controller.reverbType,
                                    width: 80.0,
                                    height: 22.0,
                                    title: r.getReadableName()) {
                            controller.reverbType = r
                        }
                    }
                }.frame(width: itemWidth, height: itemHeight)
                Text("Type").modifier(HSFont(.body2))
            }
            VStack {
                HSKnob(value: $controller.reverbSize,
                       range: 1.0...3.0, size: knobSize, stepSize: 1.0,
                       allowPoweroff: false)
                .frame(width: itemWidth, height: itemHeight)
                Text("Size").modifier(HSFont(.body2))
            }
            VStack {
                HSKnob(value: $controller.reverbMix,
                       range: 0.0...1.0, size: knobSize, stepSize: 0.01,
                       allowPoweroff: true)
                .frame(width: itemWidth, height: itemHeight)
                Text("Mix").modifier(HSFont(.body2))
            }
        }

        let decimatorControls = HStack(spacing: itemSpacing) {
            VStack {
                PowerToggle(isOn: $controller.decimatorOn, size: toggleSize)
                    .frame(width: toggleWidth, height: itemHeight)
                Text("Decimator").modifier(HSFont(.body2))
            }
            VStack {
                HSKnob(value: $controller.decimatorRate,
                       range: 0.0...30.0, size: knobSize, stepSize: 0.1,
                       allowPoweroff: false)
                .frame(width: itemWidth, height: itemHeight)
                Text("Rate").modifier(HSFont(.body2))
            }
            VStack {
                HSKnob(value: $controller.decimatorMix,
                       range: 0.0...100.0, size: knobSize, stepSize: 1.0,
                       allowPoweroff: true)
                .frame(width: itemWidth, height: itemHeight)
                Text("Mix").modifier(HSFont(.body2))
            }
        }

        let driveControls = HStack(spacing: itemSpacing) {
            VStack {
                PowerToggle(isOn: $controller.driveOn, size: toggleSize)
                    .frame(width: toggleWidth, height: itemHeight)
                Text("Drive").modifier(HSFont(.body2))
            }
            VStack {
                HSKnob(value: $controller.driveGain,
                       range: -40.0...20.0, size: knobSize, stepSize: 0.1,
                       allowPoweroff: false)
                .frame(width: itemWidth, height: itemHeight)
                Text("Gain").modifier(HSFont(.body2))
            }
            VStack {
                HSKnob(value: $controller.driveMix,
                       range: 0.0...100.0, size: knobSize, stepSize: 1.0,
                       allowPoweroff: true)
                .frame(width: itemWidth, height: itemHeight)
                Text("Mix").modifier(HSFont(.body2))
            }
        }

        let delayControls = HStack(spacing: itemSpacing) {
            VStack {
                PowerToggle(isOn: $controller.delayOn, size: toggleSize)
                    .frame(width: toggleWidth, height: itemHeight)
                Text("Delay").modifier(HSFont(.body2))
            }
            VStack {
                HSKnob(value: $controller.delayFeedback,
                       range: 0.0...100.0, size: knobSize, stepSize: 1.0,
                       allowPoweroff: false, ifShowValue: true,
                       valueFormatter: { String(format: "%.0f%%", $0) })
                .frame(width: itemWidth, height: itemHeight)
                Text("Feedback").modifier(HSFont(.body2)).fixedSize()
            }
            VStack {
                HSKnob(value: $controller.delayTime,
                       range: 0.0...2.0, size: knobSize, stepSize: 0.05,
                       allowPoweroff: false, ifShowValue: true,
                       valueFormatter: { String(format: "%.1fs", $0) })
                .frame(width: itemWidth, height: itemHeight)
                Text("Time").modifier(HSFont(.body2))
            }
            VStack {
                HSKnob(value: $controller.delayMix,
                       range: 0.0...100.0, size: knobSize, stepSize: 1.0,
                       allowPoweroff: false)
                .frame(width: itemWidth, height: itemHeight)
                Text("Mix").modifier(HSFont(.body2))
            }
        }

        return ControlPanelContainer(title: "Audio Effects", component: .afx) {
            HStack {
                VStack(alignment: .leading) {
                    reverbControls
                    Spacer()
                    delayControls
                }
                Spacer()
                VStack(alignment: .leading) {
                    driveControls
                    Spacer()
                    decimatorControls
                }
            }
        }
    }
}


