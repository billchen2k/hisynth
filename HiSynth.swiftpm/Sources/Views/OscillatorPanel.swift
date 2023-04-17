//
//  OscillatorPanel.swift
//
//
//  Created by Bill Chen on 2023/4/5.
//

import Foundation
import SwiftUI

struct OscillatorPanel: View {

    @ObservedObject var controller: OscillatorController

    let waveforms: [HSWaveform] = [.sine, .saw, .square, .triangle, .pulse]

    var waveform1: Float {
        4.0 - Float(waveforms.firstIndex(of: controller.waveform1)!)
    }

    var waveform2: Float {
        4.0 - Float(waveforms.firstIndex(of: controller.waveform2)!)
    }

    var body: some View {
        ControlPanelContainer(title: "Oscillator", component: .osc) {
            HStack(spacing: 8.0) {
                // OSC1 Selector
                GeometryReader {geo in
                    VStack {
                        HStack(spacing: 15) {
                            HSSlider(value: .constant(waveform1), range: 0...4, stepSize: 1.0, height: geo.size.height * 0.85, allowPoweroff: false) {value in
                                controller.waveform1 = waveforms[4 - Int(value)]
                            }
                            VStack(alignment: .leading) {
                                ForEach(0..<waveforms.count, id: \.self) { i in
                                    HStack {
                                        ScreenBox(isOn: waveforms[i] == controller.waveform1, blankStyle: true,
                                                  width: 40, height: 21) {
                                            Image(waveforms[i].getSymbolImageName())
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 26)
                                                .onTapGesture {
                                                    controller.waveform1 = waveforms[i]
                                                }
                                        }
                                        Text(waveforms[i].getReadableName().uppercased())
                                            .modifier(HSFont(.body1))
                                    }
                                    if (i < waveforms.count - 1) {
                                        Spacer()
                                    }
                                }
                            }.frame(height: geo.size.height * 0.85)
                        }
                        Spacer()
                        Text("OSC 1 Waveform").modifier(HSFont(.body2))
                    }
                }.frame(width: 175.0)
                GeometryReader { geo in
                    VStack {
                        HSKnob(value: $controller.level1,
                               range: 0...1,
                               size: 48.0,
                               allowPoweroff: true,
                               ifShowValue: false)
                        Text("OSC 1 Level").modifier(HSFont(.body2))
                        Spacer()
                        HSKnob(value: $controller.pitch1,
                               range: -12...12,
                               size: 48.0,
                               stepSize: 1.0,
                               allowPoweroff: false,
                               ifShowValue: true,
                               valueFormatter: { String(format: "%.0f", $0) })
                        Text("OSC 1 Pitch").modifier(HSFont(.body2))
                    }
                }.frame(width: 80.0)
                GeometryReader {geo in
                    VStack {
                        HStack(spacing: 15) {
                            HSSlider(value: .constant(waveform2), range: 0...4, stepSize: 1.0, height: geo.size.height * 0.85, allowPoweroff: false) {value in
                                controller.waveform2 = waveforms[4 - Int(value)]
                            }
                            VStack(alignment: .leading) {
                                ForEach(0..<waveforms.count, id: \.self) { i in
                                    HStack {
                                        ScreenBox(isOn: waveforms[i] == controller.waveform2, blankStyle: true,
                                                  width: 40, height: 21) {
                                            Image(waveforms[i].getSymbolImageName())
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 26)
                                                .onTapGesture {
                                                    controller.waveform2 = waveforms[i]
                                                }
                                        }
                                    }
                                    if (i < waveforms.count - 1) {
                                        Spacer()
                                    }
                                }
                            }.frame(height: geo.size.height * 0.85)
                        }
                        Spacer()
                        Text("OSC 2 Waveform").modifier(HSFont(.body2))
                    }
                }.frame(width: 100.0)
                GeometryReader { geo in
                    VStack {
                        HSKnob(value: $controller.level2,
                               range: 0...1,
                               size: 48.0,
                               allowPoweroff: true,
                               ifShowValue: false)
                        Text("OSC 2 Level").modifier(HSFont(.body2))
                        Spacer()
                        HSKnob(value: $controller.pitch2,
                               range: -12...12,
                               size: 48.0,
                               stepSize: 1.0,
                               allowPoweroff: false,
                               ifShowValue: true,
                               valueFormatter: { String(format: "%.0f", $0) })
                        Text("OSC 2 Pitch").modifier(HSFont(.body2))
                    }
                }.frame(width: 70.0)
            }
        }
    }
}

